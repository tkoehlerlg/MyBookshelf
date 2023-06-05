//
//  Color+hex.swift
//  
//
//  Created by Torben Köhler on 05.06.23.
//

import SwiftUIX

public extension Color {
    static func hex(_ colorCode: String) -> Self {
        .init(hexadecimal: colorCode)
    }
}
