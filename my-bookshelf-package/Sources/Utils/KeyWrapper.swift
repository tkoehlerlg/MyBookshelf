public struct KeyWrapper<Value>: Decodable where Value: Decodable {
    private var key: Value
    public var value: Value { key }
}
