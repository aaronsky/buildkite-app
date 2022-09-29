import Buildkite
import Foundation

extension Agent {
    public var isRunningJob: Bool {
        guard let job = job else { return false }
        let isRunning: (String?) -> Bool = { $0 == "running" }

        switch job {
        case .script(let command):
            return isRunning(command.state)
        case .waiter(_):
            return false
        case .manual(let block):
            return isRunning(block.state)
        case .trigger(let trigger):
            return isRunning(trigger.state)
        }
    }
}
