//
//  ContentView.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 20.05.23.
//

import SwiftUI
import HomeView

struct MainView: View {
    var body: some View {
        TabView {
            HomeView(store: .init(
                initialState: HomeViewState.State(books: [.mock]),
                reducer: HomeViewState()
            ))
            .tabItem {
                Label("Bookshelf", systemImage: "books.vertical")
            }
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: .magnifyingglass)
                }
            Text("Profile/ Settings")
                .tabItem {
                    Label("Profile", systemImage: .personCropCircle)
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
