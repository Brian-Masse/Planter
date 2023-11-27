//
//  PlanterModel.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift
import SwiftUI


class PlanterModel: ObservableObject {
    
//    MARK: State
    enum AppState: Int {
        
        case authentication
        case openingRealm
        case creatingProfile
        case app
        case error
        
    }
    
//    MARK: vars
    static let realmManager: RealmManager = RealmManager()
    static let shared: PlanterModel = PlanterModel()
    
    @Published var offline: Bool = true
    @Published var state: AppState = .authentication
    
    var ownerID: String { PlanterModel.realmManager.user?.id ?? "no user" }
    
    
//    MARK: Flow
    
    @MainActor
    func authenticateUser() async {
        
        self.state = .authentication
        
        await PlanterModel.realmManager.signInAnonymously()
//        if PlanterModel.realmManager.user != nil {
        if PlanterModel.realmManager.checkSignedIn() {
            self.state = .openingRealm
            await self.openRealm()
        } else {
            self.state = .error
        }
    }
    
    @MainActor
    func openRealm() async {
     
        self.state = .openingRealm
        
        await PlanterModel.realmManager.openRealm()
        if PlanterModel.realmManager.realm != nil {
            self.state = .app
            
        } else {
            self.state = .error
        }
            
        
    }
}
