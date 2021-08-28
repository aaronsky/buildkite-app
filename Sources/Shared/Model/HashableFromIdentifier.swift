//
//  HashableFromIdentifier.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import Foundation

protocol HashableFromIdentifier: Hashable, Identifiable {}

extension HashableFromIdentifier {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EmptyIdentifiable: Identifiable {
    var id: UUID

    init() {
        self.id = .init()
    }
}
