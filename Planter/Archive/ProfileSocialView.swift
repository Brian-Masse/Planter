//
//  ProfileSocialView.swift
//  Planter
//
//  Created by Brian Masse on 12/11/23.
//

import Foundation
import SwiftUI
import RealmSwift
import UIUniversals

struct ProfileSocialView: View {
    
//    MARK: Vars
    @ObservedRealmObject var profile: PlanterProfile
    let image: Image
    
    @State var profileSearchText: String = ""
    @State var profileSearchResults: [PlanterProfile] = []
    
    
//    MARK: Struct Methods
    private func mapOwnerIdList(_ list: [String]) -> [PlanterProfile] {
        list.compactMap { str in
            PlanterProfile.getProfile(from: str)
        }
    }
    
    @MainActor
    private func getSearchResults() async {
        let results = await PlanterProfile.searchProfiles(in: profileSearchText)
        
        self.profileSearchResults = results
    }
    
    private func makeSearchResultButtonText(_ result: PlanterProfile) -> String {
        
        if profile == result { return "" }
        else if profile.isFriends(with: result) { return "Buddy" }
        else if profile.isRequestedBy(result) { return "Add Buddy" }
        else if profile.isPending(result) { return "Pen ding" }

        return "Add Buddy"
    }
    
    private func searchResultFunction(result: PlanterProfile, isFriends: Bool, isRequestedBy: Bool, isPending: Bool) {
        
        if isFriends {  }
        else if isRequestedBy {
            profile.acceptFriendRequest(ownerID: result.ownerId)
        } else if isPending {
            profile.unRequestFriend(result)
        } else {
            profile.requestFriend(result)
        }
        
    }
    
//    MARK: MakeProfileList
    @ViewBuilder
    private func makeProfileList(_ title: String, list: [PlanterProfile], showButton: Bool = true) -> some View {
        if !list.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                
                if !title.isEmpty {
                    UniversalText( title, size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase )
                        .opacity(0.6)
                        .padding(.bottom, 7)
                    
                }
                
                ForEach( list ) { friend in
                    if friend.ownerId != profile.ownerId {
                        makeSearchResult(friend, showButton: showButton)
                            .padding(.bottom, 7)
                    }
                }
            }
        }
    }
    

//    MARK: Search
    @ViewBuilder
    private func makeSearchResult(_ result: PlanterProfile, showButton: Bool) -> some View {
    
        HStack {
            let isFriends = profile.isFriends(with: result)
            let isRequestedBy = profile.isRequestedBy(result)
            let isPending = profile.isPending(result)
            
            VStack(alignment: .leading) {
                UniversalText( result.fullName(), size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                
                UniversalText( result.userName, size: Constants.UIDefaultTextSize, font: Constants.titleFont )
            }
            .padding(.leading)
            
            Spacer()
            
            if profile != result && showButton {
                LargeTextButton(makeSearchResultButtonText(result),
                                at: 0,
                                aspectRatio: 1,
                                verticalTextAlignment: .center,
                                arrow: false,
                                style: isFriends || isRequestedBy || isPending ? .accent : .secondary) {
                    
                    searchResultFunction(result: result,
                                         isFriends: isFriends,
                                         isRequestedBy: isRequestedBy,
                                         isPending: isPending)
                }
                                .shadow(radius: 10, y: 10)
            }
        }
        .foregroundStyle(.black.opacity(0.7))
        .rectangularBackground(style: .transparent)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
    }
    
    @ViewBuilder
    private func makeSearch() -> some View {
        VStack(alignment: .leading, spacing: 0) {
        
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    UniversalText( "find \nbuddies", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase, lineSpacing: -15 )
                    
                    StyledTextField($profileSearchText, prompt: "search", question: "Search by first name, last name, or username")
                        .padding(.trailing)
                }
                
                LargeTextButton("sea rch", at: 0, aspectRatio: 1.5, verticalTextAlignment: .bottom, arrow: true, arrowDirection: .up) {
                    Task {
                        await self.getSearchResults()
                    }
                }
                .padding(.horizontal, 7)
                .offset(y: 10)
            }
            
            if profileSearchResults.count != 0 {
                makeProfileList("results", list: profileSearchResults)
            }
        }
        .padding(.horizontal)
    }
    
//    MARK: FriendRequests
    
    @ViewBuilder
    private func makeFriendRequestSection() -> some View {
        VStack(alignment: .leading) {
            
            let friendRequests = mapOwnerIdList( Array(profile.friendRequests) )
            let pendingRequests = mapOwnerIdList( Array(profile.pendingRequests) )
            
            if !(friendRequests.isEmpty && pendingRequests.isEmpty) {
                
                UniversalText( "friend requests", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase, lineSpacing: -20 )
                
                if friendRequests.count != 0 {
                    makeProfileList("Requests", list: friendRequests)
                }
                
                if pendingRequests.count != 0 {
                    makeProfileList("pending", list: pendingRequests)
                }
            }
        }
        .padding(.horizontal)
    }
    
//    MARK: Friends
    @ViewBuilder
    private func makeFriendNode(_ profile: PlanterProfile) -> some View {
        
        VStack(alignment: .leading) {
            Rectangle()
                .frame(width: 250, height: 300)
                .overlay {
                    profile.getProfilePicture()
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(3)
                        .mask {
                            Rectangle().frame(height: 300)
                        }
                }
                .cornerRadius(Constants.UIDefaultTextSize)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    UniversalText( profile.fullName(), size: Constants.UIDefaultTextSize, font: Constants.mainFont, case: .uppercase )
                    
                    UniversalText( profile.userName, size: Constants.UISmallTextSize, font: Constants.mainFont )
                }
                .scaleEffect(1.1, anchor: .leading)
                
                
            }
        }
    }
    
    @ViewBuilder
    private func makeFriendsSection(proxy: ScrollViewProxy) -> some View {
        
        VStack(alignment: .leading) {
            
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    UniversalText( "Plant \nbuddies", size: Constants.UIMainHeaderTextSize, font: Constants.titleFont, case: .uppercase, lineSpacing: -20 )
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach( profile.friends ) { friend in
                                makeFriendNode(friend)
                            }
                        }
                    }
                }
                    
                LargeTextButton("Add Buddy", at: 30, aspectRatio: 1.6, verticalTextAlignment: .top) {
                    proxy.scrollTo(2, anchor: .top)
                }
                .offset(x: 15)
            }
            
            Divider()
        }
        .padding(.horizontal)
    }

//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
    
            ScrollViewReader { proxy in
                ScrollView(.vertical ) {
                    makeFriendsSection(proxy: proxy)
                        .id(1)
                        .padding(.bottom)
                    
                    makeSearch()
                        .id(2)
                        .padding(.bottom, 40)
                    
                    makeFriendRequestSection()
                        .id(3)
                        .padding(.bottom, 40)
                    
                    Spacer()
                
                }
            }
        }
        
    }
    
}



//#Preview {
//    
//    let profile = PlanterProfile(ownerId: "",
//                                 firstName: "Brian",
//                                 lastName: "Masse",
//                                 userName: "bmasse23",
//                                 email: "brianm25it@gmail.com",
//                                 phoneNumber: 7813153811,
//                                 birthday: .now)
//    
//    return ProfileView(profile)
//}
//
