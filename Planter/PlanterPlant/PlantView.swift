//
//  PlanterView.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI

struct PlantView: View {
    
    enum PlantPageTab: String, Identifiable, CaseIterable {
        case overview
        case calendar
        case comments
        
        var id: String {
            self.rawValue
        }
    }
    
    @Environment( \.colorScheme ) var colorScheme
    @Environment( \.presentationMode ) var presentationMode
    @Environment( \.planterSheetDismiss ) var planterSheetDismiss
    
    let plant: PlanterPlant
    
    let image: Image = Image("fern")
    
    @State var activePage: PlantPageTab = .overview
    
    
//    MARK: ViewBuilders
    
    @ViewBuilder
    private func makeDivider() -> some View {
        
        Rectangle()
            .foregroundStyle(.black)
            .frame(height: 1)
        
    }
    
//    MARK: Header
    @ViewBuilder
    private func makeTabBarNode( tab: PlantPageTab ) -> some View {
        
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 5)
                .cornerRadius(10)
            
            UniversalText( tab.rawValue, 
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.mainFont,
                           wrap: false,
                           case: .uppercase,
                           scale: true)
            .padding(.horizontal, 7)
        }
        .shadow(color: .black.opacity(0.7), radius: 20)
        .foregroundStyle( tab == activePage ? PlanterModel.shared.activeColor : Colors.secondaryLight  )
        .onTapGesture { withAnimation {
            activePage = tab
        } }
    }
    
    @ViewBuilder
    private func makeTabBar() -> some View {
        
        HStack {
            ForEach( PlantPageTab.allCases, id: \.self ) { content in
                makeTabBarNode(tab: content)
            }
        }
    }
    
    @ViewBuilder
    private func makeHeader(_ geo: GeometryProxy) -> some View {
        
        let latin = "Tracheophyta"
        
        VStack(alignment: .leading, spacing: 0) {
            makeTabBar()
            
            HStack(spacing: 0) {
                UniversalText(plant.name,
                              size: Constants.UILargeTextSize,
                              font: Constants.titleFont,
                              wrap: false, 
                              case: .uppercase, 
                              scale: true)
                
                Spacer()
                
                UniversalText( latin, size: Constants.UISubHeaderTextSize, font: Constants.mainFont )
                    .frame(width: geo.size.width / 5)
                
            }
            .padding(.bottom, -10)
            
            makeDivider()
            
            UniversalText( plant.notes, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                .padding(.vertical, 5)
            
            makeDivider()
        }
    }
    
//    MARK: MainBody
    @ViewBuilder
    private func makeMainBody(_ geo: GeometryProxy) -> some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                HStack {
                    UniversalText( "Master\nBedroom",
                                   size: Constants.UIHeaderTextSize,
                                   font: Constants.titleFont,
                                   case: .uppercase,
                                   lineSpacing: -22)
                    Spacer()
                }
                .padding(.bottom, -20)
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width - 30, height: 250)
                    .clipped()
                    .cornerRadius(Constants.UIDefaultCornerRadius)
                    .rotation3DEffect(
                        .degrees(8),
                        axis: (x: 1.0, y: -1.0, z: 0.0)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 15, x: 10, y: 15)
                    .padding(.bottom)
                
                HStack {
                    Spacer()
                    UniversalText( "status:\nGood",
                                   size: Constants.UIHeaderTextSize,
                                   font: Constants.titleFont,
                                   case: .uppercase,
                                   textAlignment: .trailing,
                                   lineSpacing: -22)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    LargeTextButton("water plant", at: 45, aspectRatio: 1.8, verticalTextAlignment: .top, arrowDirection: .down) {
                        print("hi")
                    }
                    .padding(.top, 30)
                    .padding()
                }
                Spacer()
                HStack {
                    LargeTextButton( "Edit Plant", at: -55, aspectRatio: 2.3, verticalTextAlignment: .top, arrowDirection: .down ) {
                        print("hello")
                    }
                    
                    Spacer()
                }
                .padding(.leading, 40)
            }
        }
        
    }
    
//    MARK: Background
    @ViewBuilder
    private func makeBackground() -> some View {
        
        ZStack {
            self.image
                .ignoresSafeArea()
                .blur(radius: 30)
                .padding(-50)
            
            Colors.secondaryLight.opacity(0.55)
                .ignoresSafeArea()
        }
    }
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                
                makeHeader(geo)
                
                makeMainBody(geo)
                    .padding(.top, -50)
                
                Spacer()
                
            }
            .padding(7)
            .background { makeBackground() }
        }
//        }
//        .ignoresSafeArea()
        
//        GeometryReader { geo in
//            ZStack(alignment: .bottom) {
//                VStack {
//                    
//                    let baseColor = colorScheme == .light ? Colors.baseLight : Colors.baseDark
//                    
//                    let gradient = LinearGradient(stops: [
//                        .init(color: baseColor, location: 0.1),
//                        .init(color: .clear, location: 0.4)
//                        
//                    ], startPoint: .bottom, endPoint: .top)
//                    
//                    if let image = plant.getCoverImage() {
//                        
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: geo.size.width, height: geo.size.height / 1.5)
//                            .clipped()
//                            .overlay {
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .blur(radius: 40)
//                                    .padding(-40)
//                                    .frame(width: geo.size.width, height: geo.size.height / 1.5)
//                                    .clipped()
//                                    .mask { gradient }
//                            }
//                            .overlay(alignment: .bottom) {
//                                gradient
//                            }
//                    }
//                    
//                    Spacer()
//                
//                    UniversalText(plant.name, size: Constants.UIDefaultTextSize)
//                    
//                    LargeRoundedButton("", icon: "arrow.down", wide: true) {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                    .padding(.bottom)
//                    
//                }
//        
//                
//                
//                
//                
//                
//                
//            }
//        }
//        .ignoresSafeArea()
//        .universalBackground()
    }
}


#Preview {
    let plant = PlanterPlant(ownerID: "100",
                             name: "Fern",
                             notes: "cool plant",
                             wateringInterval: 7,
                             coverImageData: Data())
    
    return PlantView(plant: plant)
}
