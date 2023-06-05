//
//  MyBookshelfApp.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 20.05.23.
//

import SwiftUI

@main
struct MyBookshelfApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
