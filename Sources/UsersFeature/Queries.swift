import Buildkite
import Foundation
import GraphQLHelpers

public struct ListQuery: Query {
    public struct Response: Decodable, Equatable {
        public var organization: Organization

        public struct Organization: Decodable, Equatable {
            public var members: Connection<Member>

            public struct Member: Decodable, Equatable, Hashable, Identifiable, Sendable {
                public var id: String
                public var uuid: String
                public var role: Role
                public var user: Fragments.User

                public enum Role: String, Decodable, Equatable, Hashable, Sendable {
                    case member = "MEMBER"
                    case admin = "ADMIN"
                }

            }
        }
    }

    public static let query: String = """
        query UsersSearch($organization: ID!, $first: Int!, $search: String, $selector: TeamSelector) {
          organization(slug: $organization) {
            members(first: $first, search: $search, team: $selector) {
              count
              pageInfo {
                endCursor
                hasNextPage
                hasPreviousPage
                startCursor
              }
              edges {
                cursor
                node {
                  id
                  uuid
                  role
                  user {
                    id
                    uuid
                    name
                    email
                    avatar {
                      url
                    }
                    bot
                    hasPassword
                  }
                }
              }
            }
          }
        }
        """

    var organization: String
    var first = 50
    var search: String?
    var team: String?

    public var variables: [String: JSONValue] {
        [
            "organization": .string(organization),
            "first": .number(Double(first)),
            "search": search.map { .string($0) } ?? .null,
            "selector": team.map { .string($0) } ?? .null,
        ]
    }

    init(
        organization: String,
        first: Int = 50,
        usersMatching search: String? = nil,
        teamsMatching team: String? = nil
    ) {
        self.organization = organization
        self.first = first
        self.search = search
        self.team = team
    }
}

public struct GetQuery: Query {
    public struct Response: Decodable, Equatable, Sendable {
        public var organizationMember: OrganizationMember?

        public struct OrganizationMember: Decodable, Equatable, Hashable, Identifiable, Sendable {
            public var complimentary: Bool
            public var createdAt: Date
            public var createdBy: Fragments.User?
            public var id: String
            public var organization: Organization
            public var permissions: Permissions
            public var role: Role
            public var security: Security
            public var user: Fragments.User
            public var uuid: String

            public struct Permissions: Decodable, Equatable, Hashable, Sendable {
                public var organizationMemberDelete: Permission?
                public var organizationMemberUpdate: Permission?
            }

            public enum Role: String, Decodable, Equatable, Hashable, Sendable {
                case member = "MEMBER"
                case admin = "ADMIN"
            }

            public struct Security: Decodable, Equatable, Hashable, Sendable {
                public var passwordProtected: Bool
                public var twoFactorEnabled: Bool
            }
        }

        public struct Organization: Decodable, Equatable, Hashable, Identifiable, Sendable {
            public var iconUrl: URL?
            public var id: String
            public var isTeamsEnabled: Bool
            public var name: String
            public var permissions: Permissions
            public var `public`: Bool
            public var slug: String
            public var sso: SSO?
            public var uuid: String

            public struct Permissions: Decodable, Equatable, Hashable, Sendable {
                public var agentTokenCreate: Permission?
                public var agentTokenView: Permission?
                public var agentView: Permission?
                public var auditEventsView: Permission?
                public var notificationServiceUpdate: Permission?
                public var organizationBillingUpdate: Permission?
                public var organizationInvitationCreate: Permission?
                public var organizationMemberUpdate: Permission?
                public var organizationMemberView: Permission?
                public var organizationMemberViewSensitive: Permission?
                public var organizationUpdate: Permission?
                public var pipelineCreate: Permission?
                public var pipelineCreateWithoutTeams: Permission?
                public var pipelineView: Permission?
                public var ssoProviderCreate: Permission?
                public var ssoProviderUpdate: Permission?
                public var suiteView: Permission?
                public var teamAdmin: Permission?
                public var teamCreate: Permission?
                public var teamEnabledChange: Permission?
                public var teamView: Permission?
            }

            public struct SSO: Decodable, Equatable, Hashable, Sendable {
                public var providerName: String?
                public var isEnabled: Bool

                enum CodingKeys: CodingKey {
                    case provider
                    case isEnabled
                }

                public init(
                    from decoder: Decoder
                ) throws {
                    struct Provider: Decodable {
                        var name: String
                    }

                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    if let provider = try container.decodeIfPresent(Provider.self, forKey: .provider) {
                        providerName = provider.name
                    }
                    isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
                }
            }
        }

        public struct Permission: Decodable, Equatable, Hashable, Sendable {
            public var allowed: Bool
            public var code: String?
            public var message: String?
        }
    }

    public static let query: String = """
        query GetUserQuery($memberSlug: ID!) {
          organizationMember(slug: $memberSlug) {
            complimentary
            createdAt
            createdBy {
              avatar {
                url
              }
              bot
              email
              hasPassword
              id
              name
              uuid
            }
            id
            organization {
              iconUrl
              id
              isTeamsEnabled
              name
              permissions {
                agentTokenCreate {
                  allowed
                  code
                  message
                }
                agentTokenView {
                  allowed
                  code
                  message
                }
                agentView {
                  allowed
                  code
                  message
                }
                auditEventsView {
                  allowed
                  code
                  message
                }
                notificationServiceUpdate {
                  allowed
                  code
                  message
                }
                organizationBillingUpdate {
                  allowed
                  code
                  message
                }
                organizationInvitationCreate {
                  allowed
                  code
                  message
                }
                organizationMemberUpdate {
                  allowed
                  code
                  message
                }
                organizationMemberView {
                  allowed
                  code
                  message
                }
                organizationMemberViewSensitive {
                  allowed
                  code
                  message
                }
                organizationUpdate {
                  allowed
                  code
                  message
                }
                pipelineCreate {
                  allowed
                  code
                  message
                }
                pipelineCreateWithoutTeams {
                  allowed
                  code
                  message
                }
                pipelineView {
                  allowed
                  code
                  message
                }
                ssoProviderCreate {
                  allowed
                  code
                  message
                }
                ssoProviderUpdate {
                  allowed
                  code
                  message
                }
                suiteView {
                  allowed
                  code
                  message
                }
                teamAdmin {
                  allowed
                  code
                  message
                }
                teamCreate {
                  allowed
                  code
                  message
                }
                teamEnabledChange {
                  allowed
                  code
                  message
                }
                teamView {
                  allowed
                  code
                  message
                }
              }
              public
              slug
              sso {
                provider {
                  name
                }
                isEnabled
              }
              uuid
            }
            permissions {
              organizationMemberDelete {
                allowed
                code
                message
              }
              organizationMemberUpdate {
                allowed
                code
                message
              }
            }
            role
            security {
              passwordProtected
              twoFactorEnabled
            }
            user {
              id
              uuid
              name
              email
              avatar {
                url
              }
              bot
              hasPassword
            }
            uuid
          }
        }
        """

    var organization: String
    var memberID: String

    public var variables: [String: JSONValue] {
        [
            "memberSlug": .string("\(organization)/\(memberID)")
        ]
    }

    init(
        organization: String,
        memberID: String
    ) {
        self.organization = organization
        self.memberID = memberID
    }
}
