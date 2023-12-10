//
//  RealmManager.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift
import Realm

class RealmManager {
    
    enum DefaultKey: String {
        case ownerID
    }
    
    enum SubscriptionKey: String {
        case planterPlant
        case planterWateringNode
        case planterRoom
        case planterProfile
    }
    
//    MARK: Vars
//    for online access to the database this needs to be given an ID
    static let appID: String = "application-0-bwmin"
    let app: App = App(id: RealmManager.appID)
    
    private(set) var realm: Realm? = nil
    private(set) var user: User? = nil
    
    private(set) var configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration
    
    let defaults = UserDefaults()
    
//    MARK: Profile
    func checkHasProfile() -> Bool {
        let profile: PlanterProfile? = RealmManager.retrieveObject(where: { query in
            query.ownerId == PlanterModel.shared.ownerID
        }).first
    
        PlanterModel.shared.setProfile(profile)
        
        return profile != nil
    }
    
//    MARK: Authentication
    func checkSignedIn() -> Bool {
         app.currentUser != nil || !(getLocalOwnerId() ?? "").isEmpty
    }
    
//    for offline access there should be a local copy of the ownerID in user defaults
//    after signing in a user, call this function to save it to defaults
    private func saveOwnerIdLocally(_ id: String) {
        defaults.set(id, forKey: DefaultKey.ownerID.rawValue)
    }
    
    func getLocalOwnerId() -> String? {
        defaults.string(forKey: DefaultKey.ownerID.rawValue)
    }
    
//    when the app loads, it checks whether there is a user
//    because the app can be offline, meaning either this class has a currentUser signed in, or its in the defaults
//    if the app has a currentUser (its online), then it needs to be captured in the realmmanager class
    func setActiveUser() {
        if let currentUser = app.currentUser {
            self.user = currentUser
        }
    }

//    MARK: Specific Authentication Methods
    private func authenticateUser(credentials: Credentials) async {
        do {
            self.user = try await app.login(credentials: credentials)
            self.saveOwnerIdLocally(self.user!.id)
        } catch {
            print( "error signing user in: \(error.localizedDescription)" )
        }
    }
    
    func signInAnonymously() async {
        if !checkSignedIn() {
            let credentials: Credentials = Credentials.anonymous
            
            await authenticateUser(credentials: credentials)
            
        } else { self.user = app.currentUser! }
    }
    
    func signInWithEmail( email: String, password: String ) async {
        if !checkSignedIn() {
            let fixedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let client = app.emailPasswordAuth
            
            do {
                try await client.registerUser(email: fixedEmail, password: password)
            } catch {
                print( "error registering user with credentials: \(fixedEmail), \(password): \(error.localizedDescription)" )
            }
            
            let credentials: Credentials = Credentials.emailPassword(email: fixedEmail, password: password)
            await authenticateUser(credentials: credentials)
            
        } else { self.user = app.currentUser! }
        
    }
    
    @MainActor
    func logout() async {
        if let user = self.user {
            
            do {
                try await user.logOut()
                
                self.user = nil
                self.saveOwnerIdLocally("")
                
                PlanterModel.photoManager.clearImage()
                PlanterModel.shared.setState(to: .authentication)
                PlanterModel.shared.setProfile(nil)
                
            } catch { print( "error logging out: \(error.localizedDescription)" ) }
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

    func setupConfiguration() {
        
        let config = PlanterModel.shared.offline ? setupDefaultOfflineConfigurtion() : setupDefaultOnlineConfiguration()
        
        self.configuration = config
        
    }
    
//    This is called if the app is offline. A non-flex sync realm is opened and used, no subscriptions are added
    func openRealm() async {
        do {
            self.realm = try await Realm(configuration: self.configuration)
            if !PlanterModel.shared.offline { await self.setupSubscriptions() }
            
        } catch {
            print( "failed to open realm: \(error.localizedDescription)" )
        }
    }
    
//    This is called if the app is online. Once the OpenFlexibleSyncRealmView finishes opening the realm
//    it passes it into this function for RealmManager to capture, and add subscriptions
    @MainActor
    func authRealm(_ realm: Realm) async {
        self.realm = realm
        
        await self.setupSubscriptions()
        
        if checkHasProfile() {
            PlanterModel.shared.setState(to: .app)
        } else {
            PlanterModel.shared.setState(to: .creatingProfile)
        }
    }
    
//    MARK: Subscriptions
    func addGenericSubcriptions<T>(realm: Realm? = nil, name: String, query: @escaping ((Query<T>) -> Query<Bool>) ) async -> T? where T:RealmSwiftObject  {
            
        let localRealm = (realm == nil) ? self.realm! : realm!
        let subscriptions = localRealm.subscriptions
        
        do {
            try await subscriptions.update {
                
                let querySub = QuerySubscription(name: name, query: query)
                
                if checkSubscription(name: name, realm: localRealm) {
                    let foundSubscriptions = subscriptions.first(named: name)!
                    foundSubscriptions.updateQuery(toType: T.self, where: query)
                }
                else { subscriptions.append(querySub) }
            }
        } catch { print("error adding subcription: \(error)") }
        
        return nil
    }
    
    func removeSubscription(name: String) async {
            
        let subscriptions = self.realm!.subscriptions
        let foundSubscriptions = subscriptions.first(named: name)
        if foundSubscriptions == nil {return}
        
        do {
            try await subscriptions.update{
                subscriptions.remove(named: name)
            }
        } catch { print("error adding subcription: \(error)") }
    }
    
    private func checkSubscription(name: String, realm: Realm) -> Bool {
        let subscriptions = realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name)
        return foundSubscriptions != nil
    }
    
    private func setupSubscriptions() async {
        
        let ownerID = PlanterModel.shared.ownerID
        
        let _: PlanterPlant? = await addGenericSubcriptions(name: SubscriptionKey.planterPlant.rawValue) { query in
            query.secondaryOwners.contains(ownerID) || query.primaryOwnerId == ownerID
        }
        
        let _:PlanterWateringNode? = await addGenericSubcriptions(name: SubscriptionKey.planterWateringNode.rawValue) { query in
            query.compiledOwnerId.contains(ownerID)
        }
        
        let _:PlanterRoom? = await addGenericSubcriptions(name: SubscriptionKey.planterRoom.rawValue) { query in
            query.secondaryOwners.contains(ownerID) || query.primaryOwnerId == ownerID
        }
        
        let _:PlanterProfile? = await addGenericSubcriptions(name: SubscriptionKey.planterProfile.rawValue) { query in
            query.ownerId == ownerID
        }
        
    }
    
//    MARK: Realm Functions
    //    in all add, update, and delete transactions, the user has the option to pass in a realm
    //    if they want to write to a different realm.
    //    This is a convenience function either choose that realm, if it has a value, or the default realm
      static func getRealm(from realm: Realm?) -> Realm {
          PlanterModel.realmManager.realm!
      }
      
      static func writeToRealm(_ realm: Realm? = nil, _ block: () -> Void ) {
          do {
              if getRealm(from: realm).isInWriteTransaction { block() }
              else { try getRealm(from: realm).write(block) }
              
          } catch { print("ERROR WRITING TO REALM:" + error.localizedDescription) }
      }
      
      static func updateObject<T: Object>(realm: Realm? = nil, _ object: T, needsThawing: Bool = true, _ block: (T) -> Void) {
          guard let thawed = object.thaw() else {
              print("failed to thaw object: \(object)")
              return
          }
          RealmManager.writeToRealm( thawed.realm ) {
            block(thawed)
        }
      }
      
      static func addObject<T:Object>( _ object: T, realm: Realm? = nil ) {
          self.writeToRealm(realm) { getRealm(from: realm).add(object) }
      }
      
      static func retrieveObject<T:Object>( realm: Realm? = nil, where query: ( (Query<T>) -> Query<Bool> )? = nil ) -> Results<T> {
          if query == nil { return getRealm(from: realm).objects(T.self) }
          else { return getRealm(from: realm).objects(T.self).where(query!) }
      }
      
      @MainActor
      static func retrieveObjects<T: Object>(realm: Realm? = nil, where query: ( (T) -> Bool )? = nil) -> [T] {
          if query == nil { return Array(getRealm(from: realm).objects(T.self)) }
          else { return Array(getRealm(from: realm).objects(T.self).filter(query!)  ) }
          
          
      }
      
      static func deleteObject<T: RealmSwiftObject>( _ object: T, where query: @escaping (T) -> Bool, realm: Realm? = nil ) where T: Identifiable {
          
          if let obj = getRealm(from: realm).objects(T.self).filter( query ).first {
              self.writeToRealm {
                  getRealm(from: realm).delete(obj)
              }
          }
      }
}
