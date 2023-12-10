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
    
//    MARK: Vars
    @Environment( \.colorScheme ) var colorScheme
    @Environment( \.presentationMode ) var presentationMode
    @Environment( \.planterSheetDismiss ) var planterSheetDismiss
    
    let plant: PlanterPlant
    let image: Image
    
    init( plant: PlanterPlant ) {
        self.plant = plant
        
        self.image = self.plant.getCoverImage() ?? Image("fern")
    }
    
    @State var activePage: PlantPageTab = .comments
    
//    MARK: TabBar
    @ViewBuilder
    private func makeTabBarNode( tab: PlantPageTab ) -> some View {
        
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 5)
                .cornerRadius(10)
            
            UniversalText( tab.rawValue,
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.mainFont,
                           case: .uppercase,
                           wrap: false,
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
    
//    MARK: Background
    @ViewBuilder
    private func makeBackground() -> some View {
        
        ZStack {
            self.image
                .resizable()
                .scaledToFill()
                .blur(radius: 30)
                .clipped()
                .ignoresSafeArea()
            
            Colors.secondaryLight.opacity(0.55)
                .ignoresSafeArea()
        }
    }
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                makeTabBar()
                    .padding([.horizontal, .top], 7)
                
                TabView(selection: $activePage) {
                    
                    PlantOverviewView(plant: plant,
                                      geo: geo,
                                      image: image)
                    .tag( PlantView.PlantPageTab.overview )

                    PlantCommentsView(plant: plant,
                                      geo: geo,
                                      image: image)
                    .tag( PlantView.PlantPageTab.comments )
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
            .background { makeBackground() }
        }
    }
}


#Preview {
    let plant = PlanterPlant(ownerID: "100",
                             name: "Cactus",
                             notes: "cool plant",
                             wateringInterval: 7,
                             coverImageData: Data())
    
    return PlantView(plant: plant)
}
