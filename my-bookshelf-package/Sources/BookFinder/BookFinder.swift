import Foundation
import Request
import Combine
import Utils
import ImageFetcher
import DiskCache
import UIKit
import Models

// This BookFinder searches Books with the help of OpenLibrary,
// the goal is to search Books by ISBN and also the Covers of the Books
final public class BookFinder {
    private static var _fetcher: ImageFetcher?

    private init() {}
    public enum Failure: LocalizedError {
        case notFound
    }
    // MARK: Search Engine
    public static func search(isbn: String) async throws -> Book {
        do {
            return try await AnyRequest<Book> {
                Url("https://openlibrary.org/isbn/\(isbn).json")
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
    // MARK: Cover Loader
    public static func getCoverFor(isbn: String, size: ImageSize) async throws -> UIImage {
        let config = ImageConfiguration(
            url: URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-\(size.rawValue).jpg")!)
        return try await getFetcher().load(config)
    }
    public static func getCoverFor(coverID: Int, size: ImageSize) async throws -> UIImage {
        let config = ImageConfiguration(
            url: URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-\(size.rawValue).jpg")!)
        return try await getFetcher().load(config)
    }
    // MARK: Helper
    static func getFetcher() throws -> ImageFetcher {
        guard let _fetcher = _fetcher else {
            let fetcher = try ImageFetcher(DiskCache(storageType: .temporary(nil)))
            _fetcher = fetcher
            return fetcher
        }
        return _fetcher
    }
}

public enum ImageSize: String {
    case s, m, l
    public var rawValue: String {
        switch self {
        case .s: return "S"
        case .m: return "M"
        case .l: return "L"
        }
    }
}

extension AnyRequest {
    func call() async throws -> ResponseType {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?
            cancellable = self.objectPublisher.sink(
                receiveCompletion: { response in
                    switch response {
                    case .finished: break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { object in
                    continuation.resume(returning: object)
                }
            )
        })
        
    }
}

extension ImageFetcher {
    func load(_ imageConfiguration: ImageConfiguration) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.load(imageConfiguration) { result in
                switch result {
                case .success(let image):
                    continuation.resume(returning: image.value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
