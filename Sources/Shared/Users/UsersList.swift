//
//  UsersList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/26/20.
//

import SwiftUI

struct UsersList: View {
    typealias User = Fragments.Organization.Member
    
    @EnvironmentObject var service: BuildkiteService
    
    var teamSlug: String?
    var onUserSelection: ((User) -> ())?
    
    @State var users: [User] = []
    @State var searchQuery: String = ""
    
    var body: some View {
        List {
            ForEach(users) { user in
                Text(user.user.name)
                    .onTapGesture {
                        onUserSelection?(user)
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: loadUsers)
        .navigationTitle("Users")
    }
    
    func loadUsers() {
        service
            .sendQueryPublisher(UsersSearchQuery(organization: service.organization, search: searchQuery, notInTeam: teamSlug))
            .tryMap { try $0.get() }
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.users = $0.organization.members.nodes })
    }
}

struct UsersList_Previews: PreviewProvider {
    static var previews: some View {
        UsersList()
    }
}
