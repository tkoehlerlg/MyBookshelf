import Foundation
import Request
import Models

public struct AuthorFinder {
    private init() {}
    public enum Failure: LocalizedError {
        case notFound
    }
    public static func getWith(link: String) async throws -> Author {
        do {
            return try await AnyRequest<Author> {
                Url("https://openlibrary.org\(link).json")
                Header.Accept(.json)
            }
            .call()
        } catch {
            guard let error = error as? RequestError else { throw error }
            if error.statusCode == 404 {
                throw Failure.notFound
            }
            throw error
        }
    }
}
