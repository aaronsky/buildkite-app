//
//  TeamView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Combine
import Buildkite

struct TeamView: View {
    @EnvironmentObject var service: BuildkiteService
    
    @State var team: Fragments.Team
    
    @State private var selectedUserIDFromSearching: String?
    @State private var presentingSearchUsersModal = false
    
    @ViewBuilder var body: some View {
        #if !os(macOS)
        content
            .navigationBarTitle(team.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                presentingSearchUsersModal = true
            }, label: {
                Image(systemName: "person.badge.plus")
            }))
        #else
        content
        #endif
    }
    
    var content: some View {
        Form {
            Section {
                Text(team.privacy.rawValue)
                Text(team.description ?? "")
            }
            Section(header: Text("MEMBERS")) {
                ForEach(team.members.nodes) { member in
                    NavigationLink(destination: UserView(userID: member.id)) {
                        Text(member.user.name)
                    }
                }
                .onDelete(perform: deleteMembers)
            }
        }
        .onAppear(perform: reloadTeam)
        .sheet(isPresented: $presentingSearchUsersModal, onDismiss: onDismissSearchUserModal) {
            UsersList()
            //            SearchUsersModal(isPresenting: self.$presentingSearchUsersModal, userID: self.$selectedUserIDFromSearching, teamSlug: self.viewModel.team.slug)
        }
    }
    
    var teamGraphQLPublisher: AnyPublisher<TeamGetQuery.Response, Error> {
        service
            .sendPublisher(resource: TeamGetQuery(organization: service.organization, team: team.slug).resource)
            .tryMap { try $0.get() }
            .eraseToAnyPublisher()
    }
    
    func onDismissSearchUserModal() {
        guard let userID = selectedUserIDFromSearching else {
            return
        }
        addMember(with: userID)
    }
    
    func reloadTeam() {
        teamGraphQLPublisher
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.team = $0.team })
    }
    
    func addMember(with userID: String) {
        service
            .sendPublisher(resource: TeamCreateMemberMutation(teamID: team.id, userID: userID).resource)
            .tryMap { try $0.get() }
            .zip(teamGraphQLPublisher)
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.team = $0.1.team })
    }
    
    func deleteMembers(at offsets: IndexSet) {
        let ids = offsets.map { team.members.edges[$0].node.id }
        let deletions = ids.map {
            service
                .sendPublisher(resource: TeamDeleteMemberMutation(id: $0).resource)
                .tryMap { try $0.get() }
        }
        
        Publishers.MergeMany(deletions)
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { data in
                    self.team.members.edges.removeAll(where: { $0.node.id == data.teamMemberDelete.deletedTeamMemberID })
                  })
    }
}

struct TeamView_Previews: PreviewProvider {
    static let teams = [Team](assetNamed: "v2.teams")!.map(Fragments.Team.init)
    
    static var previews: some View {
        Group {
            NavigationView {
                TeamView(team: teams[0])
            }
            TeamView(team: teams[1])
                .previewLayout(.sizeThatFits)
                .frame(height: 700)
        }
        .environmentObject(BuildkiteService())
    }
}
