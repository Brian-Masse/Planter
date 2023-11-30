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
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .universalForegroundColor()
                    .cornerRadius(Constants.UILargeCornerRadius, corners: [.topLeft, .bottomRight])
                    .padding(-10)
                
                HStack {
                    VStack(alignment: .leading) {
                        ForEach( plants ) { plant in
                            
                            PlantPreviewView(plant: plant)
                        }
                    }
                    
//                    UniversalText( "Today", size: Constants.UITitleTextSize, font: Constants.titleFont, wrap: false)
//                        .textCase(.uppercase)
//                        .rotationEffect(.degrees(90))
                }
            }.frame(maxWidth: geo.size.width)
        }
    }
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
                        
            UniversalText( "Planter.", size: Constants.UITitleTextSize, font: Constants.titleFont )
                .textCase(.uppercase)
            
            UniversalText( PlanterModel.shared.ownerID, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
            
            ScrollView(.vertical) {
                makeTodayView()
               
                
                //            ForEach( FilteredPlantKey.allCases, id: \.self ) { content in
                //
                //                if let list = filteredPlants[ content.rawValue ] {
                //                    if list.count != 0 {
                //
                //                        UniversalText( content.rawValue,
                //                                       size: Constants.UISubHeaderTextSize,
                //                                       font: Constants.titleFont )
                //
                //                        ForEach( list ) { plant in
                //
                //                            PlantPreviewView(plant: plant)
                //                        }
                //
                //                    }
                //                }
                //            }
                
                Spacer()
            }
            
            LargeRoundedButton("create plant", icon: "plus") {
                showingPlantCreationView = true
            }
            
        }
        .onAppear { self.filteredPlants = self.filterPlants() }
        .onChange(of: self.plants) { oldValue, newValue in
            self.filteredPlants = self.filteredPlants
        }
        
        
        .sheet(isPresented: $showingPlantCreationView) { PlantCreationScene() }
    }
}
