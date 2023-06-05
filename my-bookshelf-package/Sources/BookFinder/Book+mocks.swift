import UIKit

public extension Book {
    static var mock: Self {
        let image = UIImage(named: "mock_book_cover", in: .module, with: .none)
        let uuid = UUID().uuidString
        try! Self.getLocalCoversCache().cache(image!.pngData()!, key: "local_cover-\(uuid)")
        return .init(
            key: "works/1",
            isbn10: nil,
            isbn13: "1",
            title: "Bless the Daugther",
            subtitle: "Raised by a Voice in her Head",
            localCovers: [uuid],
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
            localBook: true,
            authors: [.mock],
            publishers: [],
            publishDate: nil
        )
    ]
}
