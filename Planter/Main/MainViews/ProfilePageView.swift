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
//    for the mathced geometry effect
    @Namespace var profilePageNameSpace
    private let pictureId = "picture"
    private let textId = "text"
    private let subTextId = "subText"
    private let iconId = "iconId"
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var halfScroll: Bool = false
    @State var scrollPosition: CGPoint = .zero
    
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
        let profilePictureSize: CGFloat = halfScroll ? 75 : 400
        
        if !halfScroll {
            VStack {
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: profilePictureSize)
                    .clipShape( RoundedRectangle(cornerRadius: 0) )
            }
            .matchedGeometryEffect(id: pictureId, in: profilePageNameSpace)
        } else {
            VStack {
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: profilePictureSize, height: profilePictureSize)
                    .clipShape( RoundedRectangle(cornerRadius: 100) )
                    .shadow(color: .white.opacity(0.1), radius: 15, y: 5)
                    .shadow(color: .white.opacity(0.2), radius: 70, y: 10)
            }
            .matchedGeometryEffect(id: pictureId, in: profilePageNameSpace)
        }
    }
    
    @ViewBuilder
    private func makeProfileHeaderDescription() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                UniversalText( "\(profile.firstName) \(profile.lastName)",
                               size: halfScroll ? Constants.UISubHeaderTextSize : Constants.UIHeaderTextSize,
                               font: Constants.titleFont, case: .uppercase )
                .frame(minWidth: halfScroll ? 0 : 300, alignment: .leading)
                .matchedGeometryEffect(id: textId, in: profilePageNameSpace)
                
                UniversalText( "Planter Member since \( profile.dateJoined.formatted(date: .abbreviated, time: .omitted) )",
                               size: Constants.UISmallTextSize,
                               font: Constants.mainFont)
                    .opacity(0.7)
                    .matchedGeometryEffect(id: subTextId, in: profilePageNameSpace)
            }
            Spacer()
            
            ColoredIconButton(icon: "pencil") { }
                .matchedGeometryEffect(id: iconId, in: profilePageNameSpace)
        }
    }
    
    @ViewBuilder
    private func makePageHeader() -> some View {
        if halfScroll {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    makeProfilePicture()
                        .padding(.trailing, Constants.UISubPadding)
                    
                    makeProfileHeaderDescription()
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, Constants.UISubPadding)
        } else {
            ZStack(alignment: .bottom) {
                makeProfilePicture()
                    .overlay( LinearGradient(colors: [.clear, Colors.getBase(from: colorScheme)],
                                             startPoint: .init(x: 0.5, y: 0.5),
                                             endPoint: .bottom)
                    )
                
                makeProfileHeaderDescription()
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
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
                    
                    makeContactField(label: "Birthday",
                                     content: profile.birthday.formatted(date: .abbreviated, time: .omitted))
                    
                }.padding(.vertical, Constants.UISubPadding)
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            makePageHeader()
            
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
                    withAnimation { self.halfScroll = true }
                } else if newValue.y > 10 {
                    withAnimation { self.halfScroll = false }
                }
            }
//            ScrollView(.vertical) {
//            }
        }
        .ignoresSafeArea()
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
