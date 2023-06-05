//
//  File.swift
//  
//
//  Created by Torben Köhler on 26.05.23.
//

import SwiftUI
import SwiftUIX
import ComposableArchitecture
import BookFinder
import Utils

public struct BookDetailViewState: ReducerProtocol {
    public struct State: Equatable {
        public var book: Book
        var colorScheme: ColorScheme = .light
        var loadingCover: Bool
        var cover: UIImage?
        var authors: [Author] = []
        var backgroundColor: Color {
            book.coverBackgroundColor(cover: cover, colorScheme: colorScheme)
        }
        var tintColor: Color {
            book.tintColor(cover: cover, bookHasCover: book.hasCover, colorScheme: colorScheme)
        }
        var secondaryTintColor: Color {
            book.secondaryTintColor(cover: cover, bookHasCover: book.hasCover, colorScheme: colorScheme)
        }
        public enum DetailsState: String, CaseIterable {
            case notes, details
            public var rawValue: String {
                switch self {
                case .notes: return "Notes"
                case .details: return "Informations"
                }
            }
        }
        var detailsState: DetailsState = .details
        public init(book: Book) {
            self.book = book
            self.loadingCover = !book.localBook
        }
    }
    public enum Action: Equatable {
        case onAppear
        case closeButtonTapped
        case loadedCover(UIImage)
        case loadingImageFailed
        case updateColorScheme(ColorScheme)
        case toggleMarked
        case detailsStateChanged(State.DetailsState)
        case authorsLoaded([Author])
    }
    public init() {}
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            guard state.book.hasCover else { return .none }
            state.loadingCover = true
            return .merge(
                .run(priority: .userInitiated) { [book = state.book] send in
                    do {
                        let cover = try await book.fetchFirstCover(imageSize: .m)
                        if let cover = cover {
                            await send(.loadedCover(cover))
                        } else { await send(.loadingImageFailed) }
                    } catch { await send(.loadingImageFailed) }
                },
                .run { [book = state.book] send in
                    await send(.authorsLoaded(book.getAuthors()))
                }
            )
        case .loadedCover(let cover):
            state.cover = cover
            state.loadingCover = false
            return .none
        case .loadingImageFailed:
            state.loadingCover = false
            return .none
        case .authorsLoaded(let authors):
            state.authors = authors
            return .none
        case .toggleMarked:
            state.book.marked.toggle()
            return .none
        case .updateColorScheme(let newColorScheme):
            state.colorScheme = newColorScheme
            return .none
        case .detailsStateChanged(let newState):
            state.detailsState = newState
            return .none
        case .closeButtonTapped:
            return .none
        }
    }
}

public struct BookDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    var store: StoreOf<BookDetailViewState>

    public init(store: StoreOf<BookDetailViewState>) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { geo in
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack(spacing: 0) {
                    titleView(viewStore)
                        .maxWidth(.infinity)
                        .safeAreaInset(.bottom, 30)
                        .safeAreaInset(.top, geo.safeAreaInsets.top)
                        .height(geo.size.height/10*6+30+geo.safeAreaInsets.top)
                        .background(viewStore.backgroundColor)
                    detailsView(viewStore)
                        .padding(.top, 16)
                        .maxWidth(.infinity)
                        .safeAreaInset(.bottom, geo.safeAreaInsets.bottom+15)
                        .height(geo.size.height/10*4+geo.safeAreaInsets.bottom)
                        .background(.color(.secondarySystemBackground).shadow(.inner(
                            color: .black.opacity(0.2),
                            radius: 10,
                            x: 0, y: 5
                        )))
                        .cornerRadius([.topLeading, .topTrailing], 30)
                        .offset(y: -30)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                    viewStore.send(.updateColorScheme(colorScheme))
                }
                .onChange(of: colorScheme) { viewStore.send(.updateColorScheme($0)) }
                .navigationTitle(viewStore.book.title)
                Button {
                    viewStore.send(.closeButtonTapped, animation: .default)
                } label: {
                    Image(systemName: .chevronLeft)
                        .tint(viewStore.backgroundColor)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .frame(width: 40, height: 40)
                        .background(viewStore.secondaryTintColor)
                        .cornerRadius(20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .safeAreaInset(.top, geo.safeAreaInsets.top)
                .padding(.top, 10)
                .padding(.leading, 15)
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
    }

    func titleView(_ viewStore: ViewStoreOf<BookDetailViewState>) -> some View {
        VStack(spacing: 0) {
            if viewStore.loadingCover {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let cover = viewStore.cover {
                Image(uiImage: cover)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(25)
                    .padding(.horizontal,50)
            }
            Text(viewStore.book.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(viewStore.tintColor)
                .padding(.top, 20)
            if !viewStore.authors.isEmpty {
                NavigationLink {
                    Text("Authors: \(viewStore.authors.map { $0.name }.joined(separator: ", "))")
                } label: {
                    HStack(spacing: 5) {
                        Text(viewStore.authors.map { $0.name }.joined(separator: ", "))
                            .font(.headline)
                        Image(systemName: .chevronRight)
                            .font(.subheadline)
                    }
                    .fontWeight(.medium)
                    .foregroundColor(viewStore.secondaryTintColor)
                    .padding(.top, 1)
                }

            }
        }
        .padding(.bottom, 25)
    }

    func detailsView(_ viewStore: ViewStoreOf<BookDetailViewState>) -> some View {
        VStack(spacing: 11) {
            Picker("Details View Picker", selection: viewStore.binding(
                get: \.detailsState,
                send: BookDetailViewState.Action.detailsStateChanged
            ).animation(.easeInOut)) {
                ForEach(BookDetailViewState.State.DetailsState.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            switch viewStore.detailsState {
            case .notes:
                TextField(
                    "Notes Text Field",
                    text: .constant(""),
                    prompt: Text("Your Notes ...")
                )
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(.systemGray5)
                .cornerRadius(20)
                .transition(.move(edge: .leading))
            case .details:
                let book = viewStore.book
                ScrollView {
                    VStack(spacing: 10) {
                        if let isbn10 = book.isbn10 {
                            infoSection(title: "ISBN 10", value: isbn10)
                        }
                        if let isbn13 = book.isbn13 {
                            infoSection(title: "ISBN 13", value: isbn13)
                        }
                        if let publishDate = book.publishDate {
                            infoSection(title: "Publish Date", value: dateToString(publishDate))
                        }
                        infoSection(title: "Publisher/s", value: book.publishers.joined(separator: ", "))
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
    }

    func infoSection(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(store: .init(
            initialState: BookDetailViewState.State(book: .mock),
            reducer: BookDetailViewState()
        ))
    }
}
