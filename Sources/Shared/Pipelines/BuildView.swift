//
//  BuildView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/30/20.
//

import SwiftUI
import Buildkite

struct BuildView: View {
    @EnvironmentObject var service: BuildkiteService
    
    @State var build: Build?
    
    var pipelineSlug: String
    var buildNumber: Int
    
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
        .task {
            await loadBuild()
        }
    }
    
    func loadBuild() async {
        let resource = Build.Resources.Get(organization: service.organization,
                                        pipeline: pipelineSlug,
                                        build: buildNumber)
        self.build = try? await service.send(resource: resource)
    }
}

struct BuildView_Previews: PreviewProvider {
    static var build = Build(assetNamed: "v2.build")
    
    static var previews: some View {
        BuildView(build: build,
                  pipelineSlug: "",
                  buildNumber: 0)
            .environmentObject(BuildkiteService())
            .environmentObject(Emojis())
    }
}
