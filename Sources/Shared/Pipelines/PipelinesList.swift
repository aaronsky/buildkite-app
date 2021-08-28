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

    @State var isLoading: Bool = false
    @State var pipelines: [PipelinesListQuery.Response.Pipeline] = []
    @State private var selection: PipelinesListQuery.Response.Pipeline?
    @State var searchQuery: String = ""

    var body: some View {
        List(selection: $selection) {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if pipelines.isEmpty {
                Text("No pipelines found")
                    .italic()
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
        .refreshable {
            await loadPipelines()
        }
        .navigationTitle("Pipelines")
    }

    func loadPipelines() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let data = try await service.sendQuery(PipelinesListQuery(organization: service.organization,
                                                                      pipelinesCount: 50,
                                                                      pipelinesSearch: searchQuery,
                                                                      buildsCount: 50))
            self.pipelines = data.organization.pipelines.nodes
        } catch {
            print(error)
        }
    }
}

struct PipelinesList_Previews: PreviewProvider {
    static var query = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList").get()

    static var previews: some View {
        PipelinesList(pipelines: query.organization.pipelines.nodes)
            .environmentObject(BuildkiteService())
    }
}
