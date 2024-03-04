//
//  PlanterView.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI
import UIUniversals

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
        
        self.image = PhotoManager.decodeImage(from: plant.coverImage) ?? Image("fern")
    }
    
    @State var activePage: PlantPageTab = .overview
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                HeaderTabBar(activeTab: $activePage)
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
            .universalImageBackground(self.image)
        }
    }
}


//#Preview {
//    let plant = PlanterPlant(ownerID: "100",
//                             name: "Cactus",
//                             notes: "cool plant",
//                             wateringInterval: 7,
//                             coverImageData: Data())
//    
//    return PlantView(plant: plant)
//}
