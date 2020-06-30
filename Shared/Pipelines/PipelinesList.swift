//
//  PipelinesList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct PipelinesList: View {
    typealias Pipeline = PipelinesListQuery.Response.Organization.Pipeline
    
    @EnvironmentObject var service: BuildkiteService
    
    @State var pipelines: [Pipeline] = []
    @State private var selection: Pipeline?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(pipelines) { pipeline in
                NavigationLink(destination: EmptyView()) {
                    PipelineRow(pipeline: pipeline)
                }
            }
        }
        .onAppear(perform: loadPipelines)
            .navigationTitle("Pipelines")
    }
    
    func loadPipelines() {
        let resource = PipelinesListQuery(organizationSlug: service.organization, perPage: 10).resource
        service
            .sendPublisher(resource: resource)
            .tryMap { try $0.get() }
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.pipelines = $0.organization.pipelines.nodes })
    }
}

struct PipelinesList_Previews: PreviewProvider {
    static var previews: some View {
        PipelinesList()
    }
}
