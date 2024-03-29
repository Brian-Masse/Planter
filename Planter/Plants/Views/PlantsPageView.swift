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
    }
    
//    MARK: Vars
    @ObservedResults(PlanterPlant.self) var plants
    
    @State var activeFilter: [PlantFilter] = []
    @State var filteredPlants: [PlanterPlant] = []
    
    @State var srollPosition: CGPoint = .zero
    
    @MainActor
    init() {
        self.filteredPlants = Array(plants)
    }
    
//    MARK: Struct Methods
    
    @MainActor
    private func updateFilter( to filter: PlantFilter ) async {
        let activeFilter    = await toggleFilterItem(filter)
        let newPlants       = await getNewPlants(to: activeFilter)

        self.activeFilter = activeFilter
        self.filteredPlants = newPlants
    }
    
    private func getNewPlants(to filter: [PlantFilter]) async -> [PlanterPlant] {
        if filter.count == 0 { return Array(plants) }
        else {
            let filterFavorite = filter.contains(where: { filter in filter == .favorite })
            
            return plants.compactMap { plant in
                (plant.isFavorite && filterFavorite) ? plant : nil
            }
        }
    }
    
    private func toggleFilterItem(_ filter: PlantFilter) async -> [PlantFilter] {
        var filterCopy = activeFilter
        if let index = self.filterIsActive( filter ) { filterCopy.remove(at: index)
        } else { filterCopy.append(filter) }
        return filterCopy
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
            .if(!filterIsActive) {  view in view.rectangularBackground( 0, style: .secondary, reverseStyle: true ) }
            .onTapGesture {
                Task { await updateFilter(to: filter) }
            }
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
            UniversalText("Planter", size: Constants.UITitleTextSize, font: SpaceGroteskMedium.shared, case: .uppercase)
                .padding(.leading, 10)
            
//            BlurScroll(10, scrollPositionBinding: $srollPosition)
            ScrollView
            {
                VStack(spacing: Constants.UISubPadding) {
                    makeUpcomingPlantsView()
                    
                    makeFilterSelector()
                    
                    makeAllPlants()
                }
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        
        
        
    }
    
}
