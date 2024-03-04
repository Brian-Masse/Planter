//
//  PlanterApp.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import SwiftUI
import UIUniversals

@main
struct PlanterApp: App {
    
    private func setupUIUniversals() {
        
        Colors.setColors(baseLight:         .init(245, 234, 208),
                         secondaryLight:    .init(220, 207, 188),
                         baseDark:          .init(0, 0, 0),
                         secondaryDark:     .init(25, 25, 25),
                         lightAccent:       .init(245, 87, 66),
                         darkAccent:        .init(245, 87, 66))
        
        Constants.UIDefaultCornerRadius = 40
        
        Constants.setFontSizes(UILargeTextSize:         130,
                               UITitleTextSize:         80,
                               UIMainHeaderTextSize:    60,
                               UIHeaderTextSize:        40,
                               UISubHeaderTextSize:     30,
                               UIDefeaultTextSize:      20,
                               UISmallTextSize:         15)
        
        FontProvider.registerFonts()
        Constants.titleFont = FontProvider[.madeTommyRegular]
        Constants.mainFont = FontProvider[.madeTommyRegular]
        
        UITabBar.appearance().isHidden = true
    }
    
    init() { setupUIUniversals() }
    
    var body: some Scene {
        WindowGroup {
            PlanterView ()
        }
    }
}
