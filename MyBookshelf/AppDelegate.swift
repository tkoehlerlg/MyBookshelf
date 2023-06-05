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
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(Color.white.opacity(0.8))
        itemAppearance.selected.iconColor = .white

        let standardAppearance = UITabBarAppearance()
        standardAppearance.stackedLayoutAppearance = itemAppearance
        standardAppearance.inlineLayoutAppearance = itemAppearance
        standardAppearance.compactInlineLayoutAppearance = itemAppearance
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(Color(hexadecimal: "B392AC"))
        standardAppearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = standardAppearance
        UITabBar.appearance().scrollEdgeAppearance = standardAppearance
    }
}
