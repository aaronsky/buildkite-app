//
//  Connection.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import Foundation

struct Connection<T: Decodable>: Decodable {
    var count: Int?
    var edges: [Edge]?
    var pageInfo: PageInfo?
    
    var nodes: [T] {
        edges?.map(\.node) ?? []
    }
    
    struct Edge: Decodable {
        var node: T
        var cursor: String?
    }
    
    struct PageInfo: Decodable {
        /// When paginating forwards, the cursor to continue.
        var endCursor: String?
        /// When paginating forwards, are there more items?
        var hasNextPage: Bool
        /// When paginating backwards, are there more items?
        var hasPreviousPage: Bool
        /// When paginating backwards, the cursor to continue.
        var startCursor: String?
    }
    
    init(edges: [Connection<T>.Edge]) {
        self.edges = edges
    }
    
    init(nodes: [T]) {
        self.init(edges: nodes.map { Edge(node: $0, cursor: nil) })
    }
    
}

extension Connection: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: T...) {
        self.init(nodes: elements)
    }
}
