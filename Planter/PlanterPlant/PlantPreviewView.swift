//
//  PlantPreviewView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI

struct PlantPreviewView: View {
//    MARK: Vars
    let plant: PlanterPlant
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showingPlantView: Bool 
    @State var test: Bool = false
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeBackground(height: CGFloat = 300) -> some View {
        
        let alignment: Alignment = .center
        let normalBlurHeight: CGFloat = 2/5
        
        let gradient = LinearGradient(stops: [
            .init(color: .white, location: normalBlurHeight ),
            .init(color: .clear, location: 1 ) ],
                                      startPoint: .bottom,
                                      endPoint: .top)
        
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .foregroundStyle(.black)
                
                if let coverImage = plant.getCoverImage() {
                    coverImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: height, alignment: alignment)
                        .clipped()
                        .overlay {
                            coverImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: 40)
                                .padding(-40)
                                .frame(width: geo.size.width, height: height, alignment: alignment)
                                .clipped()
                                .mask(alignment: .bottom) {
                                    gradient
                                        .frame(height: height / 1.5)
//                                            .padding(.vertical, 20)
                                }
                        }
                        .allowsHitTesting(false)
                }
            }
            .frame(height: height, alignment: alignment)
            .cornerRadius(Constants.UIDefaultCornerRadius)
        }.frame(height: height)
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
        .onTapGesture { withAnimation { test = true }}
        .planterSheet(isPresented: $test, transition: .slide) {
            PlantView(plant: plant)
            
//            Text(self.plant.name)
//                .onTapGesture {
//                    withAnimation { showingPlantView = false }
//                }
        }

//        .onTapGesture { showingPlantView = true }
    }
}
