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
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            
            let favoriteMessage =  !plant.isFavorite ? "Favorite \nthis plant" : "Favorite\nplant"
            
            ResizableIcon(plant.isFavorite ? "staroflife.fill" : "staroflife", size: Constants.UISubHeaderTextSize)
            
            UniversalText( favoriteMessage,
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           textAlignment: .trailing,
                           lineSpacing: -10)
            .padding(.leading, 90)
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
    let plant: PlanterPlant

    let image: Image
    
    init(plant: PlanterPlant) {
        self.plant = plant

        self.image = PhotoManager.decodeImage(from: plant.coverImage) ?? Image("fern")
    }
    
//    MARK: Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack() {
                UniversalText(plant.getWateringMessage(),
                              size: Constants.UISubHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              lineSpacing: -10)
                .padding(.trailing, Constants.UISubPadding)
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: ViewConstants.width - (2 * ViewConstants.padding), height: 116)
                    .clipped()
                
                PlantFavoriteToggle(plant: plant)
            }
            
            LargeTextButton("WA TER", at: 30, aspectRatio: 1.4,
                            cornerRadius: Constants.UILargeCornerRadius,
                            arrowDirection: .up,
                            style: .secondary,
                            reverseStyle: true) {
                RealmManager.updateObject(plant) { thawed in
                    thawed.dateLastWatered = Date.now - ( 5 * Constants.DayTime )
                }
            }.offset(x: -15)
        }
        .universalTextStyle(reversed: true)
        .frame(minWidth: ViewConstants.width - (2 * ViewConstants.padding))
        .rectangularBackground(ViewConstants.padding, style: .primary, reverseStyle: true)
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
