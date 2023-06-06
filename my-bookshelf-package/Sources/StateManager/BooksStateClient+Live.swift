import Foundation
import BookFinder
import ComposableArchitecture
import Models

extension BooksStateClient {
    public static var liveValue: BooksStateClient {
        let bookStateActor = BooksStateActor()
        return Self(
            loadBooks: { return await bookStateActor.loadState() },
            setBooks: { await bookStateActor.setState($0) }
        )
    }
}

private actor BooksStateActor {
    private var books: [Book] = [] // Performance Boost!
    private var jsonDecoder = JSONDecoder()
    private var jsonEncoder = JSONEncoder()

    // MARK: Load Books
    func loadState() -> [Book] {
        guard books.isEmpty else { return books }
        if let data = UserDefaults.standard.string(forKey: BooksStateClient.key)?.data(using: .utf8) {
            do {
                books = try jsonDecoder.decode([Book].self, from: data)
                print("🤖 \(books.count) Book(s) loaded from Memory")
                return books
            } catch {
                print("Error in decoding App Books State: \(error)")
                return []
            }
        }
        return []
    }
    // MARK: Save Books
    func setState(_ books: [Book]) {
        print("🤖 \(books.count) Book(s) saved")
        do {
            let data = try jsonEncoder.encode(books)
            UserDefaults.standard.set(String(data: data, encoding: .utf8), forKey: BooksStateClient.key)
            self.books = books
        } catch { print("Error in encoding App Books State: \(error)") }
    }

    func clearState() {
        UserDefaults.standard.setNilValueForKey(BooksStateClient.key)
    }
}
