import Buildkite
import SwiftUI

struct JobView: View {
    var job: Job

    var body: some View {
        switch job {
        case .script(let command):
            CommandLayout(command: command)
        case .waiter(let wait):
            WaitLayout(wait: wait)
        case .manual(let block):
            BlockLayout(block: block)
        case .trigger(let trigger):
            TriggerLayout(trigger: trigger)
        }
    }

    struct CommandLayout: View {
        var command: Job.Command

        var body: some View {
            HStack {
                Text(command.name ?? "")  // emojis
                if let agent = command.agent {
                    Text(agent.name)
                }
            }
        }
    }

    struct WaitLayout: View {
        var wait: Job.Wait

        var body: some View {
            Image(systemName: "chevron.down")
        }
    }

    struct BlockLayout: View {
        var block: Job.Block

        var body: some View {
            Text(block.label)  // emojis
        }
    }

    struct TriggerLayout: View {
        var trigger: Job.Trigger

        var body: some View {
            Text(trigger.name ?? "")  // emojis
        }
    }
}

extension Job: Identifiable {
    public var id: UUID {
        switch self {
        case .script(let job):
            return job.id
        case .waiter(let job):
            return job.id
        case .manual(let job):
            return job.id
        case .trigger(let job):
            // FIXME:
            return job.triggeredBuild?.id ?? UUID()
        }
    }
}

// FIXME: upstream public initializers
//struct JobView_Previews: PreviewProvider {
//    static var previews: some View {
//        JobView(job: .script(.init()))
//        JobView(job: .waiter(.init()))
//        JobView(job: .manual(.init()))
//        JobView(job: .trigger(.init()))
//    }
//}
