import SwiftUI

struct AuthorDetailView: View {
    var body: some View {
        VStack {
            Image("author_image_placeholder", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(75)
            Text("Warsan Shire")
                .font(.system(size: 20), weight: .semibold)
            Text("Author")
                .font(.subheadline)
                .foregroundColor(.systemGray)
            VStack {
//                infoSection(title: "Per", value: <#T##String#>)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground.ignoresSafeArea())
    }

    func infoSection(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AuthorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorDetailView()
    }
}
