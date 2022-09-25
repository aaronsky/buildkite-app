import XCTestDynamicOverlay

extension APIClient {
    static let unimplemented = Self(
        setToken: XCTUnimplemented("\(Self.self).setToken"),
        graphQLClient: XCTUnimplemented("\(Self.self).graphQLClient"),
        getAccessToken: XCTUnimplemented("\(Self.self).getAccessToken"),
        revokeAccessToken: XCTUnimplemented("\(Self.self).revokeAccessToken"),
        listAgents: XCTUnimplemented("\(Self.self).listAgents"),
        getAgent: XCTUnimplemented("\(Self.self).getAgent"),
        stopAgent: XCTUnimplemented("\(Self.self).stopAgent"),
        listPipelines: XCTUnimplemented("\(Self.self).listPipelines"),
        getPipeline: XCTUnimplemented("\(Self.self).getPipeline"),
        listAllBuilds: XCTUnimplemented("\(Self.self).listAllBuilds"),
        listBuildsForOrganization: XCTUnimplemented("\(Self.self).listBuildsForOrganization"),
        listBuildsForPipeline: XCTUnimplemented("\(Self.self).listBuildsForPipeline"),
        getBuild: XCTUnimplemented("\(Self.self).getBuild"),
        rebuildBuild: XCTUnimplemented("\(Self.self).rebuildBuild"),
        cancelBuild: XCTUnimplemented("\(Self.self).cancelBuild"),
        retryJob: XCTUnimplemented("\(Self.self).retryJob"),
        unblockJob: XCTUnimplemented("\(Self.self).unblockJob"),
        getJobLogOutput: XCTUnimplemented("\(Self.self).getJobLogOutput"),
        listAnnotations: XCTUnimplemented("\(Self.self).listAnnotations"),
        listArtifactsByBuild: XCTUnimplemented("\(Self.self).listArtifactsByBuild"),
        listArtifactsByJob: XCTUnimplemented("\(Self.self).listArtifactsByJob"),
        getArtifact: XCTUnimplemented("\(Self.self).getArtifact"),
        downloadArtifact: XCTUnimplemented("\(Self.self).downloadArtifact"),
        listOrganizations: XCTUnimplemented("\(Self.self).listOrganizations"),
        getOrganization: XCTUnimplemented("\(Self.self).getOrganization"),
        listTeams: XCTUnimplemented("\(Self.self).listTeams"),
        me: XCTUnimplemented("\(Self.self).me"),
        listEmojis: XCTUnimplemented("\(Self.self).listEmojist")
    )
}
