//
//  PlantPreviewView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI

struct PlantPreviewView: View {
    
    let plant: PlanterPlant
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                UniversalText( plant.name, size: Constants.UISubHeaderTextSize, font: Constants.titleFont )
                
                Spacer()
                
            }
            .padding(.bottom, 5)
            
            if let coverImage = plant.getCoverImage() {
                coverImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
            }
        }
        .secondaryOpaqueRectangularBackground()
        
    }
    
}
