import Foundation

public extension Author {
    static var mock = Self(
        key: "/authors/0",
        name: "Torben",
        personalName: "Torben Köhler",
        birthDate: ISO8601DateFormatter().date(from: "2003-08-02T00:00:00+02:00"),
        bio: "Torben would love to go to the CODE!"
    )
}
