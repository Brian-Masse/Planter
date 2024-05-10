//
//  PlanterProfile.swift
//  Planter
//
//  Created by Brian Masse on 12/10/23.
//

import Foundation
import RealmSwift
import SwiftUI
import UIKit

class PlanterProfile: Object, Identifiable {
    
    enum Publicity: String {
        case publicProfile
        case privateProfile
        
        func getDescriptionString() -> String {
            switch self {
            case .publicProfile: return "public"
            case .privateProfile: return "private"
            }
        }
    }
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var ownerId: String = ""
    @Persisted var publicity: String = Publicity.publicProfile.rawValue
    
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var userName: String = ""
    
    @Persisted var email: String = ""
    @Persisted var phoneNumber: Int = 0
    @Persisted var birthday: Date = .now
    
    @Persisted var profileImage: Data = Data()
    private var image: SwiftUI.Image? = nil
    
    @Persisted var dateJoined: Date = .now
    
    @Persisted var pendingRequests: RealmSwift.List<String> = List()
    @Persisted var friendRequests: RealmSwift.List<String> = List()
    @Persisted var friends: RealmSwift.List<PlanterProfile> = List()
    
    convenience init( ownerId: String, firstName: String, lastName: String, userName: String, email: String, phoneNumber: Int, birthday: Date ) {
        
        self.init()
        
        self.ownerId = ownerId
        self.publicity = Publicity.publicProfile.rawValue
        
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        
        self.dateJoined = .now
        
    }
    
//    MARK: Convenience Functions
    
    func getImage() -> SwiftUI.Image {
        if let image = self.image { return image }
        self.image = PhotoManager.decodeImage(from: self.profileImage) ?? Image("profile")
        return self.image!
    }
    
    func fullName() -> String {
        "\(firstName) \(lastName)"
    }
    
    func getPublicityString() -> String {
        if let enumPublicity = Publicity(rawValue: self.publicity) {
            return enumPublicity.getDescriptionString()
        }
        return ""
    }
    
    static func getProfile(from ownerID: String) -> PlanterProfile? {
        return RealmManager.retrieveObject() { query in
            query.ownerId == ownerID
        }.first
    }
    
    func isFriends(with profile: PlanterProfile) -> Bool {
        return self.friends.contains { prof in
            prof.ownerId == profile.ownerId
        }
    }
    
    func isPending(_ profile: PlanterProfile) -> Bool {
        self.pendingRequests.contains(profile.ownerId)
    }
    
    func isRequestedBy(_ profile: PlanterProfile) -> Bool {
        self.friendRequests.contains(profile.ownerId)
    }
    
//    MARK: Class Methods
    
    func changePublicity( to publicity: Publicity ) {
        RealmManager.updateObject(self) { thawed in
            thawed.publicity = publicity.rawValue
        }
    }
    
    func setProfilePicture(to image: UIImage) {
        let data = PlanterPlant.encodeImage(image)
        
        RealmManager.updateObject(self) { thawed in
            thawed.profileImage = data
        }
    }
    
    static func searchProfiles(in text: String) async -> [PlanterProfile] {
        
        let _: PlanterProfile? = await PlanterModel.realmManager.addGenericSubcriptions(name: RealmManager.SubscriptionKey.planterProfile.rawValue) { query in
            
            query.publicity == Publicity.publicProfile.rawValue ||
            query.ownerId == PlanterModel.shared.ownerID
        }
        
        let results: [PlanterProfile] = await RealmManager.retrieveObjects { query in
            query.firstName.contains( text ) ||
            query.lastName.contains(text) ||
            query.userName.contains(text)
        }
        
        return results
        
    }
    
    func requestFriend( _ profile: PlanterProfile ) {
        RealmManager.updateObject(self) { thawed in
            thawed.pendingRequests.append( profile.ownerId )
        }
        
        profile.receiveFriendRequest(from: self)
    }
    
    func unRequestFriend( _ profile: PlanterProfile ) {
        if let index = pendingRequests.firstIndex(of: profile.ownerId) {
            RealmManager.updateObject(self) { thawed in
                thawed.pendingRequests.remove(at: index)
            }
        }
        
        profile.unReceiveFriendRequest(from: self)
    }
    
    func receiveFriendRequest( from profile: PlanterProfile ) {
        RealmManager.updateObject(self) { thawed in
            thawed.friendRequests.append(profile.ownerId)
        }
    }
    
    func unReceiveFriendRequest(from profile: PlanterProfile) {
        if let index = friendRequests.firstIndex(of: profile.ownerId) {
            RealmManager.updateObject(self) { thawed in
                thawed.friendRequests.remove(at: index)
            }
        }
    }
    
    func acceptFriendRequest( ownerID: String ) {
        if let _ = friendRequests.firstIndex(of: ownerID) {
            if let friendProfile = PlanterProfile.getProfile(from: ownerID) {
                
                friendProfile.addFriend(self)
                
                self.addFriend(friendProfile)
                
            }
        }
    }
    
    private func addFriend( _ profile: PlanterProfile ) {
        RealmManager.updateObject(self) { thawed in
            if let pendingIndex = self.pendingRequests.firstIndex(of: profile.ownerId ) {
                thawed.pendingRequests.remove(at: pendingIndex)
            }
            
            if let requestIndex = thawed.friendRequests.firstIndex(of: profile.ownerId ) {
                thawed.friendRequests.remove(at: requestIndex)
            }
            
            if let thawedFriend = profile.thaw() {
                thawed.friends.append( thawedFriend )
            }
        }
    }
}
