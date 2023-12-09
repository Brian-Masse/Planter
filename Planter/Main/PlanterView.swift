//
//  ContentView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import SwiftUI

@MainActor
struct PlanterView: View {
    
    @ObservedObject var model: PlanterModel = PlanterModel.shared
    
    @MainActor
    private func initializeApp() async {
        await model.authenticateUser()
    }
    
//    MARK: Body
    var body: some View {
       
        VStack {
            
            switch model.appState {
            case .authentication:
                AuthenticationView()
                    .environment(\.realmConfiguration, PlanterModel.realmManager.configuration)
            
            case .openingRealm:
                OpenFlexibleSyncRealmView()
                    .environment(\.realmConfiguration, PlanterModel.realmManager.configuration)
                
            case .creatingProfile:
                Text( "Creating Profile" )
                    .environment(\.realmConfiguration, PlanterModel.realmManager.configuration)
                
            case .app:  
                MainView()
                    .environment(\.realmConfiguration, PlanterModel.realmManager.configuration )
                
            case .error:
                Text( "Error" )
                
            }
        }
        .task { await self.initializeApp() }

    }
}
