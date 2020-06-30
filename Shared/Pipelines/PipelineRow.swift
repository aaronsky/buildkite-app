//
//  PipelineRow.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import SwiftUI
import Buildkite

struct PipelineRow: View {
    var pipeline: PipelinesList.Pipeline
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                BuildState(state: (pipeline.builds.nodes.first?.state ?? PipelinesList.Pipeline.Build.State.notRun).rawValue)
                Text(pipeline.name)
            }
            BuildsGraph(builds: pipeline.builds.nodes)
        }
        .frame(height: 100)
    }
}

private struct BuildsGraph: View {
    var builds: [PipelinesList.Pipeline.Build]
    
    let minBarHeight: CGFloat = 5
    let maxBarHeight: CGFloat = 25
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<(30 - builds.count)) { _ in
                Rectangle()
                    .frame(width: 5, height: minBarHeight)
                    .foregroundColor(BuildState.Colors.color(for: ""))
            }
            ForEach(builds) { build in
                Rectangle()
                    .frame(width: 5, height: (maxBarHeight))
                    .foregroundColor(BuildState.Colors.color(for: build.state.rawValue))
            }
            Spacer()
        }.frame(height: maxBarHeight)
    }
}

struct PipelineRow_Previews: PreviewProvider {
    static let pipelines = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList")!.get()
    
    static var previews: some View {
        PipelineRow(pipeline: pipelines.organization.pipelines.nodes[0])
    }
}
