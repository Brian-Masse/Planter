//
//  PlanterModel.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift
import SwiftUI

var inDev: Bool = true

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
    static let photoManager: PhotoManager = PhotoManager()
    static let shared: PlanterModel = PlanterModel()
    
    @Published var offline: Bool = false
    @Published var state: AppState = .authentication
    
    var ownerID: String { PlanterModel.realmManager.user?.id ?? "no user" }
    
    @Published var activeColor: Color = Colors.main
    
    
//    MARK: Flow
    
    @MainActor
    func authenticateUser() async {
        
        self.state = .authentication
        
        await PlanterModel.realmManager.signInAnonymously()
        if PlanterModel.realmManager.user != nil {
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
