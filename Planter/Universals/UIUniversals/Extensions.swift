//
//  Extensions.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI
import UIUniversals

//MARK: Date
extension Date {
    func matches(dayOfWeek day: Int) -> Bool {
        let component = Calendar.current.component(.weekday, from: self)
        return component == day   
    }
}
