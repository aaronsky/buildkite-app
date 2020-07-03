//
//  JobView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/30/20.
//

import SwiftUI
import Buildkite

struct JobView: View {
    var job: Job
    
    @ViewBuilder var body: some View {
        switch job {
        case let .script(command):
            CommandLayout(command: command)
        case let .waiter(wait):
            WaitLayout(wait: wait)
        case let .manual(block):
            BlockLayout(block: block)
        case let .trigger(trigger):
            TriggerLayout(trigger: trigger)
        }
    }
    
    struct CommandLayout: View {
        @EnvironmentObject var emojis: Emojis
        
        var command: Job.Command
        
        var body: some View {
            HStack {
                Text(command.name?.replacingEmojis(using: emojis) ?? "")
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
        @EnvironmentObject var emojis: Emojis
        
        var block: Job.Block
        
        var body: some View {
            Text(block.label.replacingEmojis(using: emojis))
        }
    }
    
    struct TriggerLayout: View {
        @EnvironmentObject var emojis: Emojis
        
        var trigger: Job.Trigger
        
        var body: some View {
            Text(trigger.name?.replacingEmojis(using: emojis) ?? "")
        }
    }
}

//struct JobView_Previews: PreviewProvider {
//    static var previews: some View {
//        JobView()
//    }
//}
