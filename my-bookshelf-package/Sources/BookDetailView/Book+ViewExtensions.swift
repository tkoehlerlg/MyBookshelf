//
//  File.swift
//  
//
//  Created by Torben Köhler on 26.05.23.
//

import BookFinder
import SwiftUI

public extension Book {
    func coverBackgroundColor(cover: UIImage?, colorScheme: ColorScheme) -> Color {
        if let averageColor = cover?.averageColor {
            guard colorScheme == .light else {
                return Color(uiColor: averageColor.darker())
            }
            return Color(uiColor: averageColor.darker(by: 70))
        } else {
            return .secondarySystemBackground
        }
    }
    func tintColor(cover: UIImage?, bookHasCover: Bool, colorScheme: ColorScheme) -> Color {
        guard let isLight = coverBackgroundColor(cover: cover, colorScheme: colorScheme).isLight(),
              bookHasCover else {
            return .primary
        }
        return isLight ? .black : .white
    }
    func secondaryTintColor(cover: UIImage?, bookHasCover: Bool, colorScheme: ColorScheme) -> Color {
        guard let isLight = coverBackgroundColor(cover: cover, colorScheme: colorScheme).isLight(),
              bookHasCover else {
            return .secondary
        }
        return isLight ? .black.lighter(by: 5) : .white.darker(by: 5)
    }
}
