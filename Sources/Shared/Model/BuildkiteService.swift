//
//  BuildkiteService.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import Foundation
import Combine
import Buildkite

class BuildkiteService: ObservableObject {
    let client: BuildkiteClient = {
        $0.token = Env.buildkiteToken
        return $0
    }(BuildkiteClient())

    enum Error: Swift.Error {
        case paginationFailure
    }

    @Published private(set) var organization: String = Env.organization
}

extension BuildkiteService {
    func send<R>(resource: R) async throws -> R.Content where R: Resource, R.Content == Void {
        let response = try await client.send(resource)
        return response.content
    }

    func send<R>(resource: R) async throws -> R.Content where R: Resource, R.Content: Decodable {
        let response = try await client.send(resource)
        return response.content
    }

    func send<R>(resource: R) async throws -> R.Content where R: Resource, R.Body: Encodable, R.Content: Decodable {
        let response = try await client.send(resource)
        return response.content
    }

    func singlePage<R>(resource: R, page: PageOptions) async throws -> R.Content where R: PaginatedResource {
        let response = try await client.send(resource, pageOptions: page)
        return response.content
    }

    func allPages<R>(resource: R, perPage: Int) async throws -> [R.Content] where R: PaginatedResource {
        let response = try await client.send(resource, pageOptions: PageOptions(page: 1, perPage: perPage))

        guard let page = response.page,
              let firstPage = page.firstPage,
              let nextPage = page.nextPage,
              let lastPage = page.lastPage else {
                  throw Error.paginationFailure
              }

        let length = lastPage - firstPage
        var pages: [R.Content] = []
        pages.reserveCapacity(length)
        pages.insert(response.content, at: firstPage)

        try await withThrowingTaskGroup(of: (Int, R.Content).self) { group in
            for i in nextPage...lastPage {
                group.addTask {
                    let response = try await self.client.send(resource, pageOptions: PageOptions(page: i, perPage: perPage))
                    return (i, response.content)
                }
            }

            for try await (i, content) in group {
                pages.insert(content, at: i)
            }
        }

        return pages
    }

    func sendQuery<T: GraphQLQuery>(_ query: T) async throws -> T.Response {
        return try await client.sendQuery(GraphQL<T.Response>(rawQuery: T.query, variables: query.variables))
    }
}
