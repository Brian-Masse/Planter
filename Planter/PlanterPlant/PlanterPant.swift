//
//  PlanterPant.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift

class PlanterPlant: Object, Identifiable {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var ownerID: String = ""
    
    @Persisted var name: String = ""
    @Persisted var notes: String = ""
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
//    MARK: init
    convenience init( ownerID: String, name: String, notes: String, wateringInterval: Double) {
        self.init()
        
        self.ownerID = ownerID
        
        self.name = name
        self.notes = notes
        self.dateLastWatered = .now
        self.wateringInterval = wateringInterval
        
    }
    
//    MARK: Class Methods
    func getNextWateringDate() -> Date {
        dateLastWatered + wateringInterval
        
    }
}
