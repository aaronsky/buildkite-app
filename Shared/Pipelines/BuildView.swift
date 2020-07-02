//
//  BuildView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/30/20.
//

import SwiftUI
import Buildkite

struct BuildView: View {
    struct Inputs {
        var pipelineSlug: String
        var buildNumber: Int
    }
    
    @EnvironmentObject var service: BuildkiteService
    
    @State var build: Build?
    
    var inputs: Inputs
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if let build = build {
                    ForEach(build.jobs) { job in
                        JobView(job: job)
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .onAppear(perform: loadBuild)
    }
    
    func loadBuild() {
        service
            .sendPublisher(resource: Build.Resources.Get(organization: service.organization, pipeline: inputs.pipelineSlug, build: inputs.buildNumber))
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { build = $0 })
    }
}

//struct BuildView_Previews: PreviewProvider {
//    static var previews: some View {
//        BuildView()
//    }
//}
