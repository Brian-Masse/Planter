//
//  AuthenticationView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI


struct AuthenticationView: View {
    
//    MARK: Vars
    @State var email: String = ""
    @State var password: String = ""
    
    
//    MARK: Struct Methods
    private func signInWithEmail() {
        Task {
            await PlanterModel.realmManager.signInWithEmail(email: email, password: password)
            await PlanterModel.shared.authenticateUser()
        }
    }

//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text( PlanterModel.realmManager.getLocalOwnerId() ?? "no text " )
            
            HStack {
                UniversalText( "Login", size: Constants.UITitleTextSize, font: Constants.titleFont, case: .uppercase )
                
                Spacer()
            }
            
            TextFieldWithPrompt(title: "email", binding: $email)
            TextFieldWithPrompt(title: "password", binding: $password)
            
            
            Spacer()
            
            LargeTextButton("log in", at: 30, aspectRatio: 2, verticalTextAlignment: .top) {
                signInWithEmail()
            }
            
        }
        .padding()
        .universalBackground()
        
    }

    
}
