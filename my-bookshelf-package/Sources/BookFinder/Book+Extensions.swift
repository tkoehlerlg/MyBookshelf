import Foundation
import UIKit
import DiskCache
import Utils
import Models

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
    public mutating func loadAuthors() async {
        #if targetEnvironment(simulator)
        if self == .mock { return }
        #endif
        guard authors.isEmpty else { return }
        for authorLink in authorsLinks {
            guard let author = try? await AuthorFinder.getWith(link: authorLink) else { continue }
            authors.append(author)
        }
    }
}
