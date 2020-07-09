//
//  Fragment.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import Foundation
import Buildkite

protocol Fragment: Decodable {
    static var fragment: String { get }
}

enum Fragments {    
    struct User: Decodable {
        var id: String?
        var name: String?
        var email: String?
        var avatar: Avatar
    }
    
    struct Avatar: Decodable {
        var url: URL
    }
    
    struct Organization: Decodable {
        var members: Connection<Member>
        
        struct Member: Identifiable, Decodable {
            var id: String
            var role: Role
            var user: User
            
            enum Role: String, Decodable {
                case member = "MEMBER"
                case admin = "ADMIN"
            }

        }
    }
    
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
        
        init(id: String, name: String, slug: String, description: String? = nil, privacy: Privacy, members: Connection<Fragments.Team.Member>) {
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
}
