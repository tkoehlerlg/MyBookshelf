import SwiftUI

public struct FixedSpacer: View {
    var height: Double
    var width: Double

    public init(height: Double, width: Double) {
        self.height = height
        self.width = width
    }

    public var body: some View {
        Spacer().frame(width: width, height: height)
    }
}

public struct FixedHSpacer: View {
    var width: Double

    public init(_ width: Double) {
        self.width = width
    }

    public init(width: Double) {
        self.width = width
    }

    public var body: some View {
        FixedSpacer(height: 0, width: width)
    }
}

public struct FixedVSpacer: View {
    var height: Double

    public init(_ height: Double) {
        self.height = height
    }

    public init(height: Double) {
        self.height = height
    }

    public var body: some View {
        FixedSpacer(height: height, width: 0)
    }
}
