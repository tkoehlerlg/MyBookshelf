import Foundation
import UIKit
import DiskCache
import Utils

public struct Book: Identifiable, Equatable {
    public var id: String { isbn13 ?? isbn10 ?? UUID().uuidString }
    public var key: String
    public var isbn10: String?
    public var isbn13: String?
    public var title: String
    public var subtitle: String?
    public var covers: [Int]
    public var localCovers: [String]
    /// if this is true, please only use localCovers because this book was created localy and its unsure if there are covers online
    public let localBook: Bool
    private var authorsLinks: [String]
    private var _authors: [Author] = []
    public var publishers: [String]
    public var publishDate: Date?
    public var hasCover: Bool { !covers.isEmpty || !localCovers.isEmpty }
    public var marked: Bool
    public var notes: String
    public var lentTo: String?

    public init(
        key: String,
        isbn10: String?,
        isbn13: String?,
        title: String,
        subtitle: String? = nil,
        covers: [Int] = [],
        localCovers: [String] = [],
        localBook: Bool,
        authors: [Author],
        publishers: [String],
        publishDate: Date? = nil,
        marked: Bool = false,
        notes: String = ""
    ) {
        self.key = key
        self.isbn10 = isbn10
        self.isbn13 = isbn13
        self.title = title
        self.subtitle = subtitle
        self.covers = covers
        self.localCovers = localCovers
        self.localBook = localBook
        authorsLinks = []
        _authors = authors
        self.publishers = publishers
        self.publishDate = publishDate
        self.marked = marked
        self.notes = notes
    }

    public static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id && lhs.marked == rhs.marked
    }

    public func compareISBN(_ otherISBN: String) -> Bool {
        return isbn10 == otherISBN || isbn13 == otherISBN
    }

    public func compareISBNWith(otherBook: Book) -> Bool {
        var result = false
        if isbn10 != nil {
            result = isbn10 == otherBook.isbn10
        }
        if !result && isbn13 != nil {
            result = isbn13 == otherBook.isbn13
        }
        return result
    }
}

// MARK: Decodable
extension Book: Decodable {
    enum CodingKeys: CodingKey {
        case key
        case isbn_10
        case isbn_13
        case title
        case subtitle
        case authors
        case publish_date
        case publishers
        case covers
        case local_cover_names
        case local_book
        case marked
        case notes
        case lentTo
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        isbn10 = try container.decode([String].self, forKey: .isbn_10).first
        isbn13 = try container.decode([String].self, forKey: .isbn_13).first
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        authorsLinks = try container.decode([KeyWrapper<String>].self, forKey: .authors)
            .map { return $0.value }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        if let publishDateString = try container.decodeIfPresent(String.self, forKey: .publish_date) {
            publishDate = dateFormatter.date(from: publishDateString)
        }
        publishers = try container.decode([String].self, forKey: .publishers)
        covers = try container.decode([Int].self, forKey: .covers)
        localCovers = try container.decodeIfPresent([String].self, forKey: .local_cover_names) ?? []
        localBook = try container.decodeIfPresent(Bool.self, forKey: .local_book) ?? false
        marked = try container.decodeIfPresent(Bool.self, forKey: .marked) ?? false
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        lentTo = try container.decodeIfPresent(String.self, forKey: .lentTo)
    }
}

extension Book: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encodeIfPresent(isbn10, forKey: .isbn_10)
        try container.encodeIfPresent(isbn13, forKey: .isbn_13)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(authorsLinks, forKey: .authors)
        if let publishDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            try container.encode(dateFormatter.string(from: publishDate), forKey: .publish_date)
        }
        try container.encode(publishers, forKey: .publishers)
        try container.encode(covers, forKey: .covers)
        try container.encode(localCovers, forKey: .local_cover_names)
        try container.encode(localBook, forKey: .local_book)
        try container.encode(marked, forKey: .marked)
        if !notes.isEmpty {
            try container.encode(notes, forKey: .notes)
        } else {
            try container.encodeNil(forKey: .notes)
        }
        try container.encodeIfPresent(lentTo, forKey: .lentTo)
    }
}

// MARK: Covers cache
extension Book {
    private static var coversCache: DiskCache?
    static func getCoversCache() throws -> DiskCache {
        guard let coversCache = coversCache else {
            let newCoversCache = try DiskCache(storageType: .temporary(nil))
            coversCache = newCoversCache
            return newCoversCache
        }
        return coversCache
    }
    private static var localCoversCache: DiskCache?
    static func getLocalCoversCache() throws -> DiskCache {
        guard let coversCache = coversCache else {
            let newCoversCache = try DiskCache(storageType: .permanent(nil))
            coversCache = newCoversCache
            return newCoversCache
        }
        return coversCache
    }
}

// MARK: Covers loader
extension Book {
    public func fetchFirstCover(imageSize: ImageSize) async throws -> UIImage? {
        if localBook {
            guard let firstLocalCoverID = localCovers.first else { return nil }
            if let imageData = try? Self.getLocalCoversCache().data("local_cover-\(firstLocalCoverID)"),
               let cover = UIImage(data: imageData) {
                return cover
            } else { return nil }
        } else {
            guard let firstCoverID = covers.first else { return nil }
            if let imageData = try? Self.getCoversCache().data("cover-\(firstCoverID)-\(imageSize.rawValue)"),
               let cover = UIImage(data: imageData) {
                return cover
            }
            let cover = try await BookFinder.getCoverFor(coverID: firstCoverID, size: imageSize)
            if let imageData = cover.pngData() {
                try? Self.getCoversCache().cache(imageData, key: "cover-\(firstCoverID)-\(imageSize.rawValue)")
            }
            return cover
        }
    }

    public func fetchCovers(imageSize: ImageSize) async throws -> [UIImage] {
        var loadedCovers: [UIImage] = []
        if localBook {
            for localCoverID in localCovers {
                if let imageData = try? Self.getLocalCoversCache().data("local_cover-\(localCoverID)"),
                   let cover = UIImage(data: imageData) {
                    loadedCovers.append(cover)
                }
            }
        } else {
            for coverID in covers {
                if let imageData = try? Self.getCoversCache().data("cover-\(coverID)-\(imageSize.rawValue)"),
                   let cover = UIImage(data: imageData) {
                    loadedCovers.append(cover)
                    continue
                }
                let cover = try await BookFinder.getCoverFor(coverID: coverID, size: imageSize)
                if let imageData = cover.pngData() {
                    try? Self.getCoversCache().cache(imageData, key: "cover-\(coverID)-\(imageSize.rawValue)")
                }
                loadedCovers.append(cover)
            }
        }
        return loadedCovers
    }
}

// MARK: Author loader
extension Book {
    public func getAuthors() async -> [Author] {
        #if targetEnvironment(simulator)
        if self == .mock { return [.mock] }
        #endif
        var response: [Author] = []
        for authorLink in authorsLinks {
            guard let author = try? await AuthorFinder.getWith(link: authorLink) else { continue }
            response.append(author)
        }
        return response
    }
}
