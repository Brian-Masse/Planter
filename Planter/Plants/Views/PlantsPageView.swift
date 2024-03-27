//
//  PlantsPageView.swift
//  Planter
//
//  Created by Brian Masse on 3/27/24.
//

import Foundation
import SwiftUI
import UIUniversals
import RealmSwift

struct PlantsPageView: View {
    
//    MARK: Vars
    
    @ObservedResults(PlanterPlant.self) var plants
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeUpcomingPlantsView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            UniversalText("Upcomng", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase)
                .universalTextStyle()
            
            ScrollView(.horizontal) {
                HStack() {
                    ForEach(plants) { plant in
                        PlantFullPreviewView( plant: plant)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .rectangularBackground(10, style: .secondary, corners: [.topLeft, .bottomLeft])
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            UniversalText("Plants", size: Constants.UITitleTextSize, font: SpaceGroteskMedium.shared)
                .padding(.leading, 10)
            
            makeUpcomingPlantsView()
            
            Spacer()
        }
        
        
        
    }
    
}
