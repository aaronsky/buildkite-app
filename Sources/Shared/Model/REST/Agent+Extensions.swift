//
//  Agent+Extensions.swift
//  Shared
//
//  Created by Aaron Sky on 5/16/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

extension Agent: HashableFromIdentifier {}

extension Agent {
    var nameFormatted: String {
        // head
        // last bit of the tail
        // dev or prod

        let components = name.split(separator: Character("."))

        guard let head = components.first,
              let tail = components.last?.split(separator: "-").last else {
                  return ""
              }

        let env: String
        if components.contains(where: { $0.contains("dev") }) {
            env = ".dev"
        } else if components.contains(where: { $0.contains("prod") }) {
            env = ".prod"
        } else {
            env = ""
        }

        return "\(head)\(env)-\(tail)"
    }

    var isRunningJob: Bool {
        guard let job = job else {
            return false
        }
        switch job {
        case let .script(command):
            return command.state == "running"
        case .waiter(_):
            return false
        case let .manual(block):
            return block.state == "running"
        case let .trigger(trigger):
            return trigger.state == "running"
        }
    }
}
