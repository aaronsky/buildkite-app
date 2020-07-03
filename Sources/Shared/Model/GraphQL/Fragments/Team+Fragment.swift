//
//  Team+GraphQL.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

extension Fragments {
    struct Team: Decodable {
        var id: String
        var name: String
        var slug: String
        var description: String?
        var privacy: Privacy
        var members: Connection<Member>
        
        struct Member: Identifiable, Decodable {
            var id: String
            var role: Role
            var user: User
            
            enum Role: String, Decodable {
                case member = "MEMBER"
                case maintainer = "MAINTAINER"
            }
            
            struct User: Decodable {
                var id: String
                var name: String
                var email: String
            }
        }
        
        init(id: String, name: String, slug: String, description: String? = nil, privacy: Fragments.Privacy, members: Connection<Fragments.Team.Member>) {
                self.id = id
                self.name = name
                self.slug = slug
                self.description = description
                self.privacy = privacy
                self.members = members
        }

        
        init(team: Buildkite.Team) {
            self.init(id: "",
                      name: team.name,
                      slug: team.slug,
                      description: team.description,
                      privacy: Privacy(from: team.privacy),
                      members: [])
        }
    }
    
    enum Privacy: String, Decodable {
        case visible = "VISIBLE"
        case secret = "SECRET"
        
        init(from visibility: Buildkite.Team.Visibility) {
            switch visibility {
            case .secret: self = .secret
            case .visible: self = .visible
            }
        }
    }
}
