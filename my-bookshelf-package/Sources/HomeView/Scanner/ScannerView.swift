import SwiftUI
import SwiftUIX
import CodeScanner
import BookFinder
import ComposableArchitecture
import Utils

struct ScannerView: View {
    var store: StoreOf<ScannerViewState>

    struct ViewState: Equatable {
        var isTorchOn: Bool
        var popUpIsShown: Bool
        init(_ state: ScannerViewState.State) {
            isTorchOn = state.isTorchOn
            popUpIsShown = state.feedbackPopUp != nil
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                VStack {
                    HStack {
                        Text("ISBN Scanner")
                        Image(systemName: .barcodeViewfinder)
                        Spacer()
                        Button(systemImage: .xmarkCircle) {
                            viewStore.send(.closeTapped, animation: .default)
                        }
                        .fontWeight(.medium)
                    }
                    .font(.title)
                    .bold()
                    .frame(height: 50, alignment: .bottom)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 15)
                    .padding(.top, 20)
                    ZStack {
                        CodeScannerView(
                            codeTypes: [.ean8, .ean13],
                            scanMode: .continuous,
                            showViewfinder: true,
                            simulatedData: "9780545029360",
                            shouldVibrateOnSuccess: !viewStore.popUpIsShown,
                            isTorchOn: viewStore.isTorchOn,
                            completion: { result in
                                switch result {
                                case .success(let result):
                                    viewStore.send(.scannerSuccess(result.string))
                                case .failure:
                                    viewStore.send(.scannerFailure)
                                }
                            })
                        .background(.systemGray6)
                        .cornerRadius(25)
                        Button {
                            viewStore.send(.toggleTorch, animation: .none)
                        } label: {
                            Image(systemName: .lightbulb)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .frame(width: 55, height: 55)
                                .background(viewStore.isTorchOn ? .black : .yellow)
                                .tint(viewStore.isTorchOn ? .white : .black)
                                .cornerRadius(58)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 15)
                    }
                    Button(action: {
                        // Code for manuall adding
                    }, label: {
                        HStack(spacing: 12) {
                            Text("Manuell hinzufügen")
                            Image(systemName: .docAppend)
                        }
                        .tint(.white)
                        .fontWeight(.bold)
                        .padding(15)
                        .maxWidth(.infinity)
                        .background(.accentColor)
                        .cornerRadius(15)
                    })
                    .padding(.vertical, 30)
                }
                .padding(.horizontal, 20)
                IfLetStore(store.scope(
                    state: \.feedbackPopUp,
                    action: ScannerViewState.Action.feedbackPopUp
                ), then: ScannerFeedbackPopUpView.init)
                .transition(.opacity)
                .animation(.easeInOut, value: viewStore.popUpIsShown)
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(store: .init(
            initialState: ScannerViewState.State(),
            reducer: ScannerViewState()
        ))
    }
}
