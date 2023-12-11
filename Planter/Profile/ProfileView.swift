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
    
    @State var activePage: ProfileViewTab = .social
    
    init(_ profile: PlanterProfile? = nil) {
        self.profile = profile!
        self.image = PhotoManager.decodeImage(from: profile!.profileImage) ?? Image("profile")
    }
    
//    MARK: ViewBuilders
    
    
    
//    MARK: Header
    @ViewBuilder
    private func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                
                UniversalText("\(profile.firstName)\n\(profile.lastName)",
                              size: Constants.UITitleTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              wrap: false,
                              scale: true,
                              lineSpacing: -30)
                
                Spacer()
                
                Rectangle()
                    .foregroundStyle(Colors.accent)
                    .frame(width: 100, height: 120)
                    .overlay {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .mask {
                                Rectangle().frame(width: 100, height: 120)
                            }
                            .scaleEffect(3)
                            .rotationEffect(.degrees(25))
                    }
                    .cornerRadius(Constants.UIDefaultCornerRadius)
                    .rotationEffect(.degrees(-25))
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 10)
            }
            
            UniversalText( profile.userName, size: Constants.UIDefaultTextSize, font: Constants.titleFont )
            
            Divider()
        }
    }
    
//    MARK: OverviewBody
    @ViewBuilder
    private func makeOverviewBody() -> some View {
        
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    UniversalText( "overview", size: Constants.UIHeaderTextSize, font: Constants.mainFont, case: .uppercase )
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        UniversalText( "Phone\nnumber",
                                       size: Constants.UISubHeaderTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                        
                        UniversalText( "\(profile.phoneNumber.formatIntoPhoneNumber())",
                                       size: Constants.UIDefaultTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                        .padding(.bottom)
                        
                        UniversalText( "Birthday",
                                       size: Constants.UISubHeaderTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                        
                        UniversalText( profile.birthday.formatted(date: .abbreviated, time: .omitted),
                                       size: Constants.UIDefaultTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                    }
                    
                    Divider(vertical: true)
                        .frame(height: 150)
                        .padding(.horizontal, 7)
                    
                    VStack(alignment: .leading) {
                        UniversalText( "\nemail",
                                       size: Constants.UISubHeaderTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                        
                        UniversalText( profile.email,
                                       size: Constants.UIDefaultTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase,
                                       wrap: false,
                                       scale: true )
                        .padding(.bottom)
                        
                        UniversalText( "Date joined",
                                       size: Constants.UISubHeaderTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                        
                        UniversalText( profile.dateJoined.formatted(date: .abbreviated, time: .omitted),
                                       size: Constants.UIDefaultTextSize,
                                       font: Constants.mainFont,
                                       case: .uppercase )
                    }
                }
                .padding(.bottom)
                
                Divider()
            }
            
            LargeTextButton("Edit Profile", at: 35, aspectRatio: 1.5, verticalTextAlignment: .top, arrowDirection: .down) {
                
            }
            .offset(y: -50)
            
        }
    }
    
//    MARK: Scenes
    @ViewBuilder
    private func makeOverviewScene() -> some View {
        VStack(alignment: .leading) {
            makeHeader()
            
            makeOverviewBody()
            
            Spacer()
        }
        
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HeaderTabBar(activeTab: $activePage)
                .padding([.horizontal, .top], 7)
            
            TabView(selection: $activePage) {
                
                makeOverviewScene()
                    .padding(.horizontal)
                    .tag( ProfileViewTab.overview )
                
                Text("hi!")
                    .tag( ProfileViewTab.settings )
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
                
        }
        .universalImageBackground(self.image)
        
        
        
    }
    
}

#Preview {
    
    let profile = PlanterProfile(ownerId: "",
                                 firstName: "Brian",
                                 lastName: "Masse",
                                 userName: "bmasse23",
                                 email: "brianm25it@gmail.com",
                                 phoneNumber: 7813153811,
                                 birthday: .now)
    
    return ProfileView(profile)
}
