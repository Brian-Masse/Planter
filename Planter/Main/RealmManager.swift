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
    }
    
//    MARK: Vars
//    for online access to the database this needs to be given an ID
    let app: App = App(id: "application-0-bwmin")
    
    var realm: Realm? = nil
    var user: User? = nil
    
    let defaults = UserDefaults()
    
//    MARK: Authentication
//    the getOwnerId check is redundant and should be removed. But while i cannot create an app to connect to I need to
//    read it as the check for whether a user is signed in or not
    func checkSignedIn() -> Bool {
         app.currentUser != nil || getLocalOwnerId() != nil
    }
    
//    for offline access there should be a local copy of the ownerID in user defaults
//    after signing in a user, call this function to save it to defaults
    private func saveOwnerIdLocally(_ id: String) {
        defaults.set(id, forKey: DefaultKey.ownerID.rawValue)
    }
    
    private func getLocalOwnerId() -> String? {
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
            }
        } else { self.user = app.currentUser! }
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
            if !PlanterModel.shared.offline { await self.setupSubscriptions() }
            
        } catch {
            print( "failed to open realm: \(error.localizedDescription)" )
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
        
        let _: PlanterPlant? = await addGenericSubcriptions(name: SubscriptionKey.planterPlant.rawValue) { query in
            query.ownerID == PlanterModel.shared.ownerID
        }
        
    }
    
//    MARK: Realm Functions
    //    in all add, update, and delete transactions, the user has the option to pass in a realm
    //    if they want to write to a different realm.
    //    This is a convenience function either choose that realm, if it has a value, or the default realm
      static func getRealm(from realm: Realm?) -> Realm {
          realm ?? PlanterModel.realmManager.realm!
      }
      
      static func writeToRealm(_ realm: Realm? = nil, _ block: () -> Void ) {
          do {
              if getRealm(from: realm).isInWriteTransaction { block() }
              else { try getRealm(from: realm).write(block) }
              
          } catch { print("ERROR WRITING TO REALM:" + error.localizedDescription) }
      }
      
      static func updateObject<T: Object>(realm: Realm? = nil, _ object: T, _ block: (T) -> Void, needsThawing: Bool = true) {
          RealmManager.writeToRealm(realm) {
              guard let thawed = object.thaw() else {
                  print("failed to thaw object: \(object)")
                  return
              }
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
