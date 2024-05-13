//
//  PlantsSharingPageView.swift
//  Planter
//
//  Created by Brian Masse on 5/12/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct ProfilePicturePreview: View {
    let profile: PlanterProfile
    let size: CGFloat
    
    let image: Image
    
    init( from profile: PlanterProfile, size: CGFloat = 40 ) {
        self.profile = profile
        self.size = size
        self.image = profile.getImage()
    }
    
    var body: some View {
        let image = profile.getImage()
        
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipped()
            .clipShape(Circle())
    }
    
}

struct PlantsSharingPageView: View {
//    MARK: Vars
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    let profile: PlanterProfile
    let plants: [PlanterPlant]
    let friends: [PlanterProfile]
    
    @State private var selectedPlants: [PlanterPlant] = []
    @State private var selectedProfiles: [PlanterProfile] = []
    
//    MARK: Methods
    private func submit() {
        let owners: [String] = selectedProfiles.map { profile in profile.ownerId }
        
        for plant in selectedPlants {
            
            plant.addOwners( owners )
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func togglePlant(_ plant: PlanterPlant) {
        if let index = selectedPlants.firstIndex(of: plant) {
            selectedPlants.remove(at: index)
        } else {
            selectedPlants.append(plant)
        }
    }
    
    private func plantIsSelected( _ plant: PlanterPlant ) -> Bool {
        selectedPlants.contains { selectedPlant in selectedPlant == plant }
    }
    
    private func toggleProfile( _ profile: PlanterProfile ) {
        if let index = selectedProfiles.firstIndex(of: profile) {
            selectedProfiles.remove(at: index)
        } else {
            selectedProfiles.append(profile)
        }
    }
    
    private func profileIsSelected( _ profile: PlanterProfile ) -> Bool {
        selectedProfiles.contains { selectedProfile in selectedProfile == profile }
    }
    
    //    MARK: plantsPreview
    @ViewBuilder
    private func makePrimaryWatererView(_ primaryWaterer: PlanterProfile) -> some View {
        let isPrimaryWaterer = primaryWaterer.ownerId == PlanterModel.shared.ownerID
        
        if isPrimaryWaterer {
            UniversalText( "You are the primary waterer",
                           size: Constants.UISmallTextSize,
                           font: Constants.mainFont,
                           case: .uppercase )
        } else {
            HStack {
                ProfilePicturePreview(from: primaryWaterer)
                
                UniversalText( "\(primaryWaterer.firstName) is the primary owner",
                               size: Constants.UISmallTextSize,
                               font: Constants.mainFont,
                               case: .uppercase )
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func makePlantPreview(plant: PlanterPlant) -> some View {
        if let primaryWatererProfile = PlanterProfile.getProfile(from: plant.primaryWaterer) {
            let selected = self.plantIsSelected(plant)
            
            VStack(alignment: .leading, spacing: 0 ) {
                HStack(alignment: .top) {
                    
                    UniversalText( plant.name, size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                    
                    Spacer()
                    
                    UniversalText( plant.getLastWateredMessage(), size: Constants.UISmallTextSize, font: Constants.mainFont )
                }
                
                if plant.secondaryOwners.count > 0 {
                    UniversalText( "This plant is shared with", size: Constants.UISmallTextSize, font: Constants.mainFont, case: .uppercase )
                        .padding(.bottom, Constants.UISubPadding)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach( plant.secondaryOwners ) { id in
                                if let secondaryOwner = PlanterProfile.getProfile(from: id) {
                                    VStack(spacing: 0) {
                                        ProfilePicturePreview(from: secondaryOwner)
                                        UniversalText( profile.firstName, size: Constants.UISmallTextSize, font: Constants.mainFont )
                                    }
                                }
                            }
                        }.padding(.horizontal, Constants.UISubPadding)
                    }
                    .padding(.bottom, Constants.UISubPadding)
                }
                
                makePrimaryWatererView(primaryWatererProfile)
            }
            .rectangularBackground(style: .primary, cornerRadius: Constants.UIDefaultCornerRadius)
            .onTapGesture { withAnimation { togglePlant(plant) } }
            .opacity(selected ? 1 : 0.2)
        }
    }
    
//    MARK: makeSharableFriendsPreview
    @ViewBuilder
    private func makeSharableFriendsPreview(_ profile: PlanterProfile) -> some View {
        let selected = profileIsSelected(profile)
        
        HStack {
            
            ProfilePicturePreview(from: profile, size: 75)
            
            VStack(alignment: .leading) {
                UniversalText( "\(profile.firstName) \(profile.lastName)", size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase )
                
                UniversalText( "\( PlanterPlant.getNumberOfPlantsSharedWithProfileMessage(profile, plants: plants) )",
                               size: Constants.UISmallTextSize,
                               font: Constants.mainFont)
            }
            
            Spacer()
        }
        .rectangularBackground(style: .primary, cornerRadius: Constants.UIDefaultCornerRadius)
        .onTapGesture { withAnimation { toggleProfile(profile) } }
        .opacity(selected ? 1 : 0.2)
    }
    
//    MARK: Containers
    @ViewBuilder
    private func makePlaintsCollection() -> some View {
        VStack {
            ForEach( plants ) { plant in
                makePlantPreview(plant: plant)
            }
        }
    }
    
    @ViewBuilder
    private func makeProfilesCollection() -> some View {
        VStack {
            ForEach( friends) { friend in
                makeSharableFriendsPreview(friend)
            }
        }
    }
    
    @ViewBuilder
    private func makeSubmitButton() -> some View {
        let submitable: Bool = selectedPlants.count > 0 && selectedProfiles.count > 0
        let peopleText = selectedProfiles.count == 1 ?  "person" : "people"
        let plantsText = selectedPlants.count == 1 ?    "plant" : "plants"
        
        let message = submitable ? "share \(selectedPlants.count) \(plantsText) with \(selectedProfiles.count) \(peopleText)" : "share"
        
        ColoredIconButton(message, icon: "shared.with.you",
                          style: .primary,
                          foregroundStyle: submitable ? .black : nil,
                          backgroundStyle: submitable ? .accent : .primary,
                          wide: true) {
            submit()
        }
                          .opacity(submitable ? 1 : 0.5)
    }
    

//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText( "share plants", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                .padding(.bottom)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    
                    UniversalText( "Which plants would you like to share?", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                    
                    makePlaintsCollection()
                    
                    UniversalText( "Who would you like to share them with?", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                    makeProfilesCollection()
                }
            }
       
            makeSubmitButton()
        }
        .padding(.horizontal, Constants.UISubPadding)
        .background(Colors.getSecondaryBase(from: colorScheme))
    }
}
