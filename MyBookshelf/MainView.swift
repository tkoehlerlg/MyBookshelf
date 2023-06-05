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
                initialState: HomeViewState.State(),
                reducer: HomeViewState()
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
