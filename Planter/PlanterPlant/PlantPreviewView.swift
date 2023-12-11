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
    enum Layout {
        case full
        case half
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    static let fullLayoutHeight: CGFloat = 300
    static let halfLayoutHeight: CGFloat = 150
    
    let plant: PlanterPlant
    let layout: Layout
     
    @State var showingPlantView: Bool = false
    
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
                
                if let coverImage = PhotoManager.decodeImage(from: plant.coverImage) {
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
    
    @ViewBuilder
    private func makeHeader() -> some View {
        HStack {
            VStack(alignment: .leading) {
                UniversalText(plant.name, 
                              size: Constants.UIHeaderTextSize,
                              font: Constants.titleFont,
                              wrap: false,
                              scale: false)
                    .textCase(.uppercase)
                
                UniversalText(plant.notes, size: Constants.UIDefaultTextSize, font: Constants.mainFont, wrap: false)
            }
            
            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
        .padding(7)
    }
    
//    MARK: Layouts
    @ViewBuilder
    private func makeFullSizedLayout() -> some View {
        ZStack(alignment: .bottom) {
            makeBackground(height: PlantPreviewView.fullLayoutHeight)
            
            VStack {
                HStack {
                    Spacer()
                    
                    makeCheckmarkButton(style: .ultraThinMaterial)
                    makeCheckmarkButton(style: Colors.accent)
                }
                .padding(7)
                
                Spacer()
                
                makeHeader()
            }
        }
    }
    
    @ViewBuilder
    private func makeHalfSizedLayout() -> some View {
        ZStack {
            makeBackground(height: PlantPreviewView.halfLayoutHeight)
            
            HStack {
                makeHeader()
                Spacer()
                makeCheckmarkButton(style: .ultraThinMaterial)
                    .padding(.trailing, 7)
            }
        }
        
    }
    
//    MARK: Body
    var body: some View {
        
        Group {
            
            switch layout {
            case .full: makeFullSizedLayout()
            case .half: makeHalfSizedLayout()
            }
            
        }
        .onTapGesture { withAnimation { showingPlantView = true }}
        .fullScreenCover(isPresented: $showingPlantView) {
            PlantView(plant: plant)
        }
    }
}
