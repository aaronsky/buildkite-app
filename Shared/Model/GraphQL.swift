//
//  GraphQL.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct Connection<T: Decodable>: Decodable {
    var edges: [Edge]
    var pageInfo: PageInfo?
    
    var nodes: [T] {
        edges.map(\.node)
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

protocol HashableFromIdentifier: Hashable, Identifiable {}
extension HashableFromIdentifier {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum Fragments {}
