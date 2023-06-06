//
//  SwiftUIView.swift
//  
//
//  Created by Torben Köhler on 05.06.23.
//

import SwiftUI
import SwiftUIX
import ComposableArchitecture
import BookFinder
import Models

public struct ScannerFeedbackPopUp: ReducerProtocol {
    public enum State: Equatable {
        case bookAlreadyExisting
        case newBook(Book)
        case loading(ISBN: String)
        case bookNotFound
        case failure
    }
    public enum Action: Equatable {
        case cancelButtonTapped
        case addBookTapped
    }
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}

struct ScannerFeedbackPopUpView: View {
    @State var isAnimating = false
    var store: StoreOf<ScannerFeedbackPopUp>

    init(store: StoreOf<ScannerFeedbackPopUp>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewStore.send(
                            .cancelButtonTapped,
                            animation: .easeInOut
                        )
                    }
                ZStack {
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .foregroundColor(tint(viewStore)
                                    .opacity(0.2))
                            topIcon(viewStore)
                                .foregroundColor(tint(viewStore))
                                .padding(16)
                        }
                        .frame(width: 85, height: 85)
                        .padding(.bottom, 4)
                        Text(title(viewStore))
                            .font(.system(
                                .headline,
                                design: .rounded,
                                weight: .bold
                            ))
                        Text(subTitle(viewStore))
                            .font(.system(
                                .subheadline,
                                design: .rounded,
                                weight: .medium
                            ))
                            .multilineTextAlignment(.center)
                        if case let .newBook(book) = viewStore.state {
                            Button {
                                viewStore.send(.addBookTapped)
                            } label: {
                                Label("Add \"\(book.title)\"", systemImage: .plus)
                                    .lineLimit(1)
                                    .fontWeight(.medium)
                                    .tint(tint(viewStore))
                                    .height(42)
                                    .maxWidth(.infinity)
                                    .padding(.horizontal, 10)
                                    .background(tint(viewStore).opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .padding(.top, 12)
                        }
                    }
                }
                .padding(24)
                .overlay {
                    Button {
                        viewStore.send(
                            .cancelButtonTapped,
                            animation: .easeInOut
                        )
                    } label: {
                        Image(systemName: .xmarkCircle)
                            .fontWeight(.semibold)
                            .foregroundColor(.hex("B392AC"))
                            .imageScale(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(15)

                }
                .background(.systemBackground)
                .cornerRadius(30)
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 10,
                    x: 0, y: 0
                )
                .padding(25)
            }
        }
    }

    func topIcon(_ viewStore: ViewStoreOf<ScannerFeedbackPopUp>) -> some View {
        Group {
            switch viewStore.state {
            case .bookAlreadyExisting, .newBook:
                Image(systemName: "books.vertical")
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: .exclamationmarkTriangle)
                    .resizable()
                    .scaledToFit()
                    .padding(2)
            case .bookNotFound:
                Image(systemName: "book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
            case .loading:
                GeometryReader { geo in
                    Image(systemName: .barcodeViewfinder)
                        .resizable()
                        .scaledToFit()
                        .padding(3)
                    Rectangle()
                        .height(4)
                        .cornerRadius(2)
                        .padding(.top, self.isAnimating ? geo.size.height-22 : 0)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                        .padding(.vertical, 9)
                        .onAppear { isAnimating = true }
                        .onDisappear { isAnimating = false }
                }
            }
        }
    }

    func title(_ viewStore: ViewStoreOf<ScannerFeedbackPopUp>) -> String {
        switch viewStore.state {
        case .bookAlreadyExisting:
            return "Already existing"
        case .newBook:
            return "New book recognized!!!"
        case .loading:
            return "Loading ..."
        case .bookNotFound:
            return "Book could not be found in Database"
        case .failure:
            return "Error"
        }
    }

    func subTitle(_ viewStore: ViewStoreOf<ScannerFeedbackPopUp>) -> String {
        switch viewStore.state {
        case .bookAlreadyExisting:
            return "The book you scanned is already in your bookshelf."
        case .newBook:
            return "This book is not on your bookshelf, want to add it now?"
        case let .loading(ISBN: isbn):
            return "Loading Book with ISBN: \(isbn)"
        case .bookNotFound:
            return "We've searched in our Database but unfortunately found nothing! Scare isn't it?! Please insert your book manually."
        case .failure:
            return "A unknown Error occurred"
        }
    }

    func tint(_ viewStore: ViewStoreOf<ScannerFeedbackPopUp>) -> Color {
        switch viewStore.state {
        case .bookAlreadyExisting, .bookNotFound, .failure:
            return .systemRed
        case .newBook:
            return .systemGreen
        case .loading:
            return .systemOrange
        }
    }
}

struct ScannerFeedbackPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.systemGray6.ignoresSafeArea()
            Text("Lorem ipsum")
            ScannerFeedbackPopUpView(store: .init(
                initialState: ScannerFeedbackPopUp.State.failure,
                reducer: ScannerFeedbackPopUp()
            ))
        }
    }
}
