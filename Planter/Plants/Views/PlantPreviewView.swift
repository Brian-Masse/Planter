//
//  PlantPreviewView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import UIUniversals
import RealmSwift

//MARK: Convenience Structs
struct PlantFavoriteToggle: View {
    
    let plant: PlanterPlant
    let alignment: HorizontalAlignment
    
    init( plant: PlanterPlant, alignment: HorizontalAlignment = .trailing ) {
        self.plant = plant
        self.alignment = alignment
    }
    
    private func getTextAlignment() -> TextAlignment {
        alignment == .trailing ? .trailing : .leading
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            
            let favoriteMessage =  !plant.isFavorite ? "Favorite \nthis plant" : "Favorite\nplant"
            
            ResizableIcon(plant.isFavorite ? "staroflife.fill" : "staroflife", size: Constants.UISubHeaderTextSize)
            
            UniversalText( favoriteMessage,
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           textAlignment: getTextAlignment(),
                           lineSpacing: -10)
//            .padding(.leading, 90)
        }.onTapGesture { plant.toggleFavorite() }
    }
}

//MARK: PlantFullPreviewView
struct PlantFullPreviewView: View {
    
//    MARK: Constants
    private struct ViewConstants {
        static let width: CGFloat = 300
        static let padding: CGFloat = 20
    }
    
//    MARK: vars
    @State var showingPlantView: Bool = false
    @State var showingPlantwateringScene: Bool = false
    
    let plant: PlanterPlant

    let image: Image
    
    init(plant: PlanterPlant) {
        self.plant = plant
        self.image = plant.getImage()
    }
    
//    MARK: Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack() {
                HStack {
                    UniversalText(plant.getWateringMessage(),
                                  size: Constants.UISubHeaderTextSize,
                                  font: Constants.titleFont,
                                  case: .uppercase,
                                  lineSpacing: -10)
                    .padding(.trailing, Constants.UISubPadding)
                    Spacer()
                }
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: ViewConstants.width - (2 * ViewConstants.padding), height: 116)
                    .clipped()
                
                HStack {
                    Spacer()
                    PlantFavoriteToggle(plant: plant)
                }
            }
            
            if plant.wateringToday() {
                LargeTextButton("WA TER", at: 30, aspectRatio: 1.4,
                                cornerRadius: Constants.UILargeCornerRadius,
                                arrowDirection: .up,
                                style: .secondary,
                                reverseStyle: true) {
                    showingPlantwateringScene = true
                }.offset(x: -15)
            }
        }
        .universalTextStyle(reversed: true)
        .frame(minWidth: ViewConstants.width - (2 * ViewConstants.padding))
        .rectangularBackground(ViewConstants.padding, style: .primary, reverseStyle: true)
        .onTapGesture { showingPlantView = true }
        
        .fullScreenCover(isPresented: $showingPlantView) {
            PlantView(plant: plant)
        }
        .fullScreenCover(isPresented: $showingPlantwateringScene) {
            PlantWateringScene(plant: plant)
        }
    }
}


//MARK: PlantSmallPreviewView
struct PlantSmallPreviewView: View {
    
    let plant: PlanterPlant
    let accent: Bool
    
    init(plant: PlanterPlant, accent: Bool = false) {
        self.plant = plant
        self.accent = accent
    }
    
    @State private var showingPlantView: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    UniversalText( plant.name, size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
                    
                    UniversalText( plant.getLastWateredMessage(), size: Constants.UISmallTextSize, font: Constants.mainFont )
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            PlantFavoriteToggle(plant: plant)
        }
        .universalTextStyle(reversed: accent)
        .padding(.horizontal, 10)
        .rectangularBackground(10, style: .primary, reverseStyle: accent)
        .onTapGesture { showingPlantView = true }
        .fullScreenCover(isPresented: $showingPlantView) {
            PlantView(plant: plant)
        }
    }
}


struct PrimaryWatererLabel: View {
    
    let plant: PlanterPlant
    let primaryWatererOwnerId: String
    
    var body: some View {
        if let primaryWaterer = PlanterProfile.getProfile(from: plant.primaryWaterer) {
            
            let isPrimaryWaterer = primaryWaterer.ownerId == PlanterModel.shared.ownerID
            
            let message = isPrimaryWaterer ? "you are the \nprimary waterer" : "\(primaryWaterer.firstName) is the \nprimary waterer"
            
            HStack(spacing: Constants.UISubPadding) {
                VStack(alignment: .trailing, spacing: 0) {
                    ResizableIcon( isPrimaryWaterer ? "drop.fill" : "drop", size: Constants.UIDefaultTextSize )
                    
                    UniversalText( message, size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase, textAlignment: .trailing )
                }
                if !isPrimaryWaterer {
                    ProfilePicturePreview(from: primaryWaterer, size: 35)
                }
            }
        }
    }
}

//MARK: SharedPlantPreviewView
struct SharedPlantPreviewView: View {
    @Environment( \.colorScheme ) var colorScheme
    
    let plant: PlanterPlant
    let accent: Bool
    
    let image: Image
    
    init( plant: PlanterPlant, accent: Bool = false ) {
        self.plant = plant
        self.accent = accent
        self.image = plant.getImage()
    }
    
    @ViewBuilder
    private func makeSharedCarousel() -> some View {
        let count = plant.secondaryOwners.count
        let peopleText = count == 1 ? "person" : "people"
     
        VStack(alignment: .leading, spacing: 0) {
            UniversalText( "your \(plant.name) is shared with \(count) \(peopleText)",
                           size: Constants.UIDefaultTextSize,
                           font: Constants.titleFont,
                           case: .uppercase)
                .padding(.trailing, 20)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach( plant.secondaryOwners ) { id in
                        if let secondaryOwner = PlanterProfile.getProfile(from: id) {
                            ProfilePicturePreview(from: secondaryOwner, size: 35)
                        }
                    }
                }
                .padding(.leading, Constants.UISubPadding)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                PrimaryWatererLabel(plant: plant, primaryWatererOwnerId: plant.primaryWaterer)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 220, height: 100)
                .clipped()
            
            makeSharedCarousel()
        }
        .padding(Constants.UISubPadding)
        .frame(width: 230, height: 320)
        .universalTextStyle(reversed: accent)
        .rectangularBackground( style: .primary, reverseStyle: accent )
        
    }
}


//MARK: SharedWithMePlantPreviewView
struct SharedWithMePlantPreviewView: View {
    
    let plant: PlanterPlant
    
    var body: some View {
        
        if let owner = PlanterProfile.getProfile(from: plant.primaryOwnerId) {
            ZStack(alignment: .bottomLeading) {
                VStack(alignment: .leading) {
                    UniversalText( "\(owner.firstName)'s \(plant.name)", size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase )
                    UniversalText( "\(plant.getLastWateredMessage())", size: Constants.UISmallTextSize, font: Constants.mainFont )
                }.padding(.bottom, 65)
                
                HStack {
                    Spacer()
                    PrimaryWatererLabel(plant: plant, primaryWatererOwnerId: plant.primaryWaterer)
                }
            }
            .universalTextStyle()
            .rectangularBackground( style: .primary )
        }
    }
}
