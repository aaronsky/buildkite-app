//
//  UsersList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/26/20.
//

import SwiftUI
import Buildkite

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
                HStack {
                    RemoteImage(url: user.user.avatar.url)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(user.user.name ?? "")
                    Text(user.user.email ?? "")
                        .font(.caption)
                }
                }
                .onTapGesture {
                    onUserSelection?(user)
                }
            }
        }
        .listStyle(InsetListStyle())
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
    static var query = try! GraphQL<UsersSearchQuery.Response>.Content(assetNamed: "gql.UsersSearch").get()
    
    static var previews: some View {
        UsersList(users: query.organization.members.nodes)
            .environmentObject(BuildkiteService())
    }
}
