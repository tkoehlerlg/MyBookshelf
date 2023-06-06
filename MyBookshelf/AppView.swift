//
//  ContentView.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 20.05.23.
//

import SwiftUI
import ComposableArchitecture
import HomeView

struct AppView: View {
    @State var isAnimating: Bool = false
    var store: StoreOf<AppState>

    struct ViewState: Equatable {
        var isLoading: Bool
        init(state: AppState.State) {
            isLoading = state.isLoading
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                if viewStore.isLoading {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                        .scaleEffect(isAnimating ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                        .onAppear { isAnimating = true }
                        .onDisappear { isAnimating = false }
                        .transition(.opacity)
                } else {
                    TabView {
                        HomeView(store: store.scope(
                            state: \.homeView,
                            action: AppState.Action.homeView
                        ))
                        .tabItem {
                            Image(systemName: "books.vertical")
                        }
                        Text("Search")
                            .tabItem {
                                Image(systemName: .magnifyingglass)
                            }
                        Text("Profile/ Settings")
                            .tabItem {
                                Image(systemName: .personCropCircle)
                            }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: viewStore.isLoading)
            .onAppear { viewStore.send(.onAppear) }
        }
        ._printChanges()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: .init(
            initialState: AppState.State(),
            reducer: AppState()
        ))
    }
}
