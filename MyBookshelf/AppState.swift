//
//  AppState.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 06.06.23.
//

import Foundation
import ComposableArchitecture
import HomeView
import StateManager
import Models

struct AppState: ReducerProtocol {
    struct State: Equatable {
        var isLoading: Bool = true
        var books: IdentifiedArrayOf<Book> = .init(uniqueElements: []) {
            didSet {
                guard books != _books else { return }
                Task(priority: .userInitiated) { [books] in
                    await DependencyValues._current.booksState.setBooks(books.elements)
                }
                _books = books
            }
        }
        var homeView: HomeViewState.State {
            get {
                if var _homeView = _homeView.value {
                    _homeView.books = books
                    return _homeView
                } else {
                    return .init(books: books)
                }
            }
            set {
                if !isLoading {
                    books = newValue.books
                }
                _homeView.value = newValue
            }
        }
        private var _homeView: Box<HomeViewState.State?> = .init(nil)
        private var _books: IdentifiedArrayOf<Book>? = nil
        init() { }
    }
    enum Action: Equatable {
        case onAppear
        case loadedBooks([Book])
        case homeView(HomeViewState.Action)
    }
    @Dependency(\.booksState) var booksState
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.loadedBooks(await booksState.loadBooks()))
                }
            case .loadedBooks(let books):
                state.isLoading = false
                state.books = IdentifiedArray(
                    uniqueElements: books.sorted(by: { $0.title > $1.title })
                )
                return .none
            case .homeView:
                return .none
            }
        }
        Scope(state: \.homeView, action: /Action.homeView) {
            HomeViewState()
        }
    }
}
