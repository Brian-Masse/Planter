//
//  ProfileView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                UniversalText( "Profile", size: Constants.UITitleTextSize, font: Constants.titleFont )
                
                Spacer()
                
                LargeTextButton("log out", at: 0, aspectRatio: 1.5, verticalTextAlignment: .top) {
                    Task {
                        await PlanterModel.realmManager.logout()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .universalBackground()
        
        
        
    }
    
}
