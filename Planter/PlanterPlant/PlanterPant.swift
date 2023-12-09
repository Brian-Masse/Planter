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
    
    @Persisted var coverImage: Data = Data()
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
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
    
//    MARK: Permissions
    
    func addOwners( _ owners: [String] ) {
        RealmManager.updateObject(self) { thawed in
            thawed.secondaryOwners.append(objectsIn: owners)
        }
    }
    
    func addOwner( _ ownerID: String ) {
        RealmManager.updateObject(self) { thawed in
            thawed.secondaryOwners.append( ownerID )
        }
    }
    
    func removeOwner(_ ownerID: String) {
        RealmManager.updateObject(self) { thawed in
            if let index = thawed.secondaryOwners.firstIndex(of: ownerID) {
                thawed.secondaryOwners.remove(at: index)
            }
        }
    }
    
    func transferOwnership(to ownerID: String) {
        RealmManager.updateObject(self) { thawed in
            let oldPrimaryOwner = thawed.primaryOwnerId
            
            thawed.removeOwner(ownerID)
            
            thawed.addOwner(oldPrimaryOwner)
            
            thawed.primaryOwnerId = ownerID
        }
    }
    
    
    
//    MARK: Class Methods
    func getNextWateringDate(_ iterator: Int = 1) -> Date {
        var date = dateLastWatered
        for _ in (0..<iterator) {
            date += wateringInterval
        }
        return date
    }
//    
    static func encodeImage( _ image: UIImage? ) -> Data {
        if let image { return image.jpegData(compressionQuality: 0.9) ?? Data() }
        return Data()
    }
    
    private func updateOwnerId(to ownerID: String) {
        RealmManager.updateObject(self) { thawed in
            thawed.ownerID = ownerID
        }
    }
    
//    MARK: Convenience Functions
    func getCoverImage() -> Image? {
        if let uiImage = UIImage(data: coverImage) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}


//MARK: Shareable Protocol
protocol Shareable {
    
    var primaryOwnerId: String {get set}
    var secondaryOwners: RealmSwift.List<String> {get set}
    
    func addOwners(_ ownerID: [String])
    
    func addOwner(_ ownerID: String)
    
    func removeOwner(_ ownerID: String)
    
    func transferOwnership(to ownerID: String)
    
}
