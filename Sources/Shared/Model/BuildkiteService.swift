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
    let client: BuildkiteClient<URLSession> = {
        $0.token = Env.buildkiteToken
        return $0
    }(BuildkiteClient())
    
    enum Error: Swift.Error {
        case paginationFailure
    }
    
    @Published private(set) var organization: String = "wayfair"
}

extension BuildkiteService {
    func send<R: Resource>(resource: R) async throws -> R.Content where R.Content == Void {
        let response = try await client.send(resource)
        return response.content
    }
    
    func send<R: Resource>(resource: R) async throws -> R.Content where R: HasResponseBody {
        let response = try await client.send(resource)
        return response.content
    }
    
    func send<R: Resource>(resource: R) async throws -> R.Content where R: HasResponseBody & HasRequestBody {
        let response = try await client.send(resource)
        return response.content
    }
    
    func singlePage<R: Resource>(resource: R, page: PageOptions) async throws -> R.Content where R: Paginated {
        let response = try await client.send(resource, pageOptions: page)
        return response.content
    }
    
    func allPages<R: Resource>(resource: R, perPage: Int) async throws -> [R.Content] where R: Paginated {
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

    func followURL<T: Decodable>(_ url: URL) async throws -> T {
        return try await send(resource: AnyResource(url))
    }
    
    func sendQuery<T: GraphQLQuery>(_ query: T) async throws -> GraphQL<T.Response>.Content {
        return try await send(resource: GraphQL<T.Response>(rawQuery: T.query, variables: query.variables))
    }
}

private struct AnyResource<T: Decodable>: Resource, HasResponseBody {
    typealias Content = T
    let path = ""
    
    var url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func transformRequest(_ request: inout URLRequest) {
        request.url = self.url
    }
}
