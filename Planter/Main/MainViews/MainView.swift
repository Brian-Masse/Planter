//
//  MainView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct MainView: View {
    
    @ObservedObject var model: PlanterModel = PlanterModel()
    
    @ObservedResults( PlanterPlant.self ) var plants
    
    var body: some View {
        
        let arrPlants = Array( plants )
        
        VStack(alignment: .leading) {
         
            CalendarPageView(plants: arrPlants)
        }
        .padding(7)
        .padding(.bottom)
        .universalBackground()
    }
}

