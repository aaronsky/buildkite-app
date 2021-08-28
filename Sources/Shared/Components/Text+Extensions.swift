//
//  Text+Extensions.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/5/20.
//

import SwiftUI

extension Array where Element == Text {
    func joined(separator: Text) -> Text {
        var result = Text("")
        var iter = makeIterator()
        if let first = iter.next() {
            result = result + first
            while let next = iter.next() {
                result = result + separator
                result = result + next
            }
        }
        return result
    }

    func joined<S: StringProtocol>(separator: S) -> Text {
        joined(separator: Text(separator))
    }
}
