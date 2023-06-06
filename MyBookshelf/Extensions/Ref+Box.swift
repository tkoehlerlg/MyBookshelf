import Foundation

// This is for optimizing the App Performance for large Swift Components
// swiftlint:disable:next line_length
// https://github.com/apple/swift/blob/main/docs/OptimizationTips.rst#advice-use-copy-on-write-semantics-for-large-values


final class Ref<T>: Equatable where T: Equatable {
    static func == (lhs: Ref<T>, rhs: Ref<T>) -> Bool {
        lhs.val == rhs.val
    }
    var val: T
    init(_ v: T) { val = v }
}

struct Box<T>: Equatable where T: Equatable {
    var ref: Ref<T>
    init(_ x: T) { ref = Ref(x) }

    var value: T {
        get { return ref.val }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
                return
            }
            ref.val = newValue
        }
    }
}
