//
//  PlanterProfile.swift
//  Planter
//
//  Created by Brian Masse on 12/10/23.
//

import Foundation
import RealmSwift


class PlanterProfile: Object {
    
//    MARK: Vars
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var ownerId: String = ""

    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var userName: String = ""
    
    @Persisted var email: String = ""
    @Persisted var phoneNumber: Int = 0
    @Persisted var birthday: Date = .now
    
    @Persisted var dateJoined: Date = .now
    
    convenience init( ownerId: String, firstName: String, lastName: String, userName: String, email: String, phoneNumber: Int, birthday: Date ) {
        
        self.init()
        
        self.ownerId = ownerId
        
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        
        self.email = email
        self.phoneNumber = phoneNumber
        self.birthday = birthday
        
        self.dateJoined = .now
        
    }
    
//    MARK: Convenience Functions
    func fullName() -> String {
        "\(firstName) \(lastName)"
        
    }
    
}
