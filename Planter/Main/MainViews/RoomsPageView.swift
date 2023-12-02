//
//  RoomsPageView.swift
//  Planter
//
//  Created by Brian Masse on 12/2/23.
//

import Foundation
import SwiftUI

struct RoomsPageView: View {
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                UniversalText( "Roooms", size: Constants.UITitleTextSize, font: Constants.mainFont )
                    .textCase(.uppercase)
                
                Spacer()
            }
            
            Spacer()
            
        }
        
    }
    
    
}
