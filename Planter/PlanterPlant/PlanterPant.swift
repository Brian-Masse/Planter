//
//  PlanterPant.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import RealmSwift


class PlanterPlant: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var ownerID: String = ""
    @Persisted var name: String = ""
    
    convenience init( ownerID: String, name: String ) {
        self.init()
        
        self.ownerID = ownerID
        self.name = name
        
        
    }
    
    
}
