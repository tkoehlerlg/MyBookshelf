//
//  File.swift
//  
//
//  Created by Torben Köhler on 06.06.23.
//

import SwiftUI

struct TopLeftCircleBackButton: ViewModifier {
    var onTap: () -> Void
    var backgroundColor: Color
    var tintColor: Color
    var topSafeAreaInset: CGFloat

    init(
        backgroundColor: Color,
        tintColor: Color,
        topSafeAreaInset: CGFloat = 0.0,
        onTap: @escaping () -> Void
    ) {
        self.onTap = onTap
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.topSafeAreaInset = topSafeAreaInset
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            Button(action: onTap) {
                Image(systemName: .chevronLeft)
                    .tint(tintColor)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .frame(width: 40, height: 40)
                    .background(backgroundColor)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .safeAreaInset(.top, topSafeAreaInset)
            .padding(.top, 10)
            .padding(.leading, 15)
            .ignoresSafeArea(.keyboard)
        }
    }
}

extension View {
    func topLeftCircleBackButton(
        backgroundColor: Color,
        tintColor: Color,
        topSafeAreaInset: Double = 0.0,
        onTap: @escaping () -> Void
    ) -> some View {
        modifier(TopLeftCircleBackButton(
            backgroundColor: backgroundColor,
            tintColor: tintColor,
            topSafeAreaInset: topSafeAreaInset,
            onTap: onTap
        ))
    }
}


struct TopLeftCircleBackButton_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, world!")
            .topLeftCircleBackButton(backgroundColor: .black, tintColor: .white) {
                print("Tapped")
            }
    }
}
