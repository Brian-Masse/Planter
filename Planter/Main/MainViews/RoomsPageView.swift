//
//  RoomsPageView.swift
//  Planter
//
//  Created by Brian Masse on 12/2/23.
//

import Foundation
import SwiftUI

struct RoomsPageView: View {
    
    let rooms: [PlanterRoom]
    
    @State var showingRoomCreationView: Bool = false
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                UniversalText( "Rooms", size: Constants.UITitleTextSize, font: Constants.mainFont )
                    .textCase(.uppercase)
                
                Spacer()
            }
            
            ForEach( rooms ) { room in
            
                VStack(alignment: .leading) {
                    HStack {
                        
                        UniversalText( room.name, size: Constants.UISubHeaderTextSize, font: Constants.titleFont )
                        
                        Spacer()
                        
                        UniversalText( "\(room.plants.count) plants", size: Constants.UISubHeaderTextSize, font: Constants.titleFont )
                        
                    }
                    
                    UniversalText( room.notes, size: Constants.UISubHeaderTextSize, font: Constants.titleFont )
                    
                }
                .secondaryOpaqueRectangularBackground()
                
            }
            
            Spacer()
            
            LargeTextButton("Create Room", at: -90, aspectRatio: 2.1, verticalTextAlignment: .top) {
                showingRoomCreationView = true
            }
            .padding()
        }
        .padding(.bottom, 100)
        .sheet(isPresented: $showingRoomCreationView) {
            RoomCreationScene()
        }
    }
}
