import Foundation

public struct Author: Identifiable, Equatable {
    public var id: String { key }
    public var key: String
    public var name: String
    public var personalName: String?
    public var birthDate: Date?
    public var bio: String
    private var bookReferences: [BookReference] = [] // In a later version this will enable me to fetch the books of an Author

    init(key: String, name: String, personalName: String, birthDate: Date?, bio: String) {
        self.key = key
        self.name = name
        self.personalName = personalName
        self.birthDate = birthDate
        self.bio = bio
    }
}

extension Author: Decodable {
    enum CodingKeys: CodingKey {
        case key
        case name
        case personal_name
        case birth_date
        case bio
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        name = try container.decode(String.self, forKey: .name)
        personalName = try container.decodeIfPresent(String.self, forKey: .personal_name)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        if let birthDateString = try container.decodeIfPresent(String.self, forKey: .birth_date) {
            birthDate = dateFormatter.date(from: birthDateString)
        }
        bio = try container.decode(String.self, forKey: .bio)
    }
}

extension Author: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(name, forKey: .name)
        try container.encode(personalName, forKey: .personal_name)
        if let birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yyyy"
            try container.encode(dateFormatter.string(from: birthDate), forKey: .birth_date)
        } else { try container.encodeNil(forKey: .birth_date) }
        try container.encode(bio, forKey: .bio)
    }
}
