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
    
    enum PlantFilter: String, Identifiable {
        
        case myPlants = "My plants"
        case sharedPlants = "shared plants"
        case favorite = "favorite"
        
        var id: String { self.rawValue }
        
        func filterFunction(plant: PlanterPlant) -> Bool {
            switch self {
            case .favorite: return plant.isFavorite
            case .myPlants: return true
            case .sharedPlants: return true
            }
        }
    }
    
//    MARK: Vars
    let plants: [PlanterPlant]
    
    @State var activeFilter: [PlantFilter] = []
    
    @State var srollPosition: CGPoint = .zero
    
//    MARK: Filter Methods
    private var filteredPlants: [PlanterPlant] {
        if activeFilter.isEmpty { return Array(plants) }
        return plants.filter { plant in
            for filter in activeFilter {
                if !filter.filterFunction(plant: plant) { return false }
            }
            return true
        }
    }

    private func toggleFilterItem(_ filter: PlantFilter) {
        if let index = self.filterIsActive( filter ) { activeFilter.remove(at: index) }
        else { activeFilter.append(filter) }
    }
    
    private func filterIsActive(_ item: PlantFilter) -> Int? {
        if let index = activeFilter.firstIndex(where: { filter in filter == item }) { return index }
        return nil
    }
    
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
                ForEach(filteredPlants) { plant in
                    PlantSmallPreviewView(plant: plant)
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeFilterButton( filter: PlantFilter ) -> some View {
        let filterIsActive = filterIsActive(filter) != nil
        
        UniversalText( filter.rawValue, 
                       size: Constants.UIDefaultTextSize,
                       font: Constants.mainFont,
                       case: .uppercase,
                       wrap: false )
            .universalTextStyle(reversed: true)
            .padding(.vertical, Constants.UISubPadding)
            .padding(.horizontal)
            .if(filterIsActive) {   view in view.rectangularBackground( 0, style: .accent ) }
            .if(!filterIsActive) {  view in view.rectangularBackground( 0, style: .primary, reverseStyle: true ) }
            .onTapGesture { withAnimation { toggleFilterItem(filter) }}
    }

    @ViewBuilder
    private func makeFilterSelector() -> some View {
        RoundedContainer("", halfCut: true) {
            ScrollView(.horizontal) {
                HStack {
                    makeFilterButton(filter: .favorite)
                    makeFilterButton(filter: .myPlants)
                    makeFilterButton(filter: .sharedPlants)
                }
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UniversalText("Planter", size: Constants.UIHeaderTextSize, font: SpaceGroteskMedium.shared, case: .uppercase)
                .padding(.leading, 10)
            
//            BlurScroll(10, scrollPositionBinding: $srollPosition)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: Constants.UISubPadding) {
                    makeUpcomingPlantsView()
                    
                    makeFilterSelector()
                    
                    makeAllPlants()
                }
                .padding(.bottom, Constants.UIBottomPagePadding)
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
