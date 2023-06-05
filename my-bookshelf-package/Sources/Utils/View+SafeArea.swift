import SwiftUI

extension View {
    public func safeAreaInset(_ edge: Edge, _ size: Double) -> some View {
        self.modifier(CustomSafeAreaInset(edge, size))
    }

    public func safeAreaInset(_ edges: [Edge], _ size: Double) -> some View {
        var view = self
        edges.forEach { view = view.safeAreaInset($0, size) as! Self }
        return view
    }
}

struct CustomSafeAreaInset: ViewModifier {
    var edge: Edge, size: Double

    init(_ edge: Edge, _ size: Double) {
        self.edge = edge
        self.size = size
    }

    func body(content: Content) -> some View {
        switch edge {
        case .top:
            content.safeAreaInset(edge: .top, content: { FixedVSpacer(height: size) })
        case .leading:
            content.safeAreaInset(edge: .leading, content: { FixedHSpacer(width: size) })
        case .bottom:
            content.safeAreaInset(edge: .bottom, content: { FixedVSpacer(height: size) })
        case .trailing:
            content.safeAreaInset(edge: .trailing, content: { FixedHSpacer(width: size) })
        }
    }
}

struct CustomSafeAreaInset_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, world!")
            .modifier(CustomSafeAreaInset(.bottom, 20))
    }
}
