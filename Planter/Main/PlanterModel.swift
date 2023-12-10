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
    
//    MARK: vars
    static let realmManager: RealmManager = RealmManager()
    static let photoManager: PhotoManager = PhotoManager()
    static var profile: PlanterProfile { PlanterModel.shared.activeProfile! }
    static var shared: PlanterModel = PlanterModel()
    
    var offline: Bool = false
    
    var ownerID: String { PlanterModel.realmManager.user?.id ?? "no user" }
    private(set) var activeProfile: PlanterProfile? = nil
    
    @Published var activeColor: Color = Colors.main
    
//    MARK: State
    enum AppState: Int {
        
        case authentication
        case openingRealm
        case creatingProfile
        case app
        case error
        
    }
    
    @Published private(set) var appState: AppState = .authentication
    
    func setProfile( _ profile: PlanterProfile? ) {
        self.activeProfile = profile
    }
    
//    MARK: Flow
//    These functions will be called after the work of either authentication or open realm is performed
//    Their value will be used to progress the app state accordingly
    func getAuthenticationCompletion() -> Bool {
        PlanterModel.realmManager.checkSignedIn()
    }
    
    func getOpenRealmCompletion() -> Bool {
        PlanterModel.realmManager.realm != nil
    }
    
    @MainActor
    func setState(to state: AppState) {
        withAnimation {
            self.appState = state
        }
    }
    
    @MainActor
    func authenticateUser(allowAnonymousAuthenticationOnFailure: Bool = false) async {
        self.appState = .authentication
        
        if !self.getAuthenticationCompletion() && allowAnonymousAuthenticationOnFailure {
            await PlanterModel.realmManager.signInAnonymously()
        }
        
        if !self.getAuthenticationCompletion() {
            self.appState = .authentication
            return
        }
        
        PlanterModel.realmManager.setActiveUser()
        PlanterModel.realmManager.setupConfiguration()
        
        self.appState = .openingRealm
        
        if self.offline { await openRealm() }
        
    }
    
    @MainActor
    func openRealm() async {
        
        await PlanterModel.realmManager.openRealm()
        
        if !self.getOpenRealmCompletion() {
            self.appState = .error
            return
        }
        
        self.appState = .app
    }
}
