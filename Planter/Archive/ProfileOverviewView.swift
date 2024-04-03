//
//  ProfileOverviewView.swift
//  Planter
//
//  Created by Brian Masse on 12/11/23.
//

import Foundation
import SwiftUI
import UIUniversals

struct ProfileOverviewView: View {
    
//    MARK: Vars
    let profile: PlanterProfile
    let image: Image
    
    @State var showingEditingView: Bool = false
    
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
                    .foregroundStyle(Colors.lightAccent)
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
            
            UniversalText( "\(profile.userName) | \(profile.getPublicityString())",
                           size: Constants.UISmallTextSize,
                           font: Constants.titleFont )
            .padding(.bottom, 7)
            
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
                showingEditingView = true
                
            }
            .offset(y: -50)
            
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            makeHeader()
            
            makeOverviewBody()
            
            Spacer()
            
            HStack {
                Spacer()
                UniversalText( PlanterModel.shared.ownerID, size: Constants.UISmallTextSize, font: Constants.mainFont )
                Spacer()
            }
        }
        .sheet(isPresented: $showingEditingView) {
            
//            StyledPhotoPicker {
//                Text("choose")
//            }
            
            Text("submit")
                .onTapGesture {
                    
                    profile.setProfilePicture(to: PlanterModel.photoManager.retrievedImage! )
                }
            
        }
    }
}
