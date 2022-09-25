import Buildkite
import Foundation

public enum Fragments {
    public struct User: Decodable, Equatable, Hashable, Identifiable, Sendable {
        public var id: String
        public var uuid: String
        public var name: String
        public var email: String
        public var avatar: Avatar
        public var bot: Bool
        public var hasPassword: Bool
    }

    public struct Avatar: Decodable, Equatable, Hashable, Sendable {
        public var url: URL

        public init(
            url: URL
        ) {
            self.url = url
        }

        public init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let str = try container.decode(String.self, forKey: .url)
            guard let strEncoded = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: strEncoded)
            else {
                throw DecodingError.dataCorruptedError(
                    forKey: .url,
                    in: container,
                    debugDescription: "URL contains unescapable characters and cannot be decoded."
                )
            }
            self.init(url: url)
        }

        private enum CodingKeys: String, CodingKey {
            case url
        }
    }

    public struct Team: Decodable, Equatable, Hashable, Identifiable, Sendable {
        public var id: String
        public var name: String
        public var slug: String
        public var description: String?
        public var privacy: Privacy
        public var members: Connection<Member>

        public struct Member: Decodable, Equatable, Hashable, Identifiable, Sendable {
            public var id: String
            public var uuid: String
            public var role: Role
            public var user: User

            public enum Role: String, Decodable, Equatable, Hashable, Sendable {
                case member = "MEMBER"
                case maintainer = "MAINTAINER"
            }
        }

        public enum Privacy: String, Decodable, Equatable, Hashable, Sendable {
            case visible = "VISIBLE"
            case secret = "SECRET"

            init(
                from visibility: Buildkite.Team.Visibility
            ) {
                switch visibility {
                case .secret: self = .secret
                case .visible: self = .visible
                }
            }
        }

        public init(
            id: String,
            name: String,
            slug: String,
            description: String? = nil,
            privacy: Privacy,
            members: Connection<Fragments.Team.Member>
        ) {
            self.id = id
            self.name = name
            self.slug = slug
            self.description = description
            self.privacy = privacy
            self.members = members
        }

        public init(
            team: Buildkite.Team
        ) {
            self.init(
                id: "",
                name: team.name,
                slug: team.slug,
                description: team.description,
                privacy: Privacy(from: team.privacy),
                members: []
            )
        }
    }
}
