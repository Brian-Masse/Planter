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
    
    
    enum PlantCreationScene: String, CaseIterable, Identifiable {
        case page1
        case page2
        case page3
        
        var id: String {
            self.rawValue
        }
    }
    
    
    @State var plantScene: PlantCreationScene = .page1
    
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
    
    
//    MARK: Vars
    static let upNextPlantCount: Int = 2
    let plants: [PlanterPlant]
    
    @State var filteredPlants: Dictionary<String, [PlanterPlant]> = Dictionary()
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            UniversalText( "Planter.", size: Constants.UITitleTextSize, font: Constants.titleFont )

            UniversalText( PlanterModel.shared.ownerID, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
            
            HStack { Spacer() }
            
            ForEach( FilteredPlantKey.allCases, id: \.self ) { content in
                
                if let list = filteredPlants[ content.rawValue ] {
                    if list.count != 0 {
                        
                        UniversalText( content.rawValue,
                                       size: Constants.UISubHeaderTextSize,
                                       font: Constants.titleFont )
                        
                        ForEach( list ) { plant in
                            
                            UniversalText( plant.name, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                        }
                        
                    }
                }
            }
            
            Spacer()
            
            LargeRoundedButton("create plant", icon: "plus") {
                showingPlantCreationView = true
            }
            
        }
        .onAppear { self.filteredPlants = self.filterPlants() }
        .sheet(isPresented: $showingPlantCreationView) {
            
            PlanterScene($plantScene) { scene in
                Text("idk")
            }
            
        }
    }
}
