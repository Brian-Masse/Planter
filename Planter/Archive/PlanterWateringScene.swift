//
//  PlanterWateringScene.swift
//  Planter
//
//  Created by Brian Masse on 12/8/23.
//

import Foundation
import SwiftUI
import UIUniversals

struct PlantWateringScene: View {
    
    let plant: PlanterPlant
    
    @State var date: Date = .now
    @State var comments: String = ""
    
    @MainActor
    private func submit() {
        
        plant.water(date: date, comments: comments)
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                UniversalText( "Water \(plant.name)", size: Constants.UITitleTextSize, font: Constants.titleFont, case: .uppercase )
                
                Spacer()
            }.padding(.bottom)
            
            
            StyledTextField($comments, prompt: "comments")
            
            StyledDatePicker($date, title: "What day did you water this on?")
            
            Spacer()
            
            LargeTextButton("Submit", at: 0, aspectRatio: 1, arrow: false) {
                submit()
            }
            
            
        }
        .padding(7)
        .universalBackground()
    }
}
