//
//  CalendarPageView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import RealmSwift

@MainActor
struct CalendarPageView: View {

    enum FilteredPlantKey: String, CaseIterable, Identifiable {
        case overdue
        case today
        case next
        
        var id: String {
            self.rawValue
        }
    }

//    MARK: Vars
    static let upNextPlantCount: Int = 100
    
    @State var showingPlantCreationView: Bool = false
    
    let plants: [PlanterPlant]
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader()  -> some View {
        VStack(alignment: .leading) {
            HStack {
                UniversalText( "Planter.", size: Constants.UITitleTextSize, font: Constants.titleFont )
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 7)
            
            UniversalText( PlanterModel.shared.ownerID, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                .padding(.horizontal, 7)
        }
    }
    
    
    @ViewBuilder
    private func makeTodayView(from plants: [PlanterPlant]) -> some View {
        ZStack {
            if !plants.isEmpty {
                Rectangle()
                    .universalForegroundColor()
                    .cornerRadius(Constants.UILargeCornerRadius, corners: [.topLeft, .bottomRight])
                    .ignoresSafeArea()
                    .padding(-7)
                
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        PlantPreviewView(plant: plants.first!, layout: .full)
                        
                        VerticalLayout() {
                            UniversalText( "Today", size: Constants.UITitleTextSize, font: Constants.titleFont, wrap: false)
                                .textCase(.uppercase)
                        }
                        .rotationEffect(.degrees(90))
                        .padding(.horizontal, -10)
                    }
                    
                    VStack {
                        if plants.count > 1 {
                            ForEach( 1..<plants.count, id: \.self ) { i in
                                PlantPreviewView(plant: plants[ i ], layout: .full)
                                
                            }
                        }
                    }
                }.padding(7)
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private func makeUpNextView(from plants: [PlanterPlant]) -> some View {
        VStack(alignment: .leading, spacing: 7 ) {
            if !plants.isEmpty {
                HStack(alignment: .top) {
                    
                    VerticalLayout() {
                        UniversalText( "Up Next", size: Constants.UITitleTextSize, font: Constants.titleFont, wrap: false)
                            .textCase(.uppercase)
                    }
                    .rotationEffect(.degrees(-90))
                    .padding(.horizontal, -10)
                    
                    VStack {
                        ForEach( 0...1, id: \.self ) { i in
                            if i < plants.count {
                                PlantPreviewView(plant: plants[i], layout: .half)
                            }
                        }
                    }
                }
                
                if plants.count > 2 {
                    ForEach( 2..<plants.count, id: \.self ) { i in
                        PlantPreviewView(plant: plants[ i ], layout: .half )
                    }
                }
            }
        }
        .padding(.horizontal, 7)
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            let todayPlants = plants.filter { plant in
                plant.getNextWateringDate().matches(.now, to: .day)
            }
            
            let upNextPlants = plants.filter { plant in
                let date = plant.getNextWateringDate()
                return !date.matches(.now, to: .day) && date > .now
            }
        
            makeHeader()
            
            LargeTextButton("hello world", at: 30, aspectRatio: 2) {
                print("hello")
            }
            
//            ScrollView(.vertical) {
                VStack {
                    makeTodayView(from: todayPlants)
                    
                    makeUpNextView(from: upNextPlants)
                    
                    Spacer()
                    
                    LargeRoundedButton("create plant", icon: "plus", wide: true) {
                        showingPlantCreationView = true
                    }
                    .padding(7)
                }
                .blurScroll(20)
//            }
        }
        .sheet(isPresented: $showingPlantCreationView) { PlantCreationScene() }
    }
}
