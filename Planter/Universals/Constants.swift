//
//  Constants.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI
import Charts
import UIUniversals

//@MainActor
extension Colors {
    static let colorOptions: [Color] = [ Colors.lightAccent, blue, purple, grape, pink, red, yellow,  ]
}

extension Constants {
    
    //    extra
    static let UILargeCornerRadius: CGFloat = 50
    static let UIBottomOfPagePadding: CGFloat = 250
    static let UISubPadding: CGFloat = 7
    
    //    forms
    static let UIFormSpacing      : CGFloat = 10
    static let UIFormPagePadding: CGFloat = 5
    static let UIFormSliderTextFieldWidth: CGFloat = 60
    
    //    if there are any variables that need to be computed at the start, run their setup code here
    @MainActor
    static func setupConstants() {
    }
}
