//
//  SocialPageView.swift
//  Planter
//
//  Created by Brian Masse on 3/27/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct SocialPageView: View {
    
    let profile: PlanterProfile
    
    let plants: [PlanterPlant]
    
    let friends: [PlanterProfile]
    
    @State private var showingPlantsSharingPage: Bool = false
    
    init(profile: PlanterProfile, plants: [PlanterPlant]) {
        self.profile = profile
        self.plants = plants
        self.friends = Array(profile.friends)
    }
    
    
//    MARK: ViewBuilders
    
    
//    MARK: Friends Preview
    @ViewBuilder
    private func makeFriendPreview(profile: PlanterProfile) -> some View {
        
        let image = profile.getImage()
        let imageHeight: CGFloat = 125
        
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageHeight, height: imageHeight)
                .clipped()
                .clipShape( Circle() )
            
            UniversalText( "\(profile.firstName) \(profile.lastName)",
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.titleFont, case: .uppercase )
            
            UniversalText( "Planter Member since \n\(profile.dateJoined.formatted(date: .abbreviated, time: .omitted))",
                           size: Constants.UISmallTextSize,
                           font: Constants.mainFont,
                           textAlignment: .center)
            .opacity(0.8)
        }.rectangularBackground(style: .primary)
    }
    
    @ViewBuilder
    private func makeFriendsCarosel() -> some View {
        let profile = PlanterProfile(ownerId: "ownerID",
                                            firstName: "Brian",
                                            lastName: "Masse",
                                            userName: "bmasse23",
                                            email: "brianm25it@gmail.com",
                                            phoneNumber: 17813153811,
                                            birthday: Date.now)
    
        let buddies = [ profile, profile, profile ]
        
        RoundedContainer("Plant Buddies", halfCut: true) {
            VStack(alignment: .leading) {
                UniversalText( "\(friends.count) buddies", size: Constants.UISmallTextSize, font: Constants.titleFont )
                    .padding(.leading, Constants.UISubPadding)
                    .opacity(0.8)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach( friends ) { buddy in
                            makeFriendPreview(profile: buddy)
                                .padding(.horizontal, 2)
                        }
                    }
                }
            }
        }
    }
    
//    MARK: Buttons
    @ViewBuilder
    private func makeButtons() -> some View {
        HStack {
            ColoredIconButton("Share plants", icon: "shared.with.you",
                              foregroundStyle: .black,
                              backgroundStyle: .accent,
                              size: Constants.UIDefaultTextSize,
                              wide: true) { showingPlantsSharingPage = true }
            
            ColoredIconButton("Find buddies", icon: "magnifyingglass",
                              foregroundStyle: .black,
                              backgroundStyle: .accent,
                              size: Constants.UIDefaultTextSize,
                              wide: true) {}
        }
    }
    
//    MARK: PlantCarousels
    @ViewBuilder
    private func makeSharedPlants() -> some View {
        let sharedPlants = plants.filter { plant in
            plant.secondaryOwners.count > 0 && plant.primaryOwnerId == PlanterModel.shared.ownerID
        }
        
        RoundedContainer("Shared Plants", halfCut: true) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach( sharedPlants ) { plant in
                        SharedPlantPreviewView(plant: plant, accent: false)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeSharedWithMePlants() -> some View {
        let sharedWithMePlants = plants.filter { plant in
            plant.primaryOwnerId != PlanterModel.shared.ownerID
        }
        
        RoundedContainer("plants shared with you") {
            VStack {
                ForEach( sharedWithMePlants ) { plant in
                    SharedWithMePlantPreviewView(plant: plant)
                }
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            UniversalText( "social", size: Constants.UIHeaderTextSize, font: Constants.titleFont, case: .uppercase )
            
            ScrollView(.vertical) {
                makeFriendsCarosel()
        
                makeButtons()
                
                makeSharedPlants()
                
                makeSharedWithMePlants()
                
                Text("")
                    .padding(.bottom, Constants.UIBottomPagePadding)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingPlantsSharingPage) {
            let filteredPlants = plants.filter { plant in
                plant.primaryOwnerId == PlanterModel.shared.ownerID
            }
            
            PlantsSharingPageView(profile: profile,
                                  plants: filteredPlants,
                                  friends: friends)
        }
    }
}

#Preview {
    let profile = PlanterProfile(ownerId: "6574ccd5067e446740db69e6",
                                        firstName: "Brian",
                                        lastName: "Masse",
                                        userName: "bmasse23",
                                        email: "brianm25it@gmail.com",
                                        phoneNumber: 17813153811,
                                        birthday: Date.now)
    
    
    let plant = PlanterPlant(ownerID: "6574ccd5067e446740db69e6",
                             name: "fern1",
                             roomName: "bedroom",
                             notes: "notes",
                             wateringInstructions: "",
                             wateringAmount: 4,
                             wateringInterval: 4,
                             statusImageFrequency: 4,
                             statusNotesFrequency: 4, coverImageData: Data())
    
    let plant2 = PlanterPlant(ownerID: "6574ccd5067e446740db69e6",
                             name: "fern2",
                             roomName: "bedroom",
                             notes: "notes",
                             wateringInstructions: "",
                             wateringAmount: 4,
                             wateringInterval: 4,
                             statusImageFrequency: 4,
                             statusNotesFrequency: 4, coverImageData: Data())
    
    return SocialPageView(profile: profile, plants: [plant, plant2])
}
