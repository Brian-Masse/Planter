//
//  Constants.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI
import Charts

//@MainActor
class Colors {
    static var tint: Color { PlanterModel.shared.activeColor }
    static var main: Color { accent }
    
    static let colorOptions: [Color] = [ accent, blue, purple, grape, pink, red, yellow,  ]
    
    static let baseLight = makeColor( 245, 234, 208 )
    static let secondaryLight = makeColor(220, 207, 188)
    static let baseDark = makeColor( 0,0,0 )
    static let secondaryDark = Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.9)
    
    static let accent = makeColor(245, 87, 66)
//    static let lightAccentGreen = makeColor(66, 122, 69)
    
    static let yellow = makeColor(234, 169, 40)
    static let pink = makeColor(198, 62, 120)
    static let purple = makeColor(106, 38, 153)
    static let grape = makeColor(70, 42, 171)
    static let blue = makeColor(69, 121, 251)
    static let red = makeColor(236, 81, 46)
    
    private static func makeColor( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat ) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
}

class Constants {
    
    //    font sizes
    static let UILargeTextSize: CGFloat     = 130
    static let UITitleTextSize: CGFloat     = 80
    static let UIMainHeaderTextSize: CGFloat    = 60
    static let UIHeaderTextSize: CGFloat    = 40
    static let UISubHeaderTextSize: CGFloat = 30
    static let UIDefaultTextSize: CGFloat   = 20
    static let UISmallTextSize: CGFloat     = 15
    
    //    extra
    static let UIDefaultCornerRadius: CGFloat = 40
    static let UILargeCornerRadius: CGFloat = 55
    static let UIBottomOfPagePadding: CGFloat = 130
    
    //    forms
    static let UIFormSpacing      : CGFloat = 10
    static let UIFormPagePadding: CGFloat = 5
    static let UIFormSliderTextFieldWidth: CGFloat = 60
    
    //    charts
    static let UICircularProgressWidth: CGFloat = 12
    static let UIBarMarkCOrnerRadius: CGFloat = 5
    static let UIScrollableBarWidth: MarkDimension = 16
    static let UIScrollableBarWidthDouble: Double = 18
    
    //    timings
    static let MinuteTime: Double = 60
    static let HourTime: Double = 3600
    static let DayTime: Double = 86400
    static let WeekTime: Double = 604800
    static let yearTime: Double = 31557600
    
    //    fonts
    static let titleFont: ProvidedFont = .madeTommyRegular
    static let mainFont: ProvidedFont = .madeTommyRegular
    
    //    texts
    static let tagSplashPurpose: String = "Tags are a way to organize similar types of events in your life, as well as label how those activites contribute to your goals."
    static let goalsSplashPurpose: String = "Goals allow you to automatically count certain activities towards the personal goals in your life."
    
    static let templatesSplashPurpose: String = "Templates allow you save and quickly recall frequent events. To create a template, select an event and click 'make template'"
    static let favoritesSplashPurpose: String =  "Favorites help you remember the experiences and moments most special to you. To favorite an event, select it and click 'favorite'"
    
    //    if there are any variables that need to be computed at the start, run their setup code here
    @MainActor
    static func setupConstants() {
    }
}
