import Foundation
import Utils

public struct Book: Identifiable, Equatable {
    public var id: String { key }
    public var key: String
    public var isbn10: String?
    public var isbn13: String?
    public var title: String
    public var subtitle: String?
    public var description: String?
    public var covers: [Int]
    public var localCovers: [String]
    /// if this is true, please only use localCovers because this book was created localy and its unsure if there are covers online
    public let localBook: Bool
    /// please use authors for an easier usage and run loadAuthors if authors is emty
    public var authorsLinks: [String]
    public var authors: [Author]
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
        description: String?,
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
        self.authors = authors
        self.publishers = publishers
        self.publishDate = publishDate
        self.marked = marked
        self.notes = notes
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
        case description
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
        if let isbn10 = try? container.decodeIfPresent([String].self, forKey: .isbn_10)?.first {
            self.isbn10 = isbn10
        } else {
            self.isbn10 = try container.decodeIfPresent(String.self, forKey: .isbn_10)
        }
        if let isbn13 = try? container.decodeIfPresent([String].self, forKey: .isbn_13)?.first {
            self.isbn13 = isbn13
        } else {
            self.isbn13 = try container.decodeIfPresent(String.self, forKey: .isbn_13)
        }
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        if let authorsLinks = try? container.decode([KeyWrapper<String>].self, forKey: .authors).map({ $0.value }) {
            self.authorsLinks = authorsLinks
            authors = []
        } else if let authorsLinks = try? container.decode([String].self, forKey: .authors) {
            self.authorsLinks = authorsLinks
            authors = []
        } else {
            authorsLinks = []
            authors = try container.decode([Author].self, forKey: .authors)
        }
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
        try container.encode(description, forKey: .description)
        if !authors.isEmpty {
            try container.encode(authors, forKey: .authors)
        } else {
            try container.encode(authorsLinks, forKey: .authors)
        }
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
