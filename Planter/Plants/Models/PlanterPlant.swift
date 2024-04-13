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
    
//    Sharing
    @Persisted private var ownerID: String = ""
    @Persisted var secondaryOwners: RealmSwift.List<String> = List()
    var primaryOwnerId: String {
        get { ownerID }
        set { self.updateOwnerId(to: newValue) }
    }

    @Persisted var primaryWaterer: String = ""
    
//    Overview
    @Persisted var name: String = ""
    @Persisted var roomName: String = ""
    @Persisted var notes: String = ""
    @Persisted var isFavorite: Bool = false
    
    @Persisted var coverImage: Data = Data()
    private var image: SwiftUI.Image? = nil

    @Persisted var wateringInstructions:    String = ""
    @Persisted var wateringAmount:          Int = 0
    @Persisted var wateringInterval: Double = Constants.DayTime * 7
    
    @Persisted var statusImageFrequency: Int = 5
    @Persisted var statusCommentFrequency: Int = 5
    
    @Persisted var dateLastWatered: Date = .now
    @Persisted var wateringHistory: RealmSwift.List<PlanterWateringNode> = List()
    
//    archive
    @Persisted var room: PlanterRoom? = nil
    
//    MARK: init
    convenience init( ownerID: String,
                      name: String,
                      roomName: String,
                      notes: String,
                      wateringInstructions: String,
                      wateringAmount: Int,
                      wateringInterval: Double,
                      statusImageFrequency: Int,
                      statusNotesFrequency: Int,
                      coverImageData: Data) {
        self.init()
        
        self.ownerID = ownerID
//        self.primaryWaterer = ownerID
        
        self.name = name
        self.roomName = roomName
        self.notes = notes
        
        self.wateringInstructions = wateringInstructions
        self.wateringAmount = wateringAmount
        self.wateringInterval = wateringInterval * Constants.DayTime
        
        self.statusImageFrequency = statusImageFrequency
        self.statusCommentFrequency = statusNotesFrequency
        
        self.dateLastWatered = .now
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
    
    func toggleFavorite() {
        RealmManager.updateObject(self) { thawed in
            thawed.isFavorite.toggle()
        }
    }
    
//    MARK: Scheduling
//    This is how the calendar temporarily stores the schedule of plants
//    it includes the date a plant should be watered on, and the plant that needs to be watered
    struct ScheduleNode: Equatable {
        let date: Date
        let plant: PlanterPlant
    }
    
    func getWateringSchedule(in month: Date) -> [ ScheduleNode ] {
        let firstOfMonth    = month.startOfMonth()
        let endOfMonth      = month.endOfMonth()
        
        let differenceInDays    = firstOfMonth.timeIntervalSince(self.dateLastWatered) / Constants.DayTime
        let intervalInDays      = self.wateringInterval / Constants.DayTime
        
        let offsetInDays = ceil(differenceInDays / intervalInDays) * intervalInDays
        let firstWateringInMonth =  (self.dateLastWatered + offsetInDays * Constants.DayTime).resetToStartOfDay()
        
        var schedule = [ ScheduleNode(date: firstWateringInMonth, plant: self) ]
        var nextDate = firstWateringInMonth + wateringInterval
        
        while nextDate < endOfMonth {
            schedule.append( .init(date: nextDate, plant: self) )
            nextDate += wateringInterval
        }
        
        return schedule
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
    
    
    
//    MARK: Messages
    func getDaysUntilNextWateringDate() -> Int {
        let nextWateringDate = self.getNextWateringDate()
        
        return Int((nextWateringDate.timeIntervalSince(Date.now) / Constants.DayTime))
    }
    
///    "The fern needs to be watered in 5 days"
    func getWateringMessage() -> String {
        let days = getDaysUntilNextWateringDate()
        let dayMessage = days == 1 ? "day" : "days"
        let base = "The \(self.name) needs\nto be watered\n"
        
        if days > 0 { return base + "in \(days) \(dayMessage)" }
        if days == 0 { return base + "today" }
        if days < 0 { return base + "\(-days) \(dayMessage) ago" }
        
        return ""
    }
    
///    "The fern needs to be watered in 5 days"
    func getFullWateringMessage() -> String {
        let days = getDaysUntilNextWateringDate()
        let dayMessage = days == 1 ? "day" : "days"
        let base = "This plant needs to be watered "
        
        if days > 0 { return base + "in \(days) \(dayMessage)" }
        if days == 0 { return base + "today" }
        if days < 0 { return base + "\(-days) \(dayMessage) ago" }
        
        return ""
    }
    
///    "last watered: 03/27/2024"
    func getLastWateredMessage() -> String {
        "Last watered: \( self.dateLastWatered.formatted(date: .numeric, time: .omitted) )"
    }
    
///    "This plant was last watered on Apirl 12, 5 days ago."
    func getFullLastWateredMessage() -> String {
        let daysSinceLastWater = Int(Date.now.timeIntervalSince(self.dateLastWatered) / Constants.DayTime)
        let dayMessage = daysSinceLastWater == 1 ? "day ago" : "days ago"
        let ending = daysSinceLastWater == 0 ? "" : ", \(daysSinceLastWater) " + dayMessage
        
        return "This plant was last watered on \(self.dateLastWatered.formatted(date: .abbreviated, time: .omitted))" + ending
    }
    
///    This plant needs to be watered every 2 days
    func getWaterIntervalMessage() -> String {
        let day = wateringInterval == 1 ? "" : "\(Int(wateringInterval / Constants.DayTime))"
        
        return "this plant needs to be watered every \(day) days"
    }
    
//    TODO: create a message for when someone else is the primary waterer
///    Brian is the primary Waterer
    func getPrimaryWatererMessage() -> String {
        if isPrimaryWaterer() { return "You are the primary Waterer" }
        else {
            return "You are the primary Waterer"
        }
    }
    
//    MARK: General
    func wateringToday() -> Bool {
        getNextWateringDate().matches(Date.now, to: .day) || getNextWateringDate() < Date.now
    }
    
    func isPrimaryWaterer() -> Bool {
//        primaryWaterer == ownerID
        true
    }
    
    func getImage() -> SwiftUI.Image {
        if let image = self.image { return image }
        self.image = PhotoManager.decodeImage(from: self.coverImage) ?? Image("fern")
        return self.image!
    }
    
    @MainActor
    static func getPlants(on date: Date) -> [PlanterPlant] {
        
        RealmManager.retrieveObjects { query in
            query.getNextWateringDate().matches(date, to: .day)
        }
    }
    
//    MARK: WateringStatus
    enum PlantWateringCompletion {
        case missed
        case completed
        case upcoming
    }
    
    func getWateringStatus(from date: Date = .now) -> PlantWateringCompletion {
        let nextWateringDate = self.getNextWateringDate()
        
        if nextWateringDate < Date.now.resetToStartOfDay() { return .missed }
        if self.dateLastWatered > date.resetToStartOfDay() { return .completed }
        return .upcoming
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
