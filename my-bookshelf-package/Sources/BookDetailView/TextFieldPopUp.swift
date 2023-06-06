import SwiftUI
import SwiftUIX
import ComposableArchitecture

public struct TextFieldPopUp: ReducerProtocol {
    public struct State: Equatable {
        var title: String
        var placeholder: String
        var textFieldValue: String
        var autoCorrect: Bool
    }
    public enum Action: Equatable {
        case doneTapped
        case textFieldValueChanged(String)
        case close
        case finished(String)
    }
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .doneTapped:
            return .send(.finished(state.textFieldValue))
        case .textFieldValueChanged(let newValue):
            state.textFieldValue = newValue
            return .none
        case .close, .finished:
            return .none
        }
    }
}

struct TextFieldPopUpView: View {
    @FocusState private var focusedField: Bool?
    var store: StoreOf<TextFieldPopUp>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewStore.send(.close, animation: .easeInOut)
                    }
                VStack(spacing: 0) {
                    Text(viewStore.title)
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 20)
                    HStack {
                        TextField(viewStore.placeholder, text: viewStore.binding(
                            get: \.textFieldValue,
                            send: TextFieldPopUp.Action.textFieldValueChanged
                        ))
                        .focused($focusedField, equals: true)
                        .onSubmit { viewStore.send(.doneTapped) }
                        .submitLabel(.done)
                        .autocorrectionDisabled(!viewStore.autoCorrect)
                        .font(.body)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(.systemGray6)
                        .cornerRadius(15)
                        Button { viewStore.send(.doneTapped) } label: {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .frame(maxHeight: .infinity)
                                .background(.accentColor)
                                .cornerRadius(15)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .maxWidth(.infinity)
                .background(.tertiarySystemBackground)
                .cornerRadius(25)
                .shadow(
                    color: .black.opacity(0.12),
                    x: 2, y: 2,
                    blur: 15
                )
                .padding(.horizontal, 20)
            }
            .onAppear { focusedField = true }
        }
    }
}

struct TextFieldPopUp_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPopUpView(store: .init(
            initialState: TextFieldPopUp.State(
                title: "An wen hast du dein Buch verliehen?",
                placeholder: "Name",
                textFieldValue: "Günter",
                autoCorrect: false
            ),
            reducer: TextFieldPopUp()
        ))
    }
}
