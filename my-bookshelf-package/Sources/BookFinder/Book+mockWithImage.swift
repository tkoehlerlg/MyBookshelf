import UIKit
import Models

public extension Book {
    static var mockWithImage: Self {
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
}
