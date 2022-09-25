import Foundation

public protocol GraphQLClient {
    func sendQuery<Q: Query>(_ query: Q) async throws -> Q.Response
}
