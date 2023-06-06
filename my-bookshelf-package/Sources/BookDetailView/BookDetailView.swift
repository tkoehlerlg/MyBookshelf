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
import Models

public struct BookDetailViewState: ReducerProtocol {
    public struct State: Equatable {
        public var book: Book
        var colorScheme: ColorScheme = .light
        var loadingCover: Bool
        var cover: UIImage?
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
        var detailsState: DetailsState = .notes
        var textFieldPopUp: TextFieldPopUp.State?
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
        case authorsLoaded(Book)
        case gotBookBack
        case openLentToPopUp
        case textFieldPopUp(TextFieldPopUp.Action)
        case changedNotes(String)
        case deleteBookTapped
    }
    public init() {}
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
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
                        if book.authors.isEmpty {
                            var book = book
                            await book.loadAuthors()
                            await send(.authorsLoaded(book))
                        }
                    }
                )
            case .loadedCover(let cover):
                state.cover = cover
                state.loadingCover = false
                return .none
            case .loadingImageFailed:
                state.loadingCover = false
                return .none
            case .authorsLoaded(let book):
                state.book = book
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
            case .openLentToPopUp:
                state.textFieldPopUp = .init(
                    title: "Lent to",
                    placeholder: "My little Dog, Torben, ...",
                    textFieldValue: state.book.lentTo ?? "",
                    autoCorrect: false
                )
                return .none
            case .textFieldPopUp(.close):
                state.textFieldPopUp = nil
                return .none
            case .textFieldPopUp(.finished(let newValue)):
                guard !newValue.isEmpty else { return .send(.gotBookBack) }
                state.book.lentTo = newValue
                state.textFieldPopUp = nil
                return .none
            case .gotBookBack:
                state.book.lentTo = nil
                return .none
            case .changedNotes(let newNotes):
                state.book.notes = newNotes
                return .none
            case .closeButtonTapped, .textFieldPopUp, .deleteBookTapped:
                return .none
            }
        }
        .ifLet(\.textFieldPopUp, action: /Action.textFieldPopUp) {
            TextFieldPopUp()
        }
    }
}

public struct BookDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    var store: StoreOf<BookDetailViewState>

    public init(store: StoreOf<BookDetailViewState>) {
        self.store = store
    }

    struct ViewState: Equatable {
        var book: Book
        var loadingCover: Bool
        var cover: UIImage?
        var backgroundColor: Color
        var tintColor: Color
        var secondaryTintColor: Color
        var detailsState: BookDetailViewState.State.DetailsState
        init(state: BookDetailViewState.State) {
            book = state.book
            loadingCover = state.loadingCover
            cover = state.cover
            backgroundColor = state.backgroundColor
            tintColor = state.tintColor
            secondaryTintColor = state.secondaryTintColor
            detailsState = state.detailsState
        }
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { geo in
                WithViewStore(store, observe: ViewState.init) { viewStore in
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
                    .ignoresSafeArea(.keyboard)
                    .onAppear {
                        viewStore.send(.onAppear)
                        viewStore.send(.updateColorScheme(colorScheme))
                    }
                    .onChange(of: colorScheme) { viewStore.send(.updateColorScheme($0)) }
                    .navigationTitle(viewStore.book.title)
                    .topLeftCircleBackButton(
                        icon: .chevronDown,
                        backgroundColor: viewStore.secondaryTintColor,
                        tintColor: viewStore.backgroundColor,
                        topSafeAreaInset: geo.safeAreaInsets.top
                    ) {
                        viewStore.send(.closeButtonTapped, animation: .default)
                    }
                    IfLetStore(store.scope(
                        state: \.textFieldPopUp,
                        action: BookDetailViewState.Action.textFieldPopUp
                    ), then: TextFieldPopUpView.init)
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewStore.state)
                }
                .ignoresSafeArea(.container)
                .navigationBarHidden(true)
            }
        }
    }

    func titleView(_ viewStore: ViewStore<ViewState, BookDetailViewState.Action>) -> some View {
        VStack(spacing: 0) {
            if viewStore.loadingCover {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let cover = viewStore.cover {
                Image(uiImage: cover)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                    .padding(.top, 10)
            }
            ZStack {
                Text(title(book: viewStore.book))
                    .multilineTextAlignment(.center)
                    .font(.title2.leading(.tight), weight: .semibold)
                    .foregroundColor(viewStore.tintColor)
                    .padding(.horizontal, 50)
                Menu(systemImage: .ellipsisCircle) {
                    if viewStore.book.lentTo != nil {
                        Button {
                            viewStore.send(.gotBookBack)
                        } label: {
                            Label(
                                "Got Book back",
                                systemImage: "arrowshape.bounce.left"
                            )
                        }
                    } else {
                        Button {
                            viewStore.send(.openLentToPopUp, animation: .easeInOut)
                        } label: {
                            Label(
                                "Lent your Book",
                                systemImage: "arrowshape.bounce.right"
                            )
                        }
                    }
                    Button(role: .destructive) {
                        viewStore.send(.deleteBookTapped, animation: .default)
                    } label: {
                        Label("Delete Book", systemImage: .trash)
                    }
                }
                .foregroundColor(.accentColor)
                .fontWeight(.medium)
                .imageScale(.large)
                .frame(maxWidth: .infinity,alignment: .trailing)
                .padding(.trailing, 20)
            }
            if !viewStore.book.authors.isEmpty {
                NavigationLink {
                    AuthorsDetailsView(store: .init(
                        initialState: AuthorsDetailsViewState.State(
                            authors: viewStore.book.authors
                        ),
                        reducer: AuthorsDetailsViewState()
                    ))
                } label: {
                    HStack(spacing: 5) {
                        Text(viewStore.book.authors.map { $0.name }.joined(separator: ", "))
                            .font(.headline)
                        Image(systemName: .chevronRight)
                            .font(.subheadline)
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 5)
                }
            }
        }
        .padding(.bottom, 25)
    }

    func detailsView(_ viewStore: ViewStore<ViewState, BookDetailViewState.Action>) -> some View {
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
                    text: viewStore.binding(
                        get: \.book.notes,
                        send: BookDetailViewState.Action.changedNotes
                    ),
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
                        if let lentTo = book.lentTo {
                            VStack(alignment: .leading) {
                                Text("Lent to")
                                    .font(.headline)
                                Button {
                                    viewStore.send(.openLentToPopUp, animation: .easeInOut)
                                } label: {
                                    Text(lentTo)
                                    Image(systemName: .chevronRight)
                                }
                                .font(.body)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if let isbn10 = book.isbn10 {
                            InfoSection(title: "ISBN 10", value: isbn10)
                        }
                        if let isbn13 = book.isbn13 {
                            InfoSection(title: "ISBN 13", value: isbn13)
                        }
                        if let publishDate = book.publishDate {
                            InfoSection(title: "Publish Date", value: dateToString(publishDate))
                        }
                        InfoSection(title: "Publisher/s", value: book.publishers.joined(separator: ", "))
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
    }

    func title(book: Book) -> String {
        var response = book.title
        if let subtitle = book.subtitle {
            response += " – " + subtitle
        }
        return response
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
