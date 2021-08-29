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

    @State var isLoading: Bool = false
    @State var build: Build?

    var pipelineSlug: String
    var buildNumber: Int

    var body: some View {
        ScrollView {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if let build = build {
                LazyVStack {
                    ForEach(build.jobs) { job in
                        JobView(job: job)
                    }
                }
            } else {
                Text("\(service.organization)/\(pipelineSlug) #\(buildNumber) could be loaded")
                    .italic()
            }
        }
        .task {
            await loadBuild()
        }
        .refreshable {
            await loadBuild()
        }
    }

    func loadBuild() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.build = try await service.send(resource: .build(buildNumber, in: service.organization, pipeline: pipelineSlug))
        } catch {
            print(error)
        }
    }
}

struct BuildView_Previews: PreviewProvider {
    static var build = Build(assetNamed: "v2.build")

    static var previews: some View {
        BuildView(build: build,
                  pipelineSlug: "",
                  buildNumber: 0)
            .environmentObject(BuildkiteService())
    }
}
