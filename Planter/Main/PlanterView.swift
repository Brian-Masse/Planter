//
//  ContentView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import SwiftUI

@MainActor
struct PlanterView: View {
    
//    MARK: State
    enum AppState: Int {
        
        case authentication
        case openingRealm
        case creatingProfile
        case app
        case error
        
    }
    
    var model: PlanterModel = PlanterModel.shared
    
    @State var appState: AppState = .authentication
    
    @MainActor
    private func initializeApp() async {
        
        self.appState = .authentication
        await model.authenticateUser()
        if !model.getAuthenticationCompletion() {
            self.appState = .error
            return
        }
        
        self.appState = .openingRealm
        await model.openRealm()
        if !model.getOpenRealmCompletion() {
            self.appState = .error
            return
        }
        
        self.appState = .app
    }
    
    @State var toggle: Bool = false
    
//    MARK: Body
    var body: some View {
       
        VStack {
            
            switch appState {
            case .authentication:
                Text( "Authentication" )
                
            case .openingRealm:
                Text( "Opening Realm" )
                
            case .creatingProfile:
                Text( "Creating Profile" )
                
            case .app:  MainView()
                
            case .error:
                Text( "Error" )
                
            }
        }
        .task { await self.initializeApp() }

    }
}
