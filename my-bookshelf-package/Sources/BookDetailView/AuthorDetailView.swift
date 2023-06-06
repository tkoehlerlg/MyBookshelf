import SwiftUI
import ComposableArchitecture
import Models

struct AuthorsDetailsViewState: ReducerProtocol {
    struct State: Equatable {
        var authors: [Author]
        var selectedAuthor: Author?
        init(authors: [Author], selectedAuthor: Author? = nil) {
            self.authors = authors
            self.selectedAuthor = selectedAuthor
        }
    }
    var body: some ReducerProtocol<State, Void> = EmptyReducer()
}

struct AuthorsDetailsView: View {
    @Environment(\.dismiss) var dismiss
    var store: StoreOf<AuthorsDetailsViewState>
    let dateFormatter: DateFormatter
    init(store: StoreOf<AuthorsDetailsViewState>) {
        self.store = store
        self.dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = .current
    }
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.authors.count == 1, let firstAuthor = viewStore.authors.first {
                    authorDetailsView(author: firstAuthor)
                } else {
                    TabView {
                        ForEach(viewStore.authors) { author in
                            authorDetailsView(author: author)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .padding(.top, 35)
            .background(Color.systemBackground.ignoresSafeArea())
            .topLeftCircleBackButton(backgroundColor: .systemGray6, tintColor: .primary) {
                dismiss()
            }
        }
        .navigationBarHidden(true)
    }

    func authorDetailsView(author: Author) -> some View {
        VStack {
            Image(systemName: .person)
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .foregroundColor(.hex("735D78"))
                .padding(40)
                .frame(width: 150, height: 150)
                .background(.hex("F7D1CD"))
                .cornerRadius(75)
                .padding(.bottom, 5)
            Text(author.name)
                .font(.system(size: 20), weight: .semibold)
            Text("Author")
                .font(.subheadline)
                .foregroundColor(.systemGray)
            VStack(spacing: 5) {
                if let personalName = author.personalName {
                    InfoSection(title: "Personal Name", value: personalName)
                }
                if let birthDate = author.birthDate {
                    InfoSection(title: "Birthdate", value: dateToString(birthDate))
                }
                InfoSection(title: "Biographie", value: author.bio)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 25)
            .background(.systemGray6)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    func dateToString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

struct AuthorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorsDetailsView(store: .init(
            initialState: AuthorsDetailsViewState.State(authors: [.mock]),
            reducer: AuthorsDetailsViewState()
        ))
    }
}
