//
//  ProfileView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    enum ProfileViewTab: String, CaseIterable, Identifiable {
        case overview
        case social
        case settings
        
        var id: String {
            self.rawValue
        }
    }
    
    
//    MARK: Vars
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    let profile: PlanterProfile
    let image: Image
    
    @State var activePage: ProfileViewTab = .overview
    
    init(_ profile: PlanterProfile? = nil) {
        self.profile = profile!
        self.image = profile!.getProfilePicture()
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HeaderTabBar(activeTab: $activePage)
                .padding([.horizontal, .top], 7)
                .padding(.top)
            
            TabView(selection: $activePage) {
                
                ProfileOverviewView(profile: profile, image: image)
                    .padding(.horizontal)
                    .tag( ProfileViewTab.overview )
                
                ProfileSocialView(profile: profile, image: image)
//                    .padding(.horizontal)
                    .tag( ProfileViewTab.social )
                
                LargeTextButton("log out", at: 0) {
                    Task {
                        await PlanterModel.realmManager.logout()
                    }
                }
                    .tag( ProfileViewTab.settings )
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
                
        }
        .universalImageBackground(self.image)
        
        
        
    }
    
}
//
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
