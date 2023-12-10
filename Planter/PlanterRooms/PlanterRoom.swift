//
//  PlanterRoom.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import RealmSwift


class PlanterRoom: Object, Shareable, Identifiable {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var primaryOwnerId: String = ""
    @Persisted var secondaryOwners: RealmSwift.List<String> = List()
 
    @Persisted var plants: RealmSwift.List<PlanterPlant> = List()
    
    @Persisted var name: String = ""
    @Persisted var notes: String = ""
    
    convenience init( ownerId: String, secondaryOwners: [String], name: String, notes: String, plants: [PlanterPlant] ) {
        
        self.init()
        
        self.primaryOwnerId = ownerId
        self.secondaryOwners.append(objectsIn: secondaryOwners)
        
        self.name = name
        self.notes = notes
        self.plants.append(objectsIn: plants)
    }
    
//    MARK: Class Methods
    func addPlant(_ plant: PlanterPlant) {
        
        if let room = plant.room {
            room.removePlant(plant, setsRoomToNil: false)
        }
        
        plant.setRoom(to: self)
        
        if let _ = self.plants.first(where: { node in
            node == plant
        }) {
            removePlant(plant)
            return
        }
        
        RealmManager.updateObject(self) { thawed in
            if let thawedPlant = plant.thaw() {
                thawed.plants.append(thawedPlant)
            }
        }
    }
    
    func removePlant(_ plant: PlanterPlant, setsRoomToNil: Bool = true) {
        
        if setsRoomToNil { plant.setRoom(to: nil) }
        
        if let index = self.plants.firstIndex(where: { node in
            node == plant
        }) {
            RealmManager.updateObject(self) { thawed in
                thawed.plants.remove(at: index)
            }
        }
        
    }
    
//    MARK: Permissions
//    This object does not have any nested objects
    func updateNestedObjects() { }
    
    func compileOwnerId() -> String {
        secondaryOwners.reduce(primaryOwnerId) { partialResult, str in
            partialResult + str
        }
    }
    
    func addOwners(_ ownerID: [String], updateNestedObjects: Bool) {
        for ownerId in ownerID {
            addOwner(ownerId, updateNestedObjects: false)
        }
    }
    
    func addOwner(_ ownerID: String, updateNestedObjects: Bool) {
        if secondaryOwners.firstIndex(of: ownerID) == nil {
            RealmManager.updateObject(self) { thawed in
                thawed.secondaryOwners.append(ownerID)
            }
        }
    }
    
    func removeOwner(_ ownerID: String, updateNestedObjects: Bool) {
        if let index = secondaryOwners.firstIndex(of: ownerID) {
            RealmManager.updateObject(self) { thawed in
                thawed.secondaryOwners.remove(at: index)
            }
        }
    }
    
    func transferOwnership(to ownerID: String) {
        
        let oldPrimaryOwner = self.primaryOwnerId
        
        self.primaryOwnerId = ownerID
        
        self.removeOwner(ownerID, updateNestedObjects: false)
        
        self.addOwner(oldPrimaryOwner, updateNestedObjects: false)
        
    }
}
