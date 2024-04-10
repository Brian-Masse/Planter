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
    
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: self.startOfMonth())!
    }
}
