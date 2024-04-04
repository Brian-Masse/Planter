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
        
        Colors.setColors(baseLight:         .init(255, 255, 255),
                         secondaryLight:    .init(224, 216, 206),
                         baseDark:          .init(0, 0, 0),
                         secondaryDark:     .init(30, 30, 30),
                         lightAccent:       .init(245, 87, 66),
                         darkAccent:        .init(245, 87, 66))
        
        Constants.UIDefaultCornerRadius = 25
        
        Constants.setFontSizes(UILargeTextSize:         130,
                               UITitleTextSize:         80,
                               UIMainHeaderTextSize:    60,
                               UIHeaderTextSize:        40,
                               UISubHeaderTextSize:     30,
                               UIDefeaultTextSize:      20,
                               UISmallTextSize:         15)
        
        FontProvider.registerFonts()
        Constants.titleFont = SpaceGroteskMedium.shared
        Constants.mainFont = SpaceGroteskRegular.shared
        
        UITabBar.appearance().isHidden = true
    }
    
    init() { setupUIUniversals() }
    
    var body: some Scene {
        WindowGroup {
            PlanterView ()
        }
    }
}

struct SpaceGroteskMedium: UniversalFont {
    var postScriptName: String = "SpaceGrotesk-Medium"
    
    var fontExtension: String = "ttf"
    
    static var shared: any UIUniversals.UniversalFont = SpaceGroteskMedium()
}

struct SpaceGroteskRegular: UniversalFont {
    var postScriptName: String = "SpaceGrotesk-Regular"
    var fontExtension: String = "ttf"
    
    static var shared: any UIUniversals.UniversalFont = SpaceGroteskRegular()
}
