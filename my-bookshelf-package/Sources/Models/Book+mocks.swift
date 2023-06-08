import UIKit

public extension Book {
    static var mock: Self {
        return .init(
            key: "works/1",
            isbn10: nil,
            isbn13: "1",
            title: "Bless the Daugther",
            subtitle: "Raised by a Voice in her Head",
            description: nil,
            localCovers: [],
            localBook: true,
            authors: [.mock],
            publishers: ["The Torben Foundation"],
            publishDate: .now
        )
    }

    static var mocks: [Self] = [
        .mock,
        .init(
            key: "works/2",
            isbn10: nil,
            isbn13: "2",
            title: "Booth",
            subtitle: nil,
            description: nil,
            localBook: true,
            authors: [.mock],
            publishers: [],
            publishDate: nil
        ),
        .init(
            key: "works/3",
            isbn10: nil,
            isbn13: "3",
            title: "Checkout 19",
            subtitle: nil,
            description: nil,
            localBook: true,
            authors: [.mock],
            publishers: [],
            publishDate: nil
        )
    ]
}
