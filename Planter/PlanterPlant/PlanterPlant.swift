//
//  PlanterPant.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift
import SwiftUI
import UIKit
import UIUniversals

class PlanterPlant: Object, Identifiable, Shareable {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    var id: String { name }
    
    @Persisted private var ownerID: String = ""
    @Persisted var secondaryOwners: RealmSwift.List<String> = List()
    var primaryOwnerId: String {
        get { ownerID }
        set { self.updateOwnerId(to: newValue) }
    }

    @Persisted var name: String = ""
    @Persisted var notes: String = ""
    
    @Persisted var wateringHistory: RealmSwift.List<PlanterWateringNode> = List()
    
    @Persisted var coverImage: Data = Data()
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
    @Persisted var room: PlanterRoom? = nil
    
//    MARK: init
    convenience init( ownerID: String, name: String, notes: String, wateringInterval: Double, coverImageData: Data) {
        self.init()
        
        self.ownerID = ownerID
        
        self.name = name
        self.notes = notes
        self.dateLastWatered = .now
        self.wateringInterval = wateringInterval
        
        self.coverImage = coverImageData
        
    }

//    MARK: Class Methods
    func getNextWateringDate(_ iterator: Int = 1) -> Date {
        var date = dateLastWatered
        for _ in (0..<iterator) {
            date += wateringInterval
        }
        return date
    }
    
    @MainActor
    func water( date: Date, comments: String ) {
        
        let compiledOwnerId = self.compileOwnerId()
        let wateringNode = PlanterWateringNode(compiledOwnerId: compiledOwnerId, wateringDate: date, comments: comments, watererOwnerId: PlanterModel.shared.ownerID)
        
        RealmManager.updateObject(self) { obj in
            obj.dateLastWatered = date
            obj.wateringHistory.append( wateringNode )
        }
    }
    
    static func encodeImage( _ image: UIImage? ) -> Data {
        if let image { return image.jpegData(compressionQuality: 0.9) ?? Data() }
        return Data()
    }
    
    private func updateOwnerId(to ownerID: String) {
        RealmManager.updateObject(self) { thawed in
            thawed.ownerID = ownerID
        }
    }
    
    
//    MARK: Permissions
    func compileOwnerId() -> String {
        secondaryOwners.reduce(self.primaryOwnerId) { partialResult, str in
            partialResult + str
        }
    }
    
    func updateNestedObjects() {
        let compiledOwnerId = compileOwnerId()
        
        for node in wateringHistory {
            node.updateCompiledOwnerId(compiledOwnerId)
        }
    }
    
    func addOwners( _ owners: [String], updateNestedObjects: Bool = false) {
        RealmManager.updateObject(self) { thawed in
            thawed.secondaryOwners.append(objectsIn: owners)
        }
        if updateNestedObjects { self.updateNestedObjects() }
    }
    
    func addOwner( _ ownerID: String, updateNestedObjects: Bool = false) {
        RealmManager.updateObject(self) { thawed in
            thawed.secondaryOwners.append( ownerID )
        }
        if updateNestedObjects { self.updateNestedObjects() }
    }
    
    func removeOwner(_ ownerID: String, updateNestedObjects: Bool = true) {
        RealmManager.updateObject(self) { thawed in
            if let index = thawed.secondaryOwners.firstIndex(of: ownerID) {
                thawed.secondaryOwners.remove(at: index)
            }
        }
        if updateNestedObjects { self.updateNestedObjects() }
    }
    
    func transferOwnership(to ownerID: String) {
        RealmManager.updateObject(self) { thawed in
            let oldPrimaryOwner = thawed.primaryOwnerId
            
            thawed.removeOwner(ownerID, updateNestedObjects: false)
            
            thawed.addOwner(oldPrimaryOwner, updateNestedObjects: false)
            
            thawed.primaryOwnerId = ownerID
        }
        updateNestedObjects()
    }
    
//    MARK: Convenience Functions
    
    func setRoom(to room: PlanterRoom?) {
        RealmManager.updateObject(self) { thawed in
            if let room {
                if let thawedRoom = room.thaw() {
                    thawed.room = thawedRoom
                }
            } else { thawed.room = nil }
        }
    }
    
    @MainActor
    static func getPlants(on date: Date) -> [PlanterPlant] {
        
        RealmManager.retrieveObjects { query in
            query.getNextWateringDate().matches(date, to: .day)
        }
        
    }
}

//MARK: PlanterWateringNode
class PlanterWateringNode: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
//    This ownerId is a compilation of all its parents owners.
//    Whenever you add a subowner or change anything to do with permission on the plant class
//    it should automatically update this class
    @Persisted var compiledOwnerId: String = ""
    
    @Persisted var date: Date = .now
    @Persisted var comments: String = ""
    
    @Persisted var watererOwnerId: String = ""
    
    convenience init( compiledOwnerId: String, wateringDate: Date, comments: String, watererOwnerId: String ) {
        self.init()
        
        self.compiledOwnerId = compiledOwnerId
        
        self.date = wateringDate
        self.comments = comments
        self.watererOwnerId = watererOwnerId
        
    }
    
    func updateCompiledOwnerId(_ ownerId: String) {
        RealmManager.updateObject(self) { thawed in
            thawed.compiledOwnerId = ownerId
        }
        
    }
}


//MARK: Shareable Protocol
protocol Shareable {
    
    var primaryOwnerId: String {get set}
    var secondaryOwners: RealmSwift.List<String> {get set}
    
//    If a shareable object has subobjects, they need to be easily accessed by any person with access to the parent object
//    they will have a variable compiledOwnerId, this function reminds you
//    to implement an update method whenever the permission of the parent is updated
    func updateNestedObjects() -> Void
    
    func compileOwnerId() -> String
    
    func addOwners(_ ownerID: [String], updateNestedObjects: Bool)
    
    func addOwner(_ ownerID: String, updateNestedObjects: Bool)
    
    func removeOwner(_ ownerID: String, updateNestedObjects: Bool)
    
    func transferOwnership(to ownerID: String)
    
}
