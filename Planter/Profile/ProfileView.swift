//
//  ProfileView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    let profile: PlanterProfile = PlanterModel.profile
    
//    MARK: Body
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
            
            UniversalText( profile.fullName(), size: Constants.UIDefaultTextSize, font: Constants.titleFont )
            
            Spacer()
        }
        .padding()
        .universalBackground()
        
        
        
    }
    
}
