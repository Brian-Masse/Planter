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

struct PlantFullPreviewView: View {
    
//    MARK: Constants
    private struct ViewConstants {
        static let width: CGFloat = 300
        static let padding: CGFloat = 20
    }
    
//    MARK: vars
    @ObservedRealmObject var plant: PlanterPlant

    let image: Image
    
    init(plant: PlanterPlant) {
        self.plant = plant

        self.image = PhotoManager.decodeImage(from: plant.coverImage) ?? Image("fern")
    }
    
//    MARK: Body
    var body: some View {
        
        let favoriteMessage =  !plant.isFavorite ? "Favorite \nthis plant" : "Favorite\nplant"
        
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
                
                VStack(alignment: .trailing, spacing: 0) {
                    
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
