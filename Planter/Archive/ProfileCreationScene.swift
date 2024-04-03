//
//  ProfileCreationScene.swift
//  Planter
//
//  Created by Brian Masse on 12/10/23.
//

import Foundation
import SwiftUI

struct ProfileCreationScene: View {
    
//    MARK: Vars
    
    enum ProfileCreationScene: Int, CaseIterable, Identifiable {
        case name
        case contact
        case birthday
        
        var id: Int {
            self.rawValue
        }
    }
    
    @State var scene: ProfileCreationScene = .name
    @State var sceneComplete: Bool = false
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var userName: String = ""
    
    @State var email: String = ""
    @State var phoneNumber: Int = 0
    @State var birthday: Date = .now
    
//    MARK: Struct Methods
    @MainActor
    private func submit() {
        
        let profile = PlanterProfile(ownerId: PlanterModel.shared.ownerID,
                                     firstName: firstName,
                                     lastName: lastName,
                                     userName: userName,
                                     email: email,
                                     phoneNumber: phoneNumber,
                                     birthday: birthday)
        
        RealmManager.addObject( profile )
        
        PlanterModel.shared.setProfile(profile)
        
        PlanterModel.shared.setState(to: .app)
        
    }
    
    private func checkNameSceneCompletion() -> Bool {
        !firstName.isEmpty && !lastName.isEmpty && !userName.isEmpty
    }
    
    private func checkContactSceneCompletion() -> Bool {
        !email.isEmpty && "\(phoneNumber)".count >= 9
    }
    
//    MARK: ViewBuilder
    private func makeNameScene() -> some View {
        VStack(alignment: .leading) {
            
            StyledTextField($firstName, prompt: "First Name")
            
            StyledTextField($lastName, prompt: "Last Name")
            
            StyledTextField($userName, prompt: "userName")
            
        }
        .onChange(of: firstName) { sceneComplete = checkNameSceneCompletion() }
        .onChange(of: lastName) { sceneComplete = checkNameSceneCompletion() }
        .onChange(of: userName) { sceneComplete = checkNameSceneCompletion() }
    }
    
    private func makeContactScene() -> some View {
        VStack(alignment: .leading) {
            
            let phoneBinding: Binding<String> = {
                Binding {
                    phoneNumber.formatIntoPhoneNumber()
                } set: { (newValue, _) in
                    phoneNumber = Int( newValue.removeNonNumbers() ) ?? phoneNumber
                }
            }()
            
            StyledTextField($email, prompt: "email")
            
            StyledTextField(phoneBinding, prompt: "phone number")
                .keyboardType(.numberPad)
        }
        .onChange(of: email) { sceneComplete = checkContactSceneCompletion() }
        .onChange(of: phoneNumber) { sceneComplete = checkContactSceneCompletion() }
    }
    
    private func makeBirthdayScene() -> some View {
        VStack(alignment: .leading) {
            
//            StyledDatePicker($birthday, title: "birthay")
            
        }
        .onAppear { sceneComplete = true }
        
    }
    
    
//    MARK: Body
    var body: some View {
        
        PlanterScene($scene,
                     sceneComplete: $sceneComplete,
                     canRegressScene: true,
                     submit: submit) { scene in
            
            VStack {
                switch scene {
                case .name: makeNameScene()
                case .contact: makeContactScene()
                case .birthday: makeBirthdayScene()
                    
                }
            }
        }
    }
}
