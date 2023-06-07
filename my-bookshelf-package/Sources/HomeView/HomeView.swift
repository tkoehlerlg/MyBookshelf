import SwiftUI
import SwiftUIX
import ComposableArchitecture
import BookFinder
import StateManager
import Models

public struct HomeViewState: ReducerProtocol {
    public struct State: Equatable {
        public var books: IdentifiedArrayOf<Book>
        var searchText: String = ""
        var booksStack: BooksStackState.State {
            get {
                if var _booksStack {
                    _booksStack.books = books
                    _booksStack.searchText = searchText
                    return _booksStack
                } else {
                    return .init(books: books, searchText: searchText)
                }
            }
            set {
                books = newValue.books
                _booksStack = newValue
            }
        }
        var scannerView: ScannerViewState.State?
        private var _booksStack: BooksStackState.State?

        public init(books: IdentifiedArrayOf<Book> = .init(uniqueElements: []), searchText: String = "") {
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
        case booksStack(BooksStackState.Action)
        case scannerView(ScannerViewState.Action)
        case editSearchText(String)
        case presentScannerViewSheet(Bool)
    }
    public init() {}
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .editSearchText(let newSearchText):
                state.searchText = newSearchText
                return .none
            case .scannerView(.addBook(let newBook)):
                state.books.append(newBook)
                state.scannerView = nil
                return .none
            case .scannerView(.closeTapped):
                return .send(.presentScannerViewSheet(false))
            case .presentScannerViewSheet(let present):
                state.scannerView = present ? .init() : nil
                return .none
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
        var searchText: String
        var showScannerViewSheet: Bool
        var books: IdentifiedArrayOf<Book>
        init(_ state: HomeViewState.State) {
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
                        if !viewStore.books.isEmpty {
                            BooksStack(store: store.scope(
                                state: \.booksStack,
                                action: HomeViewState.Action.booksStack
                            ), bottomSafeArea: bookButton)
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: .book)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                Text("No Books found please start by adding one.")
                                Image(systemName: .arrowDown)
                            }
                            .foregroundColor(.systemGray)
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
                prompt: Text("IBAN, Title, Author")
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
            .fontWeight(.medium)
            .padding(.vertical, 10)
            .padding(.horizontal, 17)
            .background(.systemGray5)
            .cornerRadius(10)
        }
        .height(bookButton)
        .maxWidth(.infinity)
        .background(.systemGray6)
        .cornerRadius([.topLeading, .topTrailing], 15)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.keyboard)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(
            initialState: HomeViewState.State(books: [.mockWithImage, .mocks[1]]),
            reducer: HomeViewState()
        ))
    }
}
