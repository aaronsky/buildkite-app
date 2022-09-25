import Buildkite
import Foundation

public protocol Query {
    associatedtype Response: Decodable

    static var query: String { get }
    var variables: [String: JSONValue] { get }
}
