//
//  SwiftUIView.swift
//  
//
//  Created by Torben Köhler on 24.05.23.
//

import SwiftUI
import BookFinder
import ComposableArchitecture
import Utils
import BookDetailView
import Models

public struct BooksStackState: ReducerProtocol {
    public struct State: Equatable {
        var books: IdentifiedArrayOf<Book>
        var bookCards: IdentifiedArrayOf<BookCard.State> {
            get {
                if let _bookCards {
                    var response: [BookCard.State]
                    response = _bookCards.elements.compactMap { bookCardState in
                        if let book = books[id: bookCardState.id] {
                            var bookCardState = bookCardState
                            bookCardState.book = book
                            return bookCardState
                        } else { return nil }
                    }
                    if response.count < books.count {
                        for book in books {
                            if !response.contains(where: { $0.id == book.id }) {
                                response.append(.init(book: book, tapable: true))
                            }
                        }
                    }
                    return IdentifiedArray(uniqueElements: response.sorted(by: { $0.book.title > $1.book.title }))
                } else {
                    return .init(uniqueElements: books.map {
                        .init(
                            book: $0,
                            tapable: true,
                            cover: _bookCards?[id: $0.id]?.cover
                        )
                    })
                }
            }
            set { _bookCards = newValue }
        }
        var bookDetailView: BookDetailViewState.State? {
            didSet {
                guard let bookDetailView else { return }
                books[id: bookDetailView.book.id] = bookDetailView.book
            }
        }
        var _bookCards: IdentifiedArrayOf<BookCard.State>?

        init(books: IdentifiedArrayOf<Book>) {
            self.books = books
        }
    }
    public enum Action: Equatable {
        case bookCard(id: BookCard.State.ID, action: BookCard.Action)
        case bookDetailView(BookDetailViewState.Action)
        case navLinkIsActiveUpdate(Bool)
        case removeBookWithID(Book.ID)
    }
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .navLinkIsActiveUpdate(let isActive):
                guard !isActive else { return .none }
                state.bookDetailView = nil
                return .none
            case .bookCard(id: let bookId, action: .toggleMarked):
                state.books[id: bookId]?.marked.toggle()
                return .none
            case .bookCard(id: let bookId, action: .tapped):
                guard let book = state.books[id: bookId] else { return .none }
                state.bookDetailView = .init(book: book)
                return .none
            case .bookDetailView(.closeButtonTapped):
                state.bookDetailView = nil
                return .none
            case .bookDetailView(.deleteBookTapped):
                guard let bookId = state.bookDetailView?.book.id else { return .none}
                state.bookDetailView = nil
                return .run { send in
                    try await Task.sleep(for: .milliseconds(1))
                    await send(.removeBookWithID(bookId))
                }
            case .removeBookWithID(let id):
                state.books.remove(id: id)
                return .none
            case .bookCard, .bookDetailView:
                return .none
            }
        }
        .forEach(\.bookCards, action: /Action.bookCard) {
            BookCard()
        }
        .ifLet(\.bookDetailView, action: /Action.bookDetailView) {
            BookDetailViewState()
        }
    }
}

struct BooksStack: View {
    var bottomSafeArea: Double
    var store: StoreOf<BooksStackState>

    init(store: StoreOf<BooksStackState>, bottomSafeArea: Double) {
        self.store = store
        self.bottomSafeArea = bottomSafeArea
    }

    struct ViewState: Equatable {
        var bookDetailView: BookDetailViewState.State?
        init(_ state: BooksStackState.State) {
            bookDetailView = state.bookDetailView
        }
    }

    var body: some View {
        GeometryReader { geo in
            WithViewStore(store, observe: ViewState.init) { viewStore in
                ScrollView {
                    LazyVGrid(
                        columns: getGridItemsFor(width: geo.size.width),
                        spacing: 15
                    ) {
                        ForEachStore(store.scope(
                            state: \.bookCards,
                            action: BooksStackState.Action.bookCard(id:action:)
                        ), content: BookCardView.init)
                    }
                    .padding(.horizontal, 10)
                    .safeAreaInset(.bottom, bottomSafeArea)
                }
                .fullScreenCover(
                    isPresented: viewStore.binding(
                        get: { $0.bookDetailView != nil },
                        send: BooksStackState.Action.navLinkIsActiveUpdate
                    ), content: {
                        IfLetStore(store.scope(
                            state: \.bookDetailView,
                            action: BooksStackState.Action.bookDetailView
                        ), then: BookDetailView.init)
                    }
                )
            }
        }
    }

    func getGridItemsFor(width: CGFloat) -> [GridItem] {
        var width = width
        width -= 20 // subtract padding
        width -= CGFloat(15 * (Int(width/167.5) - 1)) // subtract spacing
        let columns = Int(width/167.5)
        var gridItems: [GridItem] = [GridItem(.fixed(167.5))]
        guard columns > 1 else { return gridItems }
        for _ in 2...columns {
            gridItems.append(GridItem(.fixed(167.5)))
        }
        return gridItems
    }
}

struct BooksStack_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BooksStack(store: .init(
                initialState: BooksStackState.State(
                    books: IdentifiedArray(uniqueElements: Book.mocks)
                ),
                reducer: BooksStackState()
            ), bottomSafeArea: 200)
            .ignoresSafeArea(.container, edges: .bottom)
            .ignoresSafeArea(.keyboard)
        }
    }
}
