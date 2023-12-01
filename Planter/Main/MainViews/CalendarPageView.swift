//
//  CalendarPageView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import RealmSwift

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
    @State var showingPlantCreationView: Bool = false
    @State var showingPlantView: Bool = false
    
//    MARK: Struct Methods
    private func filterPlants() -> Dictionary< String, [PlanterPlant] > {
        
        var dic: Dictionary<String, [PlanterPlant]> = Dictionary()
        
        for key in FilteredPlantKey.allCases {
            dic[key.rawValue] = []
        }
        
        for plant in plants {
            let nextWater = plant.getNextWateringDate()
            if nextWater.matches(.now, to: .day) {
                dic[ FilteredPlantKey.today.rawValue ]!.append( plant )
            } else if nextWater < .now {
                dic[ FilteredPlantKey.overdue.rawValue ]!.append( plant )
            } else if dic[FilteredPlantKey.next.rawValue]!.count < CalendarPageView.upNextPlantCount {
                dic[ FilteredPlantKey.next.rawValue ]!.append(plant)
            }
        }
        
        return dic
    }
    
    private func setFilteredPlants() {
        
    }
    
    
//    MARK: Vars
    static let upNextPlantCount: Int = 100
    let plants: [PlanterPlant]
    
    @State var filteredPlants: Dictionary<String, [PlanterPlant]> = Dictionary()
    
//    MARK: ViewBuilders
    private func makeTodayView() -> some View {
        ZStack {
            Rectangle()
                .universalForegroundColor()
                .cornerRadius(Constants.UILargeCornerRadius, corners: [.topLeft, .bottomRight])
                .ignoresSafeArea()
                .padding(-7)
            
            VStack(spacing: 0) {
                if !plants.isEmpty {
                    HStack(alignment: .top) {
                        PlantPreviewView(plant: plants.first!, 
                                         showingPlantView: $showingPlantView)
                        
                        VerticalLayout() {
                            UniversalText( "Today", size: Constants.UITitleTextSize, font: Constants.titleFont, wrap: false)
                                .textCase(.uppercase)
                        }
                        .rotationEffect(.degrees(90))
                        .padding(.leading, -10)
                    }
                    .padding(.bottom)
                    
                    VStack {
                        if plants.count > 1 {
                            ForEach( 1..<plants.count, id: \.self ) { i in
                                PlantPreviewView(plant: plants[ i ],
                                                 showingPlantView: $showingPlantView)
                                
                            }
                        }
                    }
                }
            }.padding(7)
        }
        .padding(.vertical)
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
                        
            HStack {
                UniversalText( "Planter.", size: Constants.UITitleTextSize, font: Constants.titleFont )
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 7)
            
            UniversalText( PlanterModel.shared.ownerID, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                .padding(.horizontal, 7)
            
            ScrollView(.vertical) {
                makeTodayView()
                
                Spacer()
                
                LargeRoundedButton("create plant", icon: "plus", wide: true) {
                    showingPlantCreationView = true
                }
                .padding(7)
            }
            
        }
        .onAppear { self.filteredPlants = self.filterPlants() }
        .onChange(of: self.plants) { oldValue, newValue in
            self.filteredPlants = self.filteredPlants
        }
        
        
//        .sheet(isPresented: $showingPlantCreationView) { PlantCreationScene() }
    }
}
