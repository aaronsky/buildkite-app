//
//  Organization+GraphQL.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

extension Fragments {
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

            struct User: Decodable {
                var id: String
                var name: String
                var email: String
            }
        }
    }
}
