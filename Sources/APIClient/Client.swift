import Buildkite
import Foundation
import GraphQLHelpers

public struct APIClient {
    public var setToken: @Sendable (String) async -> Void
    public var graphQLClient: @Sendable () throws -> GraphQLClient
    // Access Tokens
    public var getAccessToken: @Sendable () async throws -> AccessToken
    public var revokeAccessToken: @Sendable () async throws -> Void
    // Agents
    public var listAgents: @Sendable (_ organization: String) async throws -> [Agent]
    public var getAgent: @Sendable (_ id: UUID, _ organization: String) async throws -> Agent
    public var stopAgent: @Sendable (_ id: UUID, _ organization: String, _ force: Bool) async throws -> Void
    // Pipelines
    public var listPipelines: @Sendable (_ organization: String) async throws -> [Pipeline]
    public var getPipeline: @Sendable (_ pipeline: String, _ organization: String) async throws -> Pipeline
    // Builds
    public var listAllBuilds: @Sendable (_ options: Build.Resources.QueryOptions?) async throws -> [Build]
    public var listBuildsForOrganization:
        @Sendable (_ organization: String, _ options: Build.Resources.QueryOptions?) async throws -> [Build]
    public var listBuildsForPipeline:
        @Sendable (_ pipeline: String, _ organization: String, _ options: Build.Resources.QueryOptions?) async throws ->
            [Build]
    public var getBuild: @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws -> Build
    public var rebuildBuild: @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws -> Build
    public var cancelBuild: @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws -> Build
    // Jobs
    public var retryJob:
        @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int) async throws -> Job
    public var unblockJob:
        @Sendable (
            _ job: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ input: Job.Resources.Unblock.Body
        ) async throws -> Job
    public var getJobLogOutput:
        @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int) async throws -> Job.LogOutput
    // Annotations
    public var listAnnotations:
        @Sendable (_ organization: String, _ pipeline: String, _ build: Int) async throws -> [Annotation]
    // Artifacts
    public var listArtifactsByBuild:
        @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws -> [Artifact]
    public var listArtifactsByJob:
        @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int) async throws -> [Artifact]
    public var getArtifact:
        @Sendable (_ id: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ job: UUID) async throws ->
            Artifact
    public var downloadArtifact:
        @Sendable (_ id: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ job: UUID) async throws ->
            Artifact.URLs
    // Organizations
    public var listOrganizations: @Sendable () async throws -> [Organization]
    public var getOrganization: @Sendable (_ organization: String) async throws -> Organization
    // Teams
    public var listTeams: @Sendable (_ organization: String) async throws -> [Team]
    // User
    public var me: @Sendable () async throws -> User
    public var listEmojis: @Sendable (_ organization: String) async throws -> [Emoji]

    public init(
        setToken: @escaping @Sendable (String) async -> Void,
        graphQLClient: @escaping @Sendable () throws -> GraphQLClient,
        // Access Tokens
        getAccessToken: @escaping @Sendable () async throws -> AccessToken,
        revokeAccessToken: @escaping @Sendable () async throws -> Void,
        // Agents
        listAgents: @escaping @Sendable (_ organization: String) async throws -> [Agent],
        getAgent: @escaping @Sendable (_ id: UUID, _ organization: String) async throws -> Agent,
        stopAgent: @escaping @Sendable (_ id: UUID, _ organization: String, _ force: Bool) async throws -> Void,
        // Pipelines
        listPipelines: @escaping @Sendable (_ organization: String) async throws -> [Pipeline],
        getPipeline: @escaping @Sendable (_ pipeline: String, _ organization: String) async throws -> Pipeline,
        // Builds
        listAllBuilds: @escaping @Sendable (_ options: Build.Resources.QueryOptions?) async throws -> [Build],
        listBuildsForOrganization: @escaping @Sendable (
            _ organization: String, _ options: Build.Resources.QueryOptions?
        ) async throws -> [Build],
        listBuildsForPipeline: @escaping @Sendable (
            _ pipeline: String, _ organization: String, _ options: Build.Resources.QueryOptions?
        ) async throws -> [Build],
        getBuild: @escaping @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws -> Build,
        rebuildBuild: @escaping @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws ->
            Build,
        cancelBuild: @escaping @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async throws ->
            Build,
        // Jobs
        retryJob: @escaping @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int) async
            throws -> Job,
        unblockJob: @escaping @Sendable (
            _ job: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ input: Job.Resources.Unblock.Body
        ) async throws -> Job,
        getJobLogOutput: @escaping @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int)
            async throws -> Job.LogOutput,
        // Annotations
        listAnnotations: @escaping @Sendable (_ organization: String, _ pipeline: String, _ build: Int) async throws ->
            [Annotation],
        // Artifacts
        listArtifactsByBuild: @escaping @Sendable (_ build: Int, _ organization: String, _ pipeline: String) async
            throws -> [Artifact],
        listArtifactsByJob: @escaping @Sendable (_ job: UUID, _ organization: String, _ pipeline: String, _ build: Int)
            async throws -> [Artifact],
        getArtifact: @escaping @Sendable (
            _ id: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ job: UUID
        ) async throws -> Artifact,
        downloadArtifact: @escaping @Sendable (
            _ id: UUID, _ organization: String, _ pipeline: String, _ build: Int, _ job: UUID
        ) async throws -> Artifact.URLs,
        // Organizations
        listOrganizations: @escaping @Sendable () async throws -> [Organization],
        getOrganization: @escaping @Sendable (_ organization: String) async throws -> Organization,
        // Teams
        listTeams: @escaping @Sendable (_ organization: String) async throws -> [Team],
        // User
        me: @escaping @Sendable () async throws -> User,
        listEmojis: @escaping @Sendable (_ organization: String) async throws -> [Emoji]
    ) {
        self.setToken = setToken
        self.graphQLClient = graphQLClient
        // Access Tokens
        self.getAccessToken = getAccessToken
        self.revokeAccessToken = revokeAccessToken
        // Agents
        self.listAgents = listAgents
        self.getAgent = getAgent
        self.stopAgent = stopAgent
        // Pipelines
        self.listPipelines = listPipelines
        self.getPipeline = getPipeline
        // Builds
        self.listAllBuilds = listAllBuilds
        self.listBuildsForOrganization = listBuildsForOrganization
        self.listBuildsForPipeline = listBuildsForPipeline
        self.getBuild = getBuild
        self.rebuildBuild = rebuildBuild
        self.cancelBuild = cancelBuild
        // Jobs
        self.retryJob = retryJob
        self.unblockJob = unblockJob
        self.getJobLogOutput = getJobLogOutput
        // Annotations
        self.listAnnotations = listAnnotations
        // Artifacts
        self.listArtifactsByBuild = listArtifactsByBuild
        self.listArtifactsByJob = listArtifactsByJob
        self.getArtifact = getArtifact
        self.downloadArtifact = downloadArtifact
        // Organizations
        self.listOrganizations = listOrganizations
        self.getOrganization = getOrganization
        // Teams
        self.listTeams = listTeams
        // User
        self.me = me
        self.listEmojis = listEmojis
    }
}
