//
//  Schema.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/6/20.
//

import Foundation

private func decodeVariant<T: Decodable>(from decoder: Decoder) throws -> T? {
    do {
        return try T(from: decoder)
    } catch DecodingError.typeMismatch(_, _) {
        return nil
    } catch {
        throw error
    }
}

enum Schema {

    struct Agent: Decodable {
        var clusterQueue: ClusterQueue?
        /// The time when the agent connected to Buildkite
        var connectedAt: Date?
        /// The connection state of the agent
        var connectionState: String
        /// The date the agent was created
        var createdAt: Date?
        /// The time when the agent disconnected from Buildkite
        var disconnectedAt: Date?
        /// The last time the agent performend a `heartbeat` operation to the Agent API
        var heartbeatAt: Date?
        /// The hostname of the machine running the agent
        var hostname: String?
        var id: String
        /// The IP address that the agent has connected from
        var ipAddress: String?
        /// If this version of agent has been deprecated by Buildkite
        var isDeprecated: Bool
        /// Returns whether or not this agent is running a job. If isRunningJob true, but the `job` field is empty, the current user doesn't have access to view the job
        var isRunningJob: Bool
        /// The currently running job
        var job: Job?
        /// Jobs that have been assigned to this agent
        // jobs(first: Intafter: Stringlast: Intbefore: Stringtype: [JobTypes!]state: [JobStates!]agentQueryRules: [String!]concurrency: JobConcurrencySearchpassed: Booleanstep: JobStepSearchorder: JobOrder = RECENTLY_ASSIGNED): JobConnection
        /// The date the agent was lost from Buildkite if it didn't cleanly disconnect
        var lostAt: Date?
        /// The meta data this agent was stared with
        var metaData: [String]?
        /// The name of the agent
        var name: String
        /// The operating system the agent is running on
        var operatingSystem: OperatingSystem?
        var organization: Organization?
        var permissions: Permissions
        /// The process identifier (PID) of the agent process on the machine
        var pid: String?
        /// The priority setting for the agent
        var priority: Int?
        /// Whether this agent is visible to everyone, including people outside this organization
        var `public`: Bool
        /// The time this agent was forced to stop
        var stopForcedAt: Date?
        /// The user that forced this agent to stop
        var stopForcedBy: User?
        /// The time the agent was gracefully stopped by a user
        var stoppedGracefullyAt: Date?
        /// The user that gracefully stopped this agent
        var stoppedGracefullyBy: User?
        /// The User-Agent of the program that is making Agent API requests to Buildkite
        var userAgent: String?
        /// The public UUID for the agent
        var uuid: UUID
        /// The version of the agent
        var version: String?
        /// Whether this agent's version has known issues and should be upgraded
        var versionHasKnownIssues: Bool
        
        struct Permissions: Decodable {
            /// Whether the user can manually delete this agent (only available to legacy agents)
            var agentDelete: Permission?
            /// Whether the user can stop the agent remotely
            var agentStop: Permission?
        }
    }
    
    struct AgentToken: Decodable {
        
    }
    
    struct APIAccessTokenCode: Decodable {
        
    }
    
    struct Artifact: Decodable {
        
    }
        
    struct AuditEvent: Decodable {
        /// The actor who caused this event
        var actor: Actor
        /// The context in which this event occurred
        var context: Context
        /// The changed data in the event
        var data: String?
        var id: String
        /// The time at which this event occurred
        var occurredAt: Date
        /// The subject of this event
        var subject: Subject?
        /// The type of event
        var type: EventType
        /// The public UUID for the event
        var uuid: UUID
        
        struct Actor: Decodable {
            /// The GraphQL ID for this actor
            var id: String
            /// The name or short description of this actor
            var name: String?
            /// The node corresponding to this actor, if available
            var node: User?
            /// The type of this actor
            var type: ActorType?
            /// The public UUID of this actor
            var uuid: UUID
            
            enum ActorType: String, Decodable {
                case user = "USER"
            }
        }
        
        struct Context: Decodable {
//            AuditWebContext
//            AuditAPIContext
        }
        
        struct Subject: Decodable {
            /// The GraphQL ID for the subject
            var id: String
            /// The name or short description of this subject
            var name: String?
            /// The node corresponding to the subject, if available
            var node: Node?
            /// The type of this subject
            var type: SubjectType?
            /// The public UUID of this subject
            var uuid: UUID
            
            struct Node: Decodable {
//                Team
//                TeamMember
//                TeamPipeline
//                SCMService
//                SCMPipelineSettings
//                Portal
//                PortalEndpoint
//                Email
//                OrganizationInvitation
//                TOTP
//                SSOProviderGoogleGSuite
//                SSOProviderGitHubApp
//                SSOProviderSAML
//                ClusterToken
//                AuthorizationBitbucket
//                AuthorizationGitHubEnterprise
//                AuthorizationGitHub
//                ClusterPermission
//                OrganizationMember
//                Pipeline
//                AgentToken
//                APIAccessToken
//                Organization
//                Cluster
//                ClusterQueue
//                User
//                NotificationServiceSlack
//                NotificationServiceWebhook
//                PipelineSchedule
            }
            
            enum SubjectType: String, Decodable {
                case team = "TEAM"
                case teamMember = "TEAM_MEMBER"
                case teamPipeline = "TEAM_PIPELINE"
                case scmService = "SCM_SERVICE"
                case scmPipelineSettings = "SCM_PIPELINE_SETTINGS"
                case portal = "PORTAL"
                case portalEndpoint = "PORTAL_ENDPOINT"
                case userEmail = "USER_EMAIL"
                case organizationInvitation = "ORGANIZATION_INVITATION"
                case userTOTP = "USER_TOTP"
                case ssoProvider = "SSO_PROVIDER"
                case clusterToken = "CLUSTER_TOKEN"
                case authorization = "AUTHORIZATION"
                case clusterPermission = "CLUSTER_PERMISSION"
                case organizationMember = "ORGANIZATION_MEMBER"
                case pipeline = "PIPELINE"
                case agentToken = "AGENT_TOKEN"
                case apiAccessToken = "API_ACCESS_TOKEN"
                case organization = "ORGANIZATION"
                case cluster = "CLUSTER"
                case clusterQueue = "CLUSTER_QUEUE"
                case user = "USER"
                case notificationService = "NOTIFICATION_SERVICE"
                case pipelineSchedule = "PIPELINE_SCHEDULE"
            }
        }

        enum EventType: String, Decodable {
            case apiAccessTokenCreated = "API_ACCESS_TOKEN_CREATED"
            case apiAccessTokenDeleted = "API_ACCESS_TOKEN_DELETED"
            case apiAccessTokenOrganization_access_revoked = "API_ACCESS_TOKEN_ORGANIZATION_ACCESS_REVOKED"
            case apiAccessTokenUpdated = "API_ACCESS_TOKEN_UPDATED"
            case agentTokenCreated = "AGENT_TOKEN_CREATED"
            case agentTokenRevoked = "AGENT_TOKEN_REVOKED"
            case authorizationCreated = "AUTHORIZATION_CREATED"
            case authorizationDeleted = "AUTHORIZATION_DELETED"
            case clusterCreated = "CLUSTER_CREATED"
            case clusterDeleted = "CLUSTER_DELETED"
            case clusterPermissionCreated = "CLUSTER_PERMISSION_CREATED"
            case clusterPermissionDeleted = "CLUSTER_PERMISSION_DELETED"
            case clusterPermissionUpdated = "CLUSTER_PERMISSION_UPDATED"
            case clusterQueueCreated = "CLUSTER_QUEUE_CREATED"
            case clusterQueueDeleted = "CLUSTER_QUEUE_DELETED"
            case clusterQueueUpdated = "CLUSTER_QUEUE_UPDATED"
            case clusterTokenCreated = "CLUSTER_TOKEN_CREATED"
            case clusterTokenDeleted = "CLUSTER_TOKEN_DELETED"
            case clusterTokenUpdated = "CLUSTER_TOKEN_UPDATED"
            case clusterUpdated = "CLUSTER_UPDATED"
            case notificationServiceBroken = "NOTIFICATION_SERVICE_BROKEN"
            case notificationServiceCreated = "NOTIFICATION_SERVICE_CREATED"
            case notificationServiceDeleted = "NOTIFICATION_SERVICE_DELETED"
            case notificationServiceDisabled = "NOTIFICATION_SERVICE_DISABLED"
            case notificationServiceEnabled = "NOTIFICATION_SERVICE_ENABLED"
            case notificationServiceUpdated = "NOTIFICATION_SERVICE_UPDATED"
            case organizationCreated = "ORGANIZATION_CREATED"
            case organizationDeleted = "ORGANIZATION_DELETED"
            case organizationInvitationAccepted = "ORGANIZATION_INVITATION_ACCEPTED"
            case organizationInvitationCreated = "ORGANIZATION_INVITATION_CREATED"
            case organizationInvitationResent = "ORGANIZATION_INVITATION_RESENT"
            case organizationInvitationRevoked = "ORGANIZATION_INVITATION_REVOKED"
            case organizationMemberCreated = "ORGANIZATION_MEMBER_CREATED"
            case organizationMemberDeleted = "ORGANIZATION_MEMBER_DELETED"
            case organizationMemberUpdated = "ORGANIZATION_MEMBER_UPDATED"
            case organizationTeamsDisabled = "ORGANIZATION_TEAMS_DISABLED"
            case organizationTeamsEnabled = "ORGANIZATION_TEAMS_ENABLED"
            case organizationUpdated = "ORGANIZATION_UPDATED"
            case pipelineCreated = "PIPELINE_CREATED"
            case pipelineDeleted = "PIPELINE_DELETED"
            case pipelineScheduleCreated = "PIPELINE_SCHEDULE_CREATED"
            case pipelineScheduleDeleted = "PIPELINE_SCHEDULE_DELETED"
            case pipelineScheduleUpdated = "PIPELINE_SCHEDULE_UPDATED"
            case pipelineUpdated = "PIPELINE_UPDATED"
            case pipelineVisibilityChanged = "PIPELINE_VISIBILITY_CHANGED"
            case pipelineWebhookURLRotated = "PIPELINE_WEBHOOK_URL_ROTATED"
            case portalCreated = "PORTAL_CREATED"
            case portalDeleted = "PORTAL_DELETED"
            case portalEndpointCreated = "PORTAL_ENDPOINT_CREATED"
            case portalEndpointDeleted = "PORTAL_ENDPOINT_DELETED"
            case portalEndpointUpdated = "PORTAL_ENDPOINT_UPDATED"
            case portalUpdated = "PORTAL_UPDATED"
            case scmPipelineSettingsCreated = "SCM_PIPELINE_SETTINGS_CREATED"
            case scmPipelineSettingsDeleted = "SCM_PIPELINE_SETTINGS_DELETED"
            case scmPipelineSettingsUpdated = "SCM_PIPELINE_SETTINGS_UPDATED"
            case scmServiceCreated = "SCM_SERVICE_CREATED"
            case scmServiceDeleted = "SCM_SERVICE_DELETED"
            case scmServiceUpdated = "SCM_SERVICE_UPDATED"
            case ssoProviderCreated = "SSO_PROVIDER_CREATED"
            case ssoProviderDeleted = "SSO_PROVIDER_DELETED"
            case ssoProviderDisabled = "SSO_PROVIDER_DISABLED"
            case ssoProviderEnabled = "SSO_PROVIDER_ENABLED"
            case ssoProviderUpdated = "SSO_PROVIDER_UPDATED"
            case teamCreated = "TEAM_CREATED"
            case teamDeleted = "TEAM_DELETED"
            case teamMemberCreated = "TEAM_MEMBER_CREATED"
            case teamMemberDeleted = "TEAM_MEMBER_DELETED"
            case teamMemberUpdated = "TEAM_MEMBER_UPDATED"
            case teamPipelineCreated = "TEAM_PIPELINE_CREATED"
            case teamPipelineDeleted = "TEAM_PIPELINE_DELETED"
            case teamPipelineUpdated = "TEAM_PIPELINE_UPDATED"
            case teamUpdated = "TEAM_UPDATED"
            case userEmailCreated = "USER_EMAIL_CREATED"
            case userEmailDeleted = "USER_EMAIL_DELETED"
            case userEmailMarkedPrimary = "USER_EMAIL_MARKED_PRIMARY"
            case userEmailVerified = "USER_EMAIL_VERIFIED"
            case userPasswordReset = "USER_PASSWORD_RESET"
            case userPasswordResetRequested = "USER_PASSWORD_RESET_REQUESTED"
            case userTOTPActivated = "USER_TOTP_ACTIVATED"
            case userTOTPCreated = "USER_TOTP_CREATED"
            case userTOTPDeleted = "USER_TOTP_DELETED"
            case userUpdated = "USER_UPDATED"
        }
    }
    
    struct Avatar: Decodable {
        /// The URL of the avavtar
        var url: URL
    }
    
    class Build: Decodable {
        // annotations(first: Intafter: Stringlast: Intbefore: String): AnnotationConnection
        /// The branch for the build
        var branch: String
        /// The time when the build was cancelled
        var canceledAt: Date?
        /// The user who canceled this build. If the build was canceled, and this value is null, then it was canceled automatically by Buildkite
        var canceledBy: User?
        // comments(first: Intlast: Int): CommentConnection
        /// The fully-qualified commit for the build
        var commit: String
        /// The time when the build was created
        var createdAt: Date?
        var createdBy: Build.Creator?
        /// Custom environment variables passed to this build
        var env: [String]?
        /// The time when the build finished
        var finishedAt: Date?
        var id: String
        // jobs(first: Intafter: Stringlast: Intbefore: Stringtype: [JobTypes!]state: [JobStates!]agentQueryRules: [String!]concurrency: JobConcurrencySearchpassed: Booleanstep: JobStepSearchorder: JobOrder = RECENTLY_CREATED): JobConnection
        /// The message for the build
        var message: String?
        // metaData(first: Intlast: Int): BuildMetaDataConnection
        /// The number of the build
        var number: Int
        var organization: Organization?
        var pipeline: Pipeline
        var pullRequest: PullRequest?
        /// The build that this build was rebuilt from
        var rebuiltFrom: Build?
        /// The time when the build became scheduled for running
        var scheduledAt: Date?
        /// Where the build was created
        var source: Build.Source
        /// The time when the build started running
        var startedAt: Date?
        /// The current state of the build
        var state: Build.State
        /// The job that this build was triggered from
        var triggeredFrom: Job.Trigger?
        /// The URL for the build
        var url: URL
        /// The UUID for the build
        var uuid: UUID

        enum Creator: Decodable {
            case user(User)
            case unregisteredUser(UnregisteredUser)
            
            init(from decoder: Decoder) throws {
                if let user: User = try decodeVariant(from: decoder) {
                    self = .user(user)
                } else if let unregisteredUser: UnregisteredUser = try decodeVariant(from: decoder) {
                    self = .unregisteredUser(unregisteredUser)
                } else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching variant found"))
                }
            }
        }

        enum Source: Decodable {
            case api(API)
            case frontend(Frontend)
            case schedule(Schedule)
            case triggerJob(TriggerJob)
            case webhook(Webhook)
            
            init(from decoder: Decoder) throws {
                if let api: API = try decodeVariant(from: decoder) {
                    self = .api(api)
                } else if let frontend: Frontend = try decodeVariant(from: decoder) {
                    self = .frontend(frontend)
                } else if let schedule: Schedule = try decodeVariant(from: decoder) {
                    self = .schedule(schedule)
                } else if let triggerJob: TriggerJob = try decodeVariant(from: decoder) {
                    self = .triggerJob(triggerJob)
                } else if let webhook: Webhook = try decodeVariant(from: decoder) {
                    self = .webhook(webhook)
                } else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching variant found"))
                }
            }
            
            struct API: Decodable {
                var name: String
            }

            struct Frontend: Decodable {
                var name: String
            }

            struct Schedule: Decodable {
                var name: String
                var pipelineSchedule: PipelineSchedule?
            }

            struct TriggerJob: Decodable {
                var name: String
            }

            struct Webhook: Decodable {
                /// Provider specific headers sent along with the webhook. This will return null if the webhook has been purged by Buildkite.
                var headers: [String]?
                var name: String
                /// The body of the webhook. Buildkite only webhook data for a short period of time, so if this returns null - then the webhook data has been purged by Buildkite
                var payload: String?
                /// The UUID for this webhook. This will return null if the webhook has been purged by Buildkite
                var uuid: UUID?
            }
        }

        enum State: String, Decodable {
            /// The build was skipped
            case skipped = "SKIPPED"
            /// The build has yet to start running jobs
            case scheduled = "SCHEDULED"
            /// The build is currently running jobs
            case running = "RUNNING"
            /// The build passed
            case passed = "PASSED"
            /// The build failed
            case failed = "FAILED"
            /// The build is currently being canceled
            case canceling = "CANCELING"
            /// The build was canceled
            case canceled = "CANCELED"
            /// The build is blocked
            case blocked = "BLOCKED"
            /// The build wasn't run
            case notRun = "NOT_RUN"
        }
    }
    
    struct ClusterQueue: Decodable {
        var cluster: Cluster?
        var createdBy: User?
        var description: String?
        var id: String
        var key: String
        /// The public UUID for this cluster queue
        var uuid: UUID
    }
    
    struct Cluster: Decodable {
        /// Returns agent tokens for the Cluster
        // agentTokens(first: Intlast: Int): ClusterAgentTokenConnection
        var createdBy: User?
        var description: String?
        var id: String
        var name: String
        var organization: Organization?
        // queues(first: Intafter: Stringlast: Intbefore: Stringorder: ClusterQueueOrder = KEY): ClusterQueueConnection
        /// The public UUID for this cluster
        var uuid: UUID
    }
    
    indirect enum Job: Decodable {
        case command(Command)
        case block(Block)
        case wait(Wait)
        case trigger(Trigger)
        
        init(from decoder: Decoder) throws {
            if let command: Command = try decodeVariant(from: decoder) {
                self = .command(command)
            } else if let block: Block = try decodeVariant(from: decoder) {
                self = .block(block)
            } else if let wait: Wait = try decodeVariant(from: decoder) {
                self = .wait(wait)
            } else if let trigger: Trigger = try decodeVariant(from: decoder) {
                self = .trigger(trigger)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching variant found"))
            }
        }
        
        struct Command: Decodable {
            /// The agent that is running the job
            var agent: Agent?
            /// The ruleset used to find an agent to run this job
            var agentQueryRules: [String]?
            /// Artifacts uploaded to this job
            // artifacts(first: Intlast: Int): ArtifactConnection
            /// A glob of files to automatically upload after the job finishes
            var automaticArtifactUploadPaths: String?
            /// The build that this job is a part of
            var build: Build?
            /// The time when the job was cancelled
            var canceledAt: Date?
            /// The cluster of this job
            var cluster: Cluster?
            /// The cluster queue of this job
            var clusterQueue: ClusterQueue?
            /// The command the job will run
            var command: String?
            /// Concurrency information related to a job
            var concurrency: Job.Concurrency?
            /// The time when the job was created
            var createdAt: Date?
            /// Environment variables for this job
            var env: [String]?
            /// Job events
            // events(first: Intafter: Stringlast: Intbefore: String): JobEventConnection!
            /// The exit status returned by the command on the agent
            var exitStatus: String?
            /// The time when the job finished
            var finishedAt: Date?
            var id: String
            /// The label of the job
            var label: String?
            /// If the job has finished and passed
            var passed: Bool
            /// The pipeline that this job is a part of
            var pipeline: Pipeline?
            /// Job retry rules
            var retryRules: Job.RetryRules?
            /// The time when the job became available to be run by an agent
            var runnableAt: Date?
            /// The time when the job became scheduled for running
            var scheduledAt: Date?
            /// If the job soft failed
            var softFailed: Bool
            /// The time when the job started running
            var startedAt: Date?
            /// The state of the job
            var state: Job.State
            /// The step that defined this job. Some older jobs in the system may not have an associated step
            var step: Step.Command?
            /// The URL for the job
            var url: URL
            /// The UUID for this job
            var uuid: UUID
        }
        
        struct Block: Decodable {
            /// The build that this job is a part of
            var build: Build?
            var id: String
            /// Whether or not this job can be unblocked yet (may be waiting on another job to finish)
            var isUnblockable: Bool?
            /// The label of this block step
            var label: String?
            /// The state of the job
            var state: Job.State
            /// The time when the job was created
            var unblockedAt: Date?
            /// The user that unblocked this job
            var unblockedBy: User?
            /// The UUID for this job
            var uuid: UUID
        }
        
        struct Wait: Decodable {
            /// The build that this job is a part of
            var build: Build?
            var id: String
            /// The state of the job
            var state: Job.State
            /// The UUID for this job
            var uuid: UUID
        }
        
        struct Trigger: Decodable {
            /// The build that this job is a part of
            var build: Build?
            var id: String
            /// The state of the job
            var state: Job.State
            /// The build that this job triggered
            var triggered: Build?
            /// The UUID for this job
            var uuid: String
        }
        
        struct Concurrency: Decodable {
            /// The concurrency group
            var group: String
            /// The maximum amount of jobs in the concurrency that are allowed to run at any given time
            var limit: Int
        }
        
        struct RetryRules: Decodable {
            var automatic: [Automatic?]?
            var manual: Bool?
            
            struct Automatic: Decodable {
                var exitStatus: String?
                var limit: String?
            }
        }
        
        enum State: String, Decodable {
            /// The job has just been created and doesn't have a state yet
            case pending = "PENDING"
            /// The job is waiting on a wait step to finish
            case waiting = "WAITING"
            /// The job was in a WAITING state when the build failed
            case waitingFailed = "WAITING_FAILED"
            /// The job is waiting on a block step to finish
            case blocked = "BLOCKED"
            /// The job was in a BLOCKED state when the build failed
            case blockedFailed = "BLOCKED_FAILED"
            /// This block job has been manually unblocked
            case unblocked = "UNBLOCKED"
            /// This block job was in a BLOCKED state when the build failed
            case unblockedFailed = "UNBLOCKED_FAILED"
            /// The job is waiting on a concurrency group check before becoming either LIMITED or SCHEDULED
            case limiting = "LIMITING"
            /// The job is waiting for jobs with the same concurrency group to finish
            case limited = "LIMITED"
            /// The job is scheduled and waiting for an agent
            case scheduled = "SCHEDULED"
            /// The job has been assigned to an agent, and it's waiting for it to accept
            case assigned = "ASSIGNED"
            /// The job was accepted by the agent, and now it's waiting to start running
            case accepted = "ACCEPTED"
            /// The job is runing
            case running = "RUNNING"
            /// The job has finished
            case finished = "FINISHED"
            /// The job is currently canceling
            case canceling = "CANCELING"
            /// The job was canceled
            case canceled = "CANCELED"
            /// The job is timing out for taking too long
            case timingOut = "TIMING_OUT"
            /// The job timed out
            case timedOut = "TIMED_OUT"
            /// The job was skipped
            case skipped = "SKIPPED"
            /// The jobs configuration means that it can't be run
            case broken = "BROKEN"
        }
    }
    
    struct NotificationService: Decodable {
        
    }
    
    struct OperatingSystem: Decodable {
        var name: String
    }
    
    struct Organization: Decodable {
        /// Returns agent access tokens for an Organization. By default returns all tokens, whether revoked or non-revoked.
        // agentTokens(first: Intlast: Intrevoked: Boolean): AgentTokenConnection
        // agents(first: Intafter: Stringlast: Intbefore: Stringsearch: StringmetaData: [String!]cluster: IDclusterQueue: [ID!]isRunningJob: Boolean): AgentConnection
        // auditEvents(first: Intafter: Stringlast: Intbefore: StringoccurredAtFrom: DateTimeoccurredAtTo: DateTimetype: [AuditEventType!]actorType: [AuditActorType!]actor: [ID!]subjectType: [AuditSubjectType!]subject: [ID!]order: OrganizationAuditEventOrders = RECENTLY_OCCURRED): OrganizationAuditEventConnection
        /// Return cluster in the Organization by UUID
        // cluster(id: ID!): Cluster
        /// Returns clusters for an Organization
        // clusters(first: Intafter: Stringlast: Intbefore: Stringorder: ClusterOrder = NAME): ClusterConnection
        /// The URL to an icon representing this organization
        var iconUrl: URL?
        var id: String
        // invitations(first: Intafter: Stringlast: Intbefore: Stringstate: [OrganizationInvitationStates!]order: OrganizationInvitationOrders = RECENTLY_CREATED): OrganizationInvitationConnection
        // jobs(first: Intafter: Stringlast: Intbefore: Stringtype: [JobTypes!]state: [JobStates!]agentQueryRules: [String!]concurrency: JobConcurrencySearchpassed: Booleanstep: JobStepSearchorder: JobOrder = RECENTLY_CREATED): JobConnection
        /// Returns users within the organization
        // members(first: Intafter: Stringlast: Intbefore: Stringsearch: Stringemail: Stringteam: TeamSelectorrole: [OrganizationMemberRole!]security: OrganizationMemberSecurityInputsso: OrganizationMemberSSOInputorder: OrganizationMemberOrder = RECENTLY_CREATED): OrganizationMemberConnection
        /// The name of the organization
        var name: String
        var permissions: Permissions
        /// Return all the pipelines the current user has access to for this organization
        // pipelines(first: Intafter: Stringlast: Intbefore: Stringsearch: Stringrepository: PipelineRepositoryInputteam: TeamSelectorfavorite: Booleanorder: PipelineOrders = RECENTLY_CREATED): PipelineConnection
        /// Whether this organization is visible to everyone, including people outside it
        var `public`: Bool
        /// The slug used to represent the organization in URLs
        var slug: String
        /// The single sign-on configuration of this organization
        var sso: SSO?
        /// Single sign on providers created for an organization
        // ssoProviders(first: Intafter: Stringlast: Intbefore: String): SSOProviderConnection
        /// Returns teams within the organization that the viewer can see
        // teams(first: Intafter: Stringlast: Intbefore: Stringsearch: Stringpipeline: PipelineSelectoruser: UserSelectorprivacy: [TeamPrivacy!]order: TeamOrder = NAME): TeamConnection
        /// The public UUID for this organization
        var uuid: String
        
        struct Permissions: Decodable {
            /// Whether the user can create agent tokens
            var agentTokenCreate: Permission?
            /// Whether the user can access agent tokens
            var agentTokenView: Permission?
            /// Whether the user can create a see a list of agents in organization
            var agentView: Permission?
            /// Whether the user can access audit events for the organization
            var auditEventsView: Permission?
            /// Whether the user can change the notification services for the organization
            var notificationServiceUpdate: Permission?
            /// Whether the user can view and manage billing for the organization
            var organizationBillingUpdate: Permission?
            /// Whether the user can invite members from an organization
            var organizationInvitationCreate: Permission?
            /// Whether the user can update/remove members from an organization
            var organizationMemberUpdate: Permission?
            /// Whether the user can see members in the organization
            var organizationMemberView: Permission?
            /// Whether the user can see sensitive information about members in the organization
            var organizationMemberViewSensitive: Permission?
            /// Whether the user can change the organization name and related source code provider settings
            var organizationUpdate: Permission?
            /// Whether the user can create a new pipeline in the organization
            var pipelineCreate: Permission?
            /// Whether the user can create a new pipeline without adding it to any teams within the organization
            var pipelineCreateWithoutTeams: Permission?
            /// Whether the user can create a see a list of pipelines in organization
            var pipelineView: Permission?
            /// Whether the user can manage portals in the organization
            var portalUpdate: Permission?
            /// Whether the user can change SSO Providers for the organization
            var ssoProviderCreate: Permission?
            /// Whether the user can change SSO Providers for the organization
            var ssoProviderUpdate: Permission?
            /// Whether the user can administer one or all the teams in the organization
            var teamAdmin: Permission?
            /// Whether the user can create teams for the organization
            var teamCreate: Permission?
            /// Whether the user can toggle teams on/off for the organzation
            var teamEnabledChange: Permission?
            /// Whether the user can see teams in the organization
            var teamView: Permission?
        }
        
        struct SSO: Decodable {
            /// Whether this account is configured for single sign-on
            var isEnabled: Bool
            /// The single sign-on provider for this organization
            var provider: Provider?
            
            struct Provider: Decodable {
                var name: String
            }
        }
    }
    
    struct OrganizationInvitation: Decodable {
        
    }
    
    struct OrganizationMember: Decodable {
        
    }
    
    struct Permission: Decodable {
        var allowed: Bool
        var code: String?
        var message: String?
    }
    
    struct Pipeline: Decodable {
        /// Returns the builds for this pipeline
        // builds(first: Intafter: Stringlast: Intbefore: Stringstate: [BuildStates!]branch: [String!]commit: [String!]metaData: [String!]createdAtFrom: DateTimecreatedAtTo: DateTime): BuildConnection
        /// When a new build is created on a branch, any previous builds that are running on the same branch will be automatically cancelled
        var cancelIntermediateBuilds: Bool
        /// Limit which branches build cancelling applies to, for example `!master` will ensure that the master branch won't have it's builds automatically cancelled.
        var cancelIntermediateBuildsBranchFilter: String?
        /// The shortest length to which any git commit ID may be truncated while guaranteeing referring to a unique commit
        var commitShortLength: Int
        /// The time when the pipeline was created
        var createdAt: Date?
        /// The default branch for this pipeline
        var defaultBranch: String?
        /// The short description of the pipeline
        var description: String?
        /// Returns true if the viewer has favorited this pipeline
        var favorite: Bool
        var id: String
        // jobs(first: Intafter: Stringlast: Intbefore: Stringtype: [JobTypes!]state: [JobStates!]agentQueryRules: [String!]concurrency: JobConcurrencySearchpassed: Booleanstep: JobStepSearchorder: JobOrder = RECENTLY_CREATED): JobConnection
        // metrics(first: Intlast: Int): PipelineMetricConnection
        /// The name of the pipeline
        var name: String
        /// The next build number in the sequence
        var nextBuildNumber: Int
        var organization: Organization
        var permissions: Permissions
        /// The repository for this pipeline
        var repository: Repository?
        /// Schedules for this pipeline
        // schedules(first: Int): PipelineScheduleConnection
        /// When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.
        var skipIntermediateBuilds: Bool
        /// Limit which branches build skipping applies to, for example `!master` will ensure that the master branch won't have it's builds automatically skipped.
        var skipIntermediateBuildsBranchFilter: String?
        /// The slug of the pipeline
        var slug: String
        var steps: Steps?
        /// Teams associated with this pipeline
        // teams(first: Intafter: Stringlast: Intbefore: Stringsearch: Stringorder: TeamPipelineOrder = RECENTLY_CREATED): TeamPipelineConnection
        /// The URL for the pipeline
        var url: URL
        /// The UUID of the pipeline
        var uuid: String
        /// Whether this pipeline is visible to everyone, including people outside this organization
        var visibility: Visibility
        /// The URL to use in your repository settings for commit webhooks
        var webhookURL: URL
        
        struct Permissions: Decodable {
            /// Whether the user can create builds on this pipeline
            var buildCreate: Permission
            /// Whether the user can delete this pipeline
            var pipelineDelete: Permission
            /// Whether the user can favorite this pipeline
            var pipelineFavorite: Permission
            /// Whether the user can create schedules on this pipeline
            var pipelineScheduleCreate: Permission
            /// Whether the user can edit the settings of this pipeline
            var pipelineUpdate: Permission
        }
        
        struct Steps: Decodable {
            /// A YAML representation of the pipeline steps
            var yaml: String?
        }
        
        enum Visibility: String, Decodable {
            /// The pipeline is public
            case `public` = "PUBLIC"
            /// The pipeline is private
            case `private` = "PRIVATE"
        }
    }
    
    struct PipelineSchedule: Decodable {
        /// The branch to use for builds that this schedule triggers. Defaults to to the default branch in the Pipeline
        var branch: String?
        /// Returns the builds created by this schedule
        // builds(first: Intafter: Stringlast: Intbefore: String): BuildConnection
        /// The commit to use for builds that this schedule triggers. Defaults to `HEAD`
        var commit: String?
        /// The time when this schedule was created
        var createdAt: Date?
        var createdBy: User?
        /// A definition of the trigger build schedule in cron syntax
        var cronline: String
        /// If this Pipeline schedule is currently enabled
        var enabled: Bool?
        /// Environment variables passed to any triggered builds
        var env: [String]?
        /// The time when this schedule failed
        var failedAt: Date?
        /// If the last attempt at triggering this scheduled build fails, this will be the reason
        var failedMessage: String?
        var id: String
        /// A short description of the Pipeline schedule
        var label: String
        /// The message to use for builds that this schedule triggers
        var message: String?
        /// The time when this schedule will create a build next
        var nextBuildAt: Date?
        /// The user who owns any builds created by this schedule, if they are not the creator
        var ownedBy: User?
        /// permissions: PipelineSchedulePermissions!
        var pipeline: Pipeline?
        /// The UUID of the Pipeline schedule
        var uuid: UUID
    }
    
    struct PullRequest: Decodable {
        var id: String
    }
    
    struct Repository: Decodable {
        /// The repository’s provider
        var provider: Provider?
        /// The git URL for this repository
        var url: URL
        
        struct Provider: Decodable {
            /// The name of the provider
            var name: String
            /// This URL to the provider’s web interface
            var url: URL?
            /// The URL to use when setting up webhooks from the provider to trigger Buildkite builds
            var webhookUrl: URL?
        }
    }
    
    enum Step {
        struct Command: Decodable {
            /// The conditional evaluated for this step
            var conditional: String?
            /// Dependencies of this job
            // dependencies(first: Intafter: Stringlast: Intbefore: String): DependencyConnection
            /// The user-defined key for this step
            var key: String?
            /// The UUID for this step
            var uuid: UUID
        }
    }
    
    struct Team: Decodable {
        
    }
    
    struct UnregisteredUser: Decodable {
        var avatar: Avatar
        /// The email for the user
        var email: String?
        /// The name of the user
        var name: String?
    }
    
    struct User: Decodable {
        var avatar: Avatar
        /// If this user account is an official bot managed by Buildkite
        var bot: Bool
        /// Returns builds that this user has created.
        // builds(first: Intlast: Intstate: [BuildStates!]branch: [String!]metaData: [String!]): BuildConnection
        /// The primary email for the user
        var email: String
        /// Does the user have a password set
        var hasPassword: Bool
        var id: String
        /// The name of the user
        var name: String
        /// The public UUID of the user
        var uuid: UUID
    }
    
    struct Viewer: Decodable {
        // authorizations(first: Intafter: Stringlast: Intbefore: Stringtype: [AuthorizationType!]): AuthorizationConnection
        // builds(first: Intlast: Intstate: BuildStatesbranch: StringmetaData: [String!]): BuildConnection
        // changelogs(first: Intlast: Intread: Boolean): ChangelogConnection
        /// Emails associated with the current user
        // emails(first: Intlast: Intverified: Boolean): EmailConnection
        /// The ID of the current user
        var id: String
        // jobs(first: Intafter: Stringlast: Intbefore: Stringtype: [JobTypes!]state: [JobStates!]agentQueryRules: [String!]order: JobOrder = RECENTLY_CREATED): JobConnection
        // notice(namespace: NoticeNamespaces!scope: String!): Notice
        // organizations(first: Intlast: Int): OrganizationConnection
        /// The current user's permissions
        var permissions: Permissions
        /// The user's active TOTP configuration, if any. This field is private, requires an escalated session, and cannot be accessed via the public GraphQL API.
        // totp(id: ID): TOTP
        /// The current user
        var user: User?
        
        struct Permissions: Decodable {
            /// Whether the viewer can configure two-factor authentication
            var totpConfigure: Permission
        }
    }
}
