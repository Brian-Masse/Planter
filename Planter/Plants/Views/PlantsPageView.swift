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
    
    @State var srollPosition: CGPoint = .zero
    
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeUpcomingPlantsView() -> some View {
        RoundedContainer("Upcoming", halfCut: true) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(plants) { plant in
                        PlantFullPreviewView( plant: plant)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    @ViewBuilder
    private func makeAllPlants() -> some View {
        RoundedContainer("All Plants") {
            VStack {
                ForEach(plants) { plant in
                    PlantSmallPreviewView(plant: plant)
                }
            }
        }
        
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UniversalText("Planter", size: Constants.UITitleTextSize, font: SpaceGroteskMedium.shared, case: .uppercase)
                .padding(.leading, 10)
            
//            BlurScroll(10, scrollPositionBinding: $srollPosition)
            ScrollView
            {
                VStack(spacing: Constants.UISubPadding) {
                    makeUpcomingPlantsView()
                    
                    makeAllPlants()
                }
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        
        
        
    }
    
}
