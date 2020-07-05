//
//  UsersOrTeamsView.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/4/20.
//

import SwiftUI

struct UsersOrTeamsView: View {
    enum Subview {
        case users
        case teams
    }
    
    @State var isShowingFilterMenu: Bool = false
    @State var subviewSelection: Subview = .users
    
    var body: some View {
        VStack {
            if isShowingFilterMenu {
                FilterMenu(subviewSelection: $subviewSelection)
            }
            switch subviewSelection {
            case .users:
                UsersList()
            case .teams:
                TeamsList()
            }
        }.navigationBarItems(trailing: Button(action: {
            withAnimation {
                isShowingFilterMenu.toggle()                
            }
        }, label: {
            if isShowingFilterMenu {
                Image(systemName: "line.horizontal.3.decrease.circle.fill")
            } else {
                Image(systemName: "line.horizontal.3.decrease.circle")
            }
        }))
    }
}

struct FilterMenu: View {
    @Binding var subviewSelection: UsersOrTeamsView.Subview
    
    var body: some View {
        VStack {
            Picker("View", selection: $subviewSelection) {
                Text("Users").tag(UsersOrTeamsView.Subview.users)
                Text("Teams").tag(UsersOrTeamsView.Subview.teams)
            }
            .padding(.horizontal, 20)
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct UsersOrTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsersOrTeamsView(isShowingFilterMenu: true, subviewSelection: .teams)
                .environmentObject(BuildkiteService())
                .environmentObject(Emojis(cache: ImageMemoryCache()))
        }
    }
}
