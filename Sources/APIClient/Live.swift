import Buildkite
import GraphQLHelpers

extension APIClient {
    public static var live: Self {
        let tokens = Tokens()
        let client = BuildkiteClient(tokens: tokens)
        return Self(
            setToken: { await tokens.setToken($0) },
            graphQLClient: { client },
            // Access Tokens
            getAccessToken: { try await client.send(.getAccessToken).content },
            revokeAccessToken: { try await client.send(.revokeAccessToken).content },
            // Agents
            listAgents: { try await client.send(.agents(in: $0)).content },
            getAgent: { try await client.send(.agent($0, in: $1)).content },
            stopAgent: { try await client.send(.stopAgent($0, in: $1, force: $2)).content },
            // Pipelines
            listPipelines: { try await client.send(.pipelines(in: $0)).content },
            getPipeline: { try await client.send(.pipeline($0, in: $1)).content },
            // Builds
            listAllBuilds: { try await client.send(.builds(options: $0)).content },
            listBuildsForOrganization: { try await client.send(.builds(inOrganization: $0, options: $1)).content },
            listBuildsForPipeline: { try await client.send(.builds(forPipeline: $0, in: $1, options: $2)).content },
            getBuild: { try await client.send(.build($0, in: $1, pipeline: $2)).content },
            rebuildBuild: { try await client.send(.rebuild($0, in: $1, pipeline: $2)).content },
            cancelBuild: { try await client.send(.cancelBuild($0, in: $1, pipeline: $2)).content },
            // Jobs
            retryJob: { try await client.send(.retryJob($0, in: $1, pipeline: $2, build: $3)).content },
            unblockJob: { try await client.send(.unblockJob($0, in: $1, pipeline: $2, build: $3, with: $4)).content },
            getJobLogOutput: { try await client.send(.logOutput(for: $0, in: $1, pipeline: $2, build: $3)).content },
            // Annotations
            listAnnotations: { try await client.send(.annotations(in: $0, pipeline: $1, build: $2)).content },
            // Artifacts
            listArtifactsByBuild: { try await client.send(.artifacts(byBuild: $0, in: $1, pipeline: $2)).content },
            listArtifactsByJob: {
                try await client.send(.artifacts(byJob: $0, in: $1, pipeline: $2, build: $3)).content
            },
            getArtifact: { try await client.send(.artifact($0, in: $1, pipeline: $2, build: $3, job: $4)).content },
            downloadArtifact: {
                try await client.send(.downloadArtifact($0, in: $1, pipeline: $2, build: $3, job: $4)).content
            },
            // Organizations
            listOrganizations: { try await client.send(.organizations).content },
            getOrganization: { try await client.send(.organization($0)).content },
            // Teams
            listTeams: { try await client.send(.teams(in: $0)).content },
            // User
            me: { try await client.send(.me).content },
            listEmojis: { try await client.send(.emojis(in: $0)).content }
        )
    }
}

extension BuildkiteClient: GraphQLClient {
    public func sendQuery<Q>(_ query: Q) async throws -> Q.Response where Q: Query {
        try await sendQuery(GraphQL(rawQuery: Q.query, variables: query.variables))
    }
}

actor Tokens: TokenProvider, Sendable {
    var token: String?

    func setToken(_ token: String?) {
        self.token = token
    }

    func token(for version: APIVersion) -> String? {
        token
    }
}
