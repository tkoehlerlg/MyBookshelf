import SwiftUI

struct AuthorDetailView: View {
    var body: some View {
        VStack {
            Image("author_image_placeholder", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(75)
        }
        .background(.white)
    }
}

struct AuthorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorDetailView()
    }
}
