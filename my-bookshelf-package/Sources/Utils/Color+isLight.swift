import UIKit
import SwiftUI

// https://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright
public extension UIColor {
    /// A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.7) -> Bool? {
        let originalCGColor = self.cgColor

        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}

public extension Color {
    func isLight(threshold: Float = 0.7) -> Bool? {
        return UIColor(self).isLight(threshold: threshold)
    }
}
