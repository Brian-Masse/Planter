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
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeBackground(height: CGFloat = 300) -> some View {
        
        let alignment: Alignment = .center
        let normalBlurHeight: CGFloat = 1/5
        
        let gradient = LinearGradient(stops: [
            .init(color: .white, location: normalBlurHeight ),
            .init(color: .clear, location: 1 ) ],
                                      startPoint: .bottom,
                                      endPoint: .top)
        
        ZStack(alignment: alignment) {
            if let coverImage = plant.getCoverImage() {
                coverImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        coverImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 40)
                            .padding(-40)
                            .clipped()
                            .mask(alignment: alignment) {
                                gradient
                                    .frame(height: height)
                                    .padding(.vertical, 20)
                            }
                    }
            } else {
                Rectangle()
                    .foregroundStyle(.black)
            }
        }
        .frame(maxHeight: height, alignment: alignment)
        .cornerRadius(Constants.UIDefaultCornerRadius)
    }
    
    @ViewBuilder
    private func makeCheckmarkButton<T: ShapeStyle>(style: T) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(style)
            
            Image(systemName: "checkmark")
        }
        .frame(width: 120, height: 120)
        .cornerRadius(Constants.UILargeCornerRadius)
    
    }
    
//    MARK: Body
    var body: some View {
        
        ZStack(alignment: .bottom) {
            makeBackground()
            
            VStack {
                
                HStack {
                    Spacer()
                    
                    makeCheckmarkButton(style: .ultraThinMaterial)
                    makeCheckmarkButton(style: Colors.accent)
                }
                .padding(7)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        UniversalText(plant.name, size: Constants.UIHeaderTextSize, font: Constants.titleFont, wrap: false)
                            .textCase(.uppercase)
                        
                        UniversalText(plant.notes, size: Constants.UIDefaultTextSize, font: Constants.mainFont, wrap: false)
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding()
                .padding(7)
            }
        }
    }
}
