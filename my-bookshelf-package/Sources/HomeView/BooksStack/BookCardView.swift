import SwiftUI
import BookFinder
import ComposableArchitecture
import Utils
import BookDetailView

public struct BookCard: ReducerProtocol {
    public struct State: Identifiable, Equatable {
        public var id: String { book.id }
        var book: Book
        var tapable: Bool
        var cover: UIImage?
        var loadingCover: Bool
        var colorScheme: ColorScheme = .light
        var backgroundColor: Color {
            book.coverBackgroundColor(cover: cover, colorScheme: colorScheme)
        }
        var tintColor: Color {
            book.tintColor(cover: cover, bookHasCover: book.hasCover, colorScheme: colorScheme)
        }

        init(book: Book, tapable: Bool) {
            self.book = book
            self.tapable = tapable
            self.loadingCover = !book.localBook
        }
    }
    public enum Action: Equatable {
        case onAppear
        case loadedCover(UIImage)
        case loadingImageFailed
        case updateColorScheme(ColorScheme)
        case toggleMarked
        case tapped
    }
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            guard state.book.hasCover else { return .none }
            state.loadingCover = true
            return .run(priority: .userInitiated) { [book = state.book] send in
                do {
                    let cover = try await book.fetchFirstCover(imageSize: .m)
                    if let cover = cover {
                        await send(.loadedCover(cover))
                    } else { await send(.loadingImageFailed) }
                } catch { await send(.loadingImageFailed) }
            }
        case .loadedCover(let cover):
            state.cover = cover
            state.loadingCover = false
            return .none
        case .loadingImageFailed:
            state.loadingCover = false
            return .none
        case .updateColorScheme(let newColorScheme):
            state.colorScheme = newColorScheme
            return .none
        case .toggleMarked, .tapped:
            return .none
        }
    }
}

struct BookCardView: View {
    @Environment(\.colorScheme) var colorScheme
    var store: StoreOf<BookCard>

    init(store: StoreOf<BookCard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if viewStore.tapable {
                Button(
                    action: { viewStore.send(.tapped) },
                    label: content(viewStore)
                )
            } else {
                content(viewStore)
            }
        }
    }

    func content(_ viewStore: ViewStoreOf<BookCard>) -> some View {
        ZStack {
            VStack(spacing: 10) {
                if viewStore.loadingCover {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let cover = viewStore.cover {
                    Image(uiImage: cover)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(5)
                }
                Text(viewStore.book.title)
                    .lineLimit(!viewStore.loadingCover && viewStore.cover == nil ? 0 : 1)
                    .font(.headline)
                    .foregroundColor(viewStore.tintColor)
            }
            Button(action: {
                viewStore.send(.toggleMarked, animation: .easeInOut(duration: 0.1))
            }, label: {
                Image(systemName: viewStore.book.marked ? .bookmarkFill : .bookmark)
                    .resizable()
                    .sizeToFit()
                    .height(25)
                    .tint(viewStore.tintColor)
            })
            .buttonStyle(NoAnimationButton())
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topTrailing
            )
        }
        .padding(9)
        .frame(width: 160, height: 180)
        .background(viewStore.backgroundColor)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(10)
        .onChange(of: colorScheme) { viewStore.send(.updateColorScheme($0)) }
        .onAppear {
            viewStore.send(.updateColorScheme(colorScheme))
            viewStore.send(.onAppear)
        }
    }
}

struct BookCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                Color.white
                Color.black
            }
            .ignoresSafeArea()
            BookCardView(store: .init(
                initialState: BookCard.State(
                    book: Book.mocks[0],
                    tapable: true
                ),
                reducer: BookCard()
            ))
            .frame(width: 160, height: 160)
        }
    }
}
