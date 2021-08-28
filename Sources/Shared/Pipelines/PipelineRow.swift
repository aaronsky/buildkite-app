//
//  PipelineRow.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import SwiftUI
import Buildkite

struct PipelineRow: View {
    @EnvironmentObject var service: BuildkiteService

    var pipeline: PipelinesListQuery.Response.Pipeline

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                BuildState(state: (pipeline.builds.nodes.first?.state ?? PipelinesListQuery.Response.Build.State.notRun).rawValue)
                Text(pipeline.name)
            }
            BuildsGraph(builds: pipeline.builds.nodes)
        }
        .frame(height: 80)
    }
}

private struct BuildsGraph: View {
    var builds: [PipelinesListQuery.Response.Build]

    let minBarHeight: CGFloat = 5
    let maxBarHeight: CGFloat = 25
    var empties: [EmptyIdentifiable] {
        Array(repeating: .init(), count: max(30 - builds.count, 0))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(empties) { _ in
                Rectangle()
                    .frame(width: 5, height: minBarHeight)
                    .foregroundColor(BuildState.Colors.color(for: ""))
            }
            ForEach(builds.prefix(30).reversed()) { build in
                Rectangle()
                    .frame(width: 5, height: maxBarHeight)
                    .foregroundColor(BuildState.Colors.color(for: build.state.rawValue))
            }
            Spacer()
        }
        .frame(height: maxBarHeight)
    }
}

struct PipelineRow_Previews: PreviewProvider {
    static var query = try! GraphQL<PipelinesListQuery.Response>.Content(assetNamed: "gql.PipelinesList").get()

    static var previews: some View {
        PipelineRow(pipeline: query.organization.pipelines.nodes.first!)
            .environmentObject(BuildkiteService())
    }
}
