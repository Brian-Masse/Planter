//
//  RealmManager.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift

class RealmManager {
    
    enum DefaultKey: String {
        case ownerID
    }
    
//    MARK: Vars
//    for online access to the database this needs to be given an ID
    let app: App = App(id: "-")
    
    var realm: Realm? = nil
    var user: User? = nil
    
    let defaults = UserDefaults()
    
//    MARK: Authentication
//    the getOwnerId check is redundant and should be removed. But while i cannot create an app to connect to I need to
//    read it as the check for whether a user is signed in or not
    func checkSignedIn() -> Bool {
         app.currentUser != nil || getOwnerId() != nil
    }
    
//    for offline access there should be a local copy of the ownerID in user defaults
//    after signing in a user, call this function to save it to defaults
    private func saveOwnerIdLocally(_ id: String) {
        defaults.set(id, forKey: DefaultKey.ownerID.rawValue)
    }
    
    private func getOwnerId() -> String? {
        defaults.string(forKey: DefaultKey.ownerID.rawValue)
    }

    func signInAnonymously() async {
        if !checkSignedIn() {
            let credentials: Credentials = Credentials.anonymous
            
            do {
                self.user = try await app.login(credentials: credentials)
                self.saveOwnerIdLocally(self.user!.id)
            } catch {
                print( "error signing user in: \(error.localizedDescription)" )
                
//                This is temporary, if a user is offline they cannot signIn, because the app will not be active
//                however i need to test offline stuff without being able to go online to first sign in.
//                so, once the user fails to login because im offline, this will save an ownerID into local storage to allow
//                me to continue testing the app
                self.saveOwnerIdLocally("hello")
            }
        }
    }
    

//    MARK: Open Realm Functions
    private func setupDefaultOfflineConfigurtion() -> Realm.Configuration {
        let configuration = Realm.Configuration(readOnly: false, deleteRealmIfMigrationNeeded: false)
        
        Realm.Configuration.defaultConfiguration = configuration
        return configuration
    }
    
    private func setupDefaultOnlineConfiguration() -> Realm.Configuration {
        if let configuration = user?.flexibleSyncConfiguration(cancelAsyncOpenOnNonFatalErrors: false) {
            Realm.Configuration.defaultConfiguration = configuration
            return configuration
        } else {
            return setupDefaultOfflineConfigurtion()
        }
    }

    func openRealm() async {
        let config = PlanterModel.shared.offline ? setupDefaultOfflineConfigurtion() : setupDefaultOnlineConfiguration()
        
        do {
            self.realm = try await Realm(configuration: config)
            
            
        } catch {
            print( "failed to open realm: \(error.localizedDescription)" )
        }
    }
    
    private func setupSubscriptions() async {
        
    }
    
    
    
}
