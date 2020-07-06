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
    @EnvironmentObject var emojis: Emojis
    
    @State var team: Fragments.Team
    
    @State private var selectedUserIDFromSearching: String?
    @State private var presentingSearchUsersModal = false
    
    @ViewBuilder var body: some View {
        #if !os(macOS)
        content
            .navigationBarTitle(emojis.replacingEmojiIdentifiers(in: team.name), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentingSearchUsersModal = true
            }, label: {
                Label("Add Person", systemImage: "person.badge.plus")
                    .labelStyle(IconOnlyLabelStyle())
            }))
        #else
        content
        #endif
    }
    
    var content: some View {
        Form {
            Section {
                Text(team.privacy.rawValue)
                EmojiLabel(team.description ?? "")
            }
            Section(header: Text("MEMBERS")) {
                ForEach(team.members.nodes) { member in
                    NavigationLink(destination: UserView(userID: member.id)) {
                        Text(member.user.name ?? "")
                    }
                }
                .onDelete(perform: deleteMembers)
            }
        }
        .onAppear(perform: reloadTeam)
        .sheet(isPresented: $presentingSearchUsersModal, onDismiss: onDismissSearchUserModal) {
            VStack {
                Text("// TODO: Search Field goes here")
                UsersList(teamSlug: team.slug,
                          onUserSelection: { user in
                    presentingSearchUsersModal = false
                    selectedUserIDFromSearching = user.user.id
                })
            }.environmentObject(service)
        }
    }
    
    var teamGraphQLPublisher: AnyPublisher<TeamGetQuery.Response, Error> {
        service
            .sendQueryPublisher(TeamGetQuery(organization: service.organization, team: team.slug))
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
            .sendQueryPublisher(TeamCreateMemberMutation(teamID: team.id, userID: userID))
            .tryMap { try $0.get() }
            .zip(teamGraphQLPublisher)
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.team = $0.1.team })
    }
    
    func deleteMembers(at offsets: IndexSet) {
        let ids = offsets.compactMap { team.members.edges?[$0].node.id }
        let deletions = ids.map {
            service
                .sendQueryPublisher(TeamDeleteMemberMutation(id: $0))
                .tryMap { try $0.get() }
        }
        
        Publishers.MergeMany(deletions)
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { data in
                    self.team.members.edges?.removeAll(where: { $0.node.id == data.teamMemberDelete.deletedTeamMemberID })
                  })
    }
}

struct TeamView_Previews: PreviewProvider {
    static let teams = [Team](assetNamed: "v2.teams").map(Fragments.Team.init)
    
    static var previews: some View {
        NavigationView {
            TeamView(team: teams[1])
        }
        .frame(height: 700)
        .previewLayout(.sizeThatFits)
        .environmentObject(BuildkiteService())
        .environmentObject(Emojis())
    }
}
