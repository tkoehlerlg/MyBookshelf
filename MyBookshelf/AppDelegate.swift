//
//  AppDelegate.swift
//  MyBookshelf
//
//  Created by Torben Köhler on 25.05.23.
//

import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureTabBar()
        return true
    }

    private func configureTabBar() {
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(Color.systemGray6)
        standardAppearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = standardAppearance
        UITabBar.appearance().scrollEdgeAppearance = standardAppearance
    }
}
