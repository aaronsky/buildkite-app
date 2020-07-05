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
        var command: Job.Command
        
        var body: some View {
            HStack {
                EmojiLabel(command.name ?? "")
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
            EmojiLabel(block.label)
        }
    }
    
    struct TriggerLayout: View {
        var trigger: Job.Trigger
        
        var body: some View {
            EmojiLabel(trigger.name ?? "")
        }
    }
}

struct JobView_Previews: PreviewProvider {
    static var build = Build(assetNamed: "v2.build")
    
    static var previews: some View {
        VStack {
            ForEach(build.jobs) { job in
                JobView(job: job)
            }
        }
        .environmentObject(Emojis())
    }
}
