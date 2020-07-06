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
                EmojiLabel(pipeline.name)
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
                        NavigationLink(destination: BuildView(pipelineSlug: pipeline.slug, buildNumber: build.number)) {
                            HStack {
                                BuildState(state: build.state.rawValue)
                                VStack(alignment: .leading) {
                                    EmojiLabel(build.message ?? "")
                                        .font(.body)
                                    caption(for: build)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    func caption(for build: PipelinesListQuery.Response.Build) -> Text {
        var chunks: [Text] = []
        if let createdByName = build.createdBy?.name {
            chunks.append(Text(createdByName))
        }
        chunks.append(Text("Build #\(build.number)"))
        chunks.append(Text(build.commit.prefix(7)))
        if let createdAt = build.createdAt {
            chunks.append(Text("\(createdAt, formatter: Formatters.friendlyRelativeDateFormatter)"))
        }
        
        return chunks.joined(separator: " — ")
    }
}

struct PipelineView_Previews: PreviewProvider {
    static var query = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList").get()
    
    static var previews: some View {
        NavigationView {
            PipelineView(pipeline: query.organization.pipelines.nodes.first!)
        }
        .environmentObject(BuildkiteService())
        .environmentObject(Emojis())
    }
}
