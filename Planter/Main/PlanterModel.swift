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

struct PlanterModel {
    
//    MARK: vars
    static let realmManager: RealmManager = RealmManager()
    static let photoManager: PhotoManager = PhotoManager()
    static var shared: PlanterModel = PlanterModel()
    
    var offline: Bool = false
    
    var ownerID: String { PlanterModel.realmManager.user?.id ?? "no user" }
    
    var activeColor: Color = Colors.main
    
    
//    MARK: Flow
//    These functions will be called after the work of either authentication or open realm is performed
//    Their value will be used to progress the app state accordingly
    func getAuthenticationCompletion() -> Bool {
        PlanterModel.realmManager.user != nil
    }
    
    func getOpenRealmCompletion() -> Bool {
        PlanterModel.realmManager.realm != nil
    }
    
    @MainActor
    func authenticateUser() async {
        await PlanterModel.realmManager.signInAnonymously()
    }
    
    @MainActor
    func openRealm() async { 
        await PlanterModel.realmManager.openRealm()
    }
}
