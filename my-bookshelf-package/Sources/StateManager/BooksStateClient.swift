import Foundation
import BookFinder
import ComposableArchitecture

/// The `StateManager` is a direct interface to the memory and was build to save the app books as a State
public struct BooksStateClient {
    internal static var key = "de.Torben-Koehler.MyBookshelf.books"

    public var loadBooks: @Sendable () async -> [Book]
    public var setBooks: @Sendable ([Book]) async -> Void
}

extension BooksStateClient: DependencyKey {
    public static var previewValue: BooksStateClient = Self(
        loadBooks: { return Book.mocks },
        setBooks: { _ in }
    )
}

extension DependencyValues {
    public var booksState: BooksStateClient {
        get { self[BooksStateClient.self] }
        set { self[BooksStateClient.self] = newValue }
    }
}
