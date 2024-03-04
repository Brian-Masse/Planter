//
//  PlantPreviewView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import UIUniversals

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
    
    
    
//    MARK: Background
    @ViewBuilder
    private func makeBackground(height: CGFloat = 300) -> some View {
        
        let alignment: Alignment = .center
        let normalBlurHeight: CGFloat = 1/5
        
        let gradient = LinearGradient(stops: [
            .init(color: .clear, location: 0 ),
            .init(color: .white, location: 1 - normalBlurHeight ) ],
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
                                .mask(alignment: .top) {
                                    gradient
                                        .frame(height: height )
                                }
                        }
                        .overlay {
                            gradient
                                .frame(height: height)
                                .opacity(0.2)
                        }
                        .allowsHitTesting(false)
                }
            }
            .frame(height: height, alignment: alignment)
            .cornerRadius(Constants.UIDefaultCornerRadius)
        }.frame(height: height)
    }
    
    @ViewBuilder
    private func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                UniversalText(plant.name,
                              size: Constants.UIHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              wrap: false,
                              scale: false)
                Spacer()
            }
                
            Divider()
            
            UniversalText(plant.room?.name ?? "No Room", size: Constants.UIDefaultTextSize,
                          font: Constants.mainFont,
                          case: .uppercase)
            
        }
        .foregroundStyle(.black)
        .padding()
    }
    
//    MARK: Layouts
    @ViewBuilder
    private func makeFullSizedLayout() -> some View {
        ZStack(alignment: .bottom) {
            makeBackground(height: PlantPreviewView.fullLayoutHeight)
            
            VStack {
                ZStack(alignment: .topTrailing) {
                    
                    makeHeader()
                    
                    LargeTextButton("Water Plant",
                                    at: 30,
                                    aspectRatio: 1.5,
                                    verticalTextAlignment: .bottom,
                                    arrowDirection: .up,
                                    style: .secondary) {
                        print("hello")
                    }
                                .scaleEffect(0.9)
                                .opacity(0.85)
                }

                Spacer()
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
//                makeCheckmarkButton(style: .ultraThinMaterial)
//                    .padding(.trailing, 7)
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
