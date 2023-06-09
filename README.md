# Torben's Bookshelf (iOS-App)
![Swift](https://img.shields.io/badge/Swift-5.6-brightgreen)

## About

An App for Remembering which books you have at home by simply saying it to you! Just scan the Code on the back of the book and know if you have it! Furthermore, adding books you have been never easier thanks to the [OpenLibrary](https://openlibrary.org). More benefits are also that the App knows everything about your book and also about your author, so you might find information you did not know before!

## Architecture Overview

This app is built with Swift, using The Composable Architecture (TCA) by [PointFree](https://www.pointfree.co). An interesting fact about the app is also that the different logic and UI parts of the app have been separated for better development.

## Links

- [ISBN Scanner (Modified)](https://github.com/tkoehlerlg/SwiftCodeScanner.git)
- [The Composable Architecture - Apps Architecture](https://github.com/pointfreeco/swift-composable-architecture.git)
- https://github.com/carson-katri/swift-request.git
- https://github.com/Mobelux/ImageFetcher.git

## Setup

1. Install the current Xcode Version (>= *14.3*). – [Link for installation](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_14.3/Xcode_14.3.xip) with [xcodereleases.com](https://xcodereleases.com)

2. Clone this project and navigate to the project's root directory.

3. Open the project with `open MyBookshelf.xcodeproj`.

4. Specify the Target in the top Bar. (You can also use your iPhone by connecting it to your Mac.) 
 
![Bildschirmfoto](https://github.com/tkoehlerlg/TorbensBookshelf/assets/62466714/661be652-cf9b-4d38-813d-4a70bec668df)

4. And now run the Project with <kbd>cmd</kbd> <kbd>r</kbd> or by clicking on the Play Button in the top-left corner.

## CI/CD

### Continuos Deployment

#### Deploying

Pushing changes to the main branch will deploy a new version to production. Xcode Cloud is recognising any changes on the main branch and auto-archiving and deploying the App.

## External Links

- [OpenLibrary](https://openlibrary.org) API for fetching details about a Book.
- [Swift](https://swift.org/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
