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
        
        VStack(alignment: .leading) {
         
            ForEach( plants ) { plant in
                
                Text(plant.name)
                
            }
            
            Text("hello")
                .onTapGesture {
                    
                    let plant = PlanterPlant(ownerID: PlanterModel.shared.ownerID, name: "test plant")
                    
                    RealmManager.addObject( plant )
                    
                }
        }
        
        
    }
}

