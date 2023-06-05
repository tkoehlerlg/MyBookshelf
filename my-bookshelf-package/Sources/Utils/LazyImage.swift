import SwiftUI
import SwiftUIX

public struct LazyImage: View {
    var lazyImage: () async throws -> UIImage?
    @State var viewState: ViewState = .loading

    public init(lazyImage: @escaping () async throws -> UIImage?) {
        self.lazyImage = lazyImage
    }

    enum ViewState: Equatable {
        case loading, image(UIImage), failure, empty
    }

    public var body: some View {
        switch viewState {
        case .loading:
            ProgressView()
                .task(priority: .userInitiated, {await loadImage()})
        case .image(let image):
            Image(uiImage: image)
                .resizable()
                .sizeToFit()
        case .failure:
            HStack(spacing: 15) {
                Image(systemName: .exclamationmarkTriangle)
                    .resizable()
                    .sizeToFit()
                    .frame(width: 50, height: 50)
                Text("Unexpected Failure")
            }
            .tint(.systemRed)
            .font(.headline)
        case .empty:
            EmptyView()
        }
    }

    func loadImage() async {
        do {
            guard let image = try await lazyImage() else {
                viewState = .empty
                return
            }
            viewState = .image(image)
        } catch {
            viewState = .failure
        }
    }
}

struct LazyImage_Previews: PreviewProvider {
    static var previews: some View {
        LazyImage(lazyImage: { return .checkmark })
    }
}
