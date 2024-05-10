//
//  ProfilePageView.swift
//  Planter
//
//  Created by Brian Masse on 5/9/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct ProfilePageView: View {
    
//    MARK: Vars
    
    @State var halfScroll: Bool = false
    @State var scrollPosition: CGPoint = .zero
    
    @Namespace var profilePageNameSpace
    
    let profile: PlanterProfile
    
    let image: Image
    
    init(profile: PlanterProfile) {
        self.profile = profile
        self.image = profile.getImage()
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader() -> some View {
        HStack {
            UniversalText("Profile", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeProfilePicture() -> some View {
        
        let profilePictureSize: CGFloat = halfScroll ? 75 : 275
        let bottomPadding: CGFloat = halfScroll ? Constants.UISubPadding * 2 : -Constants.UISubPadding
        
        VStack(alignment: .leading) {
            HStack {
                if !halfScroll { Spacer() }
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: profilePictureSize, height: profilePictureSize)
                    .clipped()
                    .clipShape(Circle())
                    .shadow(color: .white.opacity(0.1), radius: 15, y: 5)
                    .shadow(color: .white.opacity(0.2), radius: 70, y: 10)
                
                if halfScroll {
                    UniversalText("\(profile.firstName) \(profile.lastName)", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase, lineSpacing: -15)
                        .matchedGeometryEffect(id: "name", in: profilePageNameSpace)
                        .padding(.leading)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, bottomPadding)
            
            if !halfScroll {
                UniversalText("\(profile.firstName) \n\(profile.lastName)", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase, lineSpacing: -15)
                    .padding(.leading)
                    .frame(width: 200, alignment: .leading)
                    .matchedGeometryEffect(id: "name", in: profilePageNameSpace)
            }
        }.padding(.top, Constants.UISubPadding)
    }
    
    @ViewBuilder
    private func makeContactField(label: String, content: String) -> some View {
        HStack {
            UniversalText( label, size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase )
                .padding(.trailing)
                .opacity(0.8)
            
            Spacer()
            
            UniversalText( content, size: Constants.UISmallTextSize, font: Constants.mainFont )
                .opacity(0.6)
        }
        .padding(.horizontal)
    }
    
    
    @ViewBuilder
    private func makeInformationOverview() -> some View {
        VStack(alignment: .leading) {
            
            RoundedContainer("Overview") {
                VStack(spacing: Constants.UISubPadding) {
                    makeContactField(label: "email", content: profile.email)
                    makeContactField(label: "phone", content: profile.phoneNumber.formatIntoPhoneNumber())
                        .padding(.bottom, Constants.UISubPadding)
                    
                    Divider()
                    
                    makeContactField(label: "planter member since",
                                     content: profile.dateJoined.formatted(date: .abbreviated, time: .omitted))
                    .padding(.bottom, Constants.UISubPadding)
                    
                    makeContactField(label: "Birthday",
                                     content: profile.birthday.formatted(date: .abbreviated, time: .omitted))
                    
                }.padding(.vertical, Constants.UISubPadding)
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            makeProfilePicture()
            
            ScrollReader($scrollPosition, showingIndicator: false) {
                VStack(alignment: .leading, spacing: Constants.UISubPadding) {
                    
                    makeInformationOverview()
                    makeInformationOverview()
                    makeInformationOverview()
                }
                .padding(.bottom, Constants.UIBottomPagePadding)
            }
            .onChange(of: scrollPosition) { oldValue, newValue in
                if abs( newValue.y ) > 50 {
                    withAnimation(.easeInOut(duration: 0.35)) { self.halfScroll = true }
                } else if newValue.y > 10 {
                    withAnimation { self.halfScroll = false }
                }
            }
//            ScrollView(.vertical) {
//            }
        }
    }
}


#Preview {
    
    let profile = PlanterProfile(ownerId: "ownerID",
                                        firstName: "Brian",
                                        lastName: "Masse",
                                        userName: "bmasse23",
                                        email: "brianm25it@gmail.com",
                                        phoneNumber: 17813153811,
                                        birthday: Date.now)
    
    return ProfilePageView( profile: profile )
}
