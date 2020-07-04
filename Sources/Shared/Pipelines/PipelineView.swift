//
//  PipelineView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/30/20.
//

import SwiftUI
import Buildkite

struct PipelineView: View {
    @EnvironmentObject var service: BuildkiteService
    
    var pipeline: PipelinesListQuery.Response.Pipeline
    
    var body: some View {
        VStack {
            HStack {
                Text(pipeline.name)
                switch pipeline.visibility {
                case .public:
                    Image(systemName: "eye")
                case .private:
                    Image(systemName: "lock.fill")
                }
            }
            List {
                let builds = pipeline.builds.nodes
                if builds.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(builds) { build in
                        NavigationLink(destination: BuildView(inputs: .init(pipelineSlug: pipeline.slug, buildNumber: build.number))) {
                            Text("\(build.number)")
                        }
                    }
                }
            }
        }
    }
}

struct PipelineView_Previews: PreviewProvider {
    static var query = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList").get()
    
    static var previews: some View {
        PipelineView(pipeline: query.organization.pipelines.nodes.first!)
            .environmentObject(BuildkiteService())
    }
}
