//
//  PipelinesList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct PipelinesList: View {
    @EnvironmentObject var service: BuildkiteService
    
    @State var pipelines: [PipelinesListQuery.Response.Pipeline] = []
    @State private var selection: PipelinesListQuery.Response.Pipeline?
    @State var searchQuery: String = ""
    
    var body: some View {
        List(selection: $selection) {
            if pipelines.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(pipelines) { pipeline in
                    NavigationLink(destination: PipelineView(pipeline: pipeline)) {
                        PipelineRow(pipeline: pipeline)
                    }
                }
            }
        }
        .listStyle(InsetListStyle())
        .task {
            await loadPipelines()
        }
        .navigationTitle("Pipelines")
    }

    func loadPipelines() async {
        let query = PipelinesListQuery(organization: service.organization,
                                       pipelinesCount: 50,
                                       pipelinesSearch: searchQuery,
                                       buildsCount: 50)
        guard let response = try? await service.sendQuery(query),
              let data = try? response.get() else {
                  return
              }
        self.pipelines = data.organization.pipelines.nodes
    }
}

struct PipelinesList_Previews: PreviewProvider {
    static var query = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList").get()
    
    static var previews: some View {
        PipelinesList(pipelines: query.organization.pipelines.nodes)
            .environmentObject(BuildkiteService())
    }
}
