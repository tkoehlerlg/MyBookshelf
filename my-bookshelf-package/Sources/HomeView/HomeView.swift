import SwiftUI
import SwiftUIX
import ComposableArchitecture
import BookFinder
import StateManager

public struct HomeViewState: ReducerProtocol {
    public struct State: Equatable {
        var isLoading: Bool = true
        var books: IdentifiedArrayOf<Book>
        var searchText: String = ""
        var booksStack: BooksStackState.State {
            get {
                if var _booksStack {
                    _booksStack.books = books
                    return _booksStack
                } else {
                    return .init(books: books)
                }
            }
            set {
                books = IdentifiedArray(
                    uniqueElements: newValue.bookCards.map { $0.book }
                )
                _booksStack = newValue
            }
        }
        var scannerView: ScannerViewState.State?
        private var _booksStack: BooksStackState.State?

        public init(books: [Book] = [], searchText: String = "") {
            self.books = IdentifiedArray(uniqueElements: books)
            self.searchText = searchText
        }

        init(books: [Book] = [.mock], searchText: String = "", presentedBook: Book = .mock) {
            self.books = IdentifiedArray(uniqueElements: books)
            self.searchText = searchText
            self._booksStack?.bookDetailView = .init(book: presentedBook)
        }
    }
    public enum Action: Equatable {
        case onAppear
        case loadBooksStateResponse([Book])
        case booksStack(BooksStackState.Action)
        case scannerView(ScannerViewState.Action)
        case editSearchText(String)
        case presentScannerViewSheet(Bool)
        case booksChanged
    }
    public init() {}
    @Dependency(\.booksState) var booksState
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run(priority: .high) { send in
                    await send(.loadBooksStateResponse(booksState.loadBooks()))
                }
            case .loadBooksStateResponse(let books):
                state.books = IdentifiedArray(uniqueElements: books)
                state.isLoading = false
                return .none
            case .editSearchText(let newSearchText):
                state.searchText = newSearchText
                return .none
            case .scannerView(.addBook(let newBook)):
                state.books.append(newBook)
                return .send(.booksChanged)
            case .scannerView(.closeTapped):
                return .send(.presentScannerViewSheet(false))
            case .presentScannerViewSheet(let present):
                state.scannerView = present ? .init() : nil
                return .none
            case .booksChanged:
                return .run { [books = state.books.elements] _ in
                    await booksState.setBooks(books)
                }
            case .booksStack, .scannerView:
                return .none
            }
        }
        .ifLet(\.scannerView, action: /Action.scannerView) {
            ScannerViewState()
        }
        Scope(state: \.booksStack, action: /Action.booksStack) {
            BooksStackState()
        }
    }
}

public struct HomeView: View {
    var store: StoreOf<HomeViewState>
    private let bookButton: Double = 80

    struct ViewState: Equatable {
        var isLoading: Bool
        var searchText: String
        var showScannerViewSheet: Bool
        var books: IdentifiedArrayOf<Book>
        init(_ state: HomeViewState.State) {
            isLoading = state.isLoading
            searchText = state.searchText
            showScannerViewSheet = state.scannerView != nil
            books = state.books
        }
    }

    public init(store: StoreOf<HomeViewState>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack {
                ZStack {
                    Group {
                        if viewStore.isLoading {
                            ProgressView()
                        } else if !viewStore.books.isEmpty {
                            BooksStack(store: store.scope(
                                state: \.booksStack,
                                action: HomeViewState.Action.booksStack
                            ), bottomSafeArea: bookButton)
                        } else {
                            VStack {
                                Text("No Books found please start by adding one.")
                                Image(systemName: .arrowDown)
                            }
                        }
                    }
                    .navigationTitle("My Bookshelf")
                    addBookButton(viewStore)
                }
            }
            .searchable(
                text: viewStore.binding(
                    get: \.searchText,
                    send: HomeViewState.Action.editSearchText
                ),
                prompt: Text("IBAN, Bookname, Author")
            )
            .sheet(isPresented: viewStore.binding(
                get: \.showScannerViewSheet,
                send: HomeViewState.Action.presentScannerViewSheet
            )) {
                IfLetStore(store.scope(
                    state: \.scannerView,
                    action: HomeViewState.Action.scannerView
                ), then: ScannerView.init)
            }
            .onAppear { viewStore.send(.onAppear) }
            .onChange(of: viewStore.books) { _ in viewStore.send(.booksChanged) }
        }
    }

    func addBookButton(_ viewStore: ViewStore<ViewState, HomeViewState.Action>) -> some View {
        Button {
            viewStore.send(.presentScannerViewSheet(true), animation: .default)
        } label: {
            HStack {
                Text("Add Book")
                Image(systemName: .plus)
            }
            .foregroundColor(.primary.colorInvert())
            .fontWeight(.bold)
            .padding(.vertical, 10)
            .padding(.horizontal, 17)
            .background(.hex("D1B3C4"))
            .cornerRadius(10)
        }
        .height(bookButton)
        .maxWidth(.infinity)
        .background(.hex("B392AC"))
        .cornerRadius([.topLeading, .topTrailing], 15)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.keyboard)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(
            initialState: HomeViewState.State(books: []),
            reducer: HomeViewState()
        ))
    }
}
