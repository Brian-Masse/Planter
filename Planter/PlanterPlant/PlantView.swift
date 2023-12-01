//
//  PlanterView.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI

struct PlantView: View {
    
    @Environment( \.colorScheme ) var colorScheme
    @Environment( \.presentationMode ) var presentationMode
    @Environment( \.planterSheetDismiss ) var planterSheetDismiss
    
    let plant: PlanterPlant
    
//    MARK: Body
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack {
                    
                    let baseColor = colorScheme == .light ? Colors.baseLight : Colors.baseDark
                    
                    let gradient = LinearGradient(stops: [
                        .init(color: baseColor, location: 0.1),
                        .init(color: .clear, location: 0.4)
                        
                    ], startPoint: .bottom, endPoint: .top)
                    
                    if let image = plant.getCoverImage() {
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height / 1.5)
                            .clipped()
                            .overlay {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: 40)
                                    .padding(-40)
                                    .frame(width: geo.size.width, height: geo.size.height / 1.5)
                                    .clipped()
                                    .mask { gradient }
                            }
                            .overlay(alignment: .bottom) {
                                gradient
                            }
                    }
                    
                    Spacer()
                
                    UniversalText(plant.name, size: Constants.UIDefaultTextSize)
                    
                    LargeRoundedButton("", icon: "arrow.down", wide: true) {
                        planterSheetDismiss.dismiss()
                    }
                    .padding(.bottom)
                    
                }
        
                
                
                
                
                
                
            }
        }
        .ignoresSafeArea()
        .universalBackground()
    }
}
