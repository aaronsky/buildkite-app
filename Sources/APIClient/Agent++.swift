import Buildkite
import Foundation

extension Agent {
    public var nameFormatted: String {
        // head
        // last bit of the tail
        // dev or prod

        let components = name.split(separator: Character("."))

        guard
            let head = components.first,
            let tail = components.last?.split(separator: "-").last
        else {
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

    public var isRunningJob: Bool {
        guard let job = job else { return false }

        switch job {
        case .script(let command):
            return command.state == "running"
        case .waiter(_):
            return false
        case .manual(let block):
            return block.state == "running"
        case .trigger(let trigger):
            return trigger.state == "running"
        }
    }
}
