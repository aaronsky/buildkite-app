//
//  Job+Extensions.swift
//  Shared
//
//  Created by Aaron Sky on 6/30/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

extension Job: HashableFromIdentifier {
    public var id: UUID {
        switch self {
        case let .script(job):
            return job.id
        case let .waiter(job):
            return job.id
        case let .manual(job):
            return job.id
        case let .trigger(job):
            return job.id
        }
    }
}
extension Job.Command: HashableFromIdentifier {}
extension Job.Wait: HashableFromIdentifier {}
extension Job.Block: HashableFromIdentifier {}
extension Job.Trigger: HashableFromIdentifier {
    public var id: UUID {
        self.triggeredBuild?.id ?? UUID()
    }
}

