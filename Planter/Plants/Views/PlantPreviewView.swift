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
        .universalTextStyle(reversed: true)
        .padding(.horizontal, 10)
        .rectangularBackground(10, style: .primary, reverseStyle: true)
    }
}
