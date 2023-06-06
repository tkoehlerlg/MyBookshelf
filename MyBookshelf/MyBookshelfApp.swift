//
//  MyBookshelfApp.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 20.05.23.
//

import SwiftUI
import ComposableArchitecture

@main
struct MyBookshelfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var store: StoreOf<AppState>

    init() {
        _store = State(
            initialValue: .init(
                initialState: AppState.State(),
                reducer: AppState()
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
