//
//  PlantCommentsView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI
import RealmSwift
import UIUniversals

struct PlantCommentsView: View {
    
//    MARK: Vars
    @ObservedResults( PlanterRoom.self ) var rooms
    
    let plant: PlanterPlant
    let geo: GeometryProxy
    let image: Image
    
    @State var showingRoomSelectionView: Bool = false
    
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeRoomSelectionPreviewView(_ room: PlanterRoom) -> some View {
        HStack {
            UniversalText( room.name, size: Constants.UISubHeaderTextSize, font: Constants.mainFont, case: .uppercase )
            
            Spacer()
            
            UniversalText( "\(room.plants.count) plants", size: Constants.UIDefaultTextSize, font: Constants.mainFont )
        }
        .rectangularBackground(style: .secondary)
        .onTapGesture {
            showingRoomSelectionView = false
            
            room.addPlant( plant )
        }
    }
    
    @ViewBuilder
    private func makeRoomSelectionView() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                UniversalText("Select Room", size: Constants.UITitleTextSize, font: Constants.mainFont, case: .uppercase)
                
                Spacer()
            }
            
            ForEach( rooms ) { room in
                makeRoomSelectionPreviewView(room)
            }
            
            Spacer()
        }
        .padding(7)
        .universalStyledBackgrond(.accent)
        
    }
    
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {

            ForEach( plant.wateringHistory, id: \.self ) { node in

                Text(node.comments)

            }
            
            Spacer()
            
            LargeTextButton("Add to Room", at: 45, arrowDirection: .up) {
                showingRoomSelectionView = true
            }
        }
        .sheet(isPresented: $showingRoomSelectionView) {
            makeRoomSelectionView()
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
