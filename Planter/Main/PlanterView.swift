//
//  ContentView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import SwiftUI

struct PlanterView: View {
    
    @ObservedObject var model: PlanterModel = PlanterModel.shared
    
    var body: some View {
       
        VStack {
            
            Spacer()
            
            switch model.state {
            case .authentication:
                Text( "Authentication" )
                
            case .openingRealm:
                Text( "Opening Realm" )
                
            case .creatingProfile:
                Text( "Creating Profile" )
                
            case .app: MainView()
                
            case .error:
                Text( "Error" )
                
            }
            
            Spacer()
            
            Text( model.ownerID )
            
            Spacer()
            
        }
        .task {
            await model.authenticateUser()
        }
        
        
    }
}
