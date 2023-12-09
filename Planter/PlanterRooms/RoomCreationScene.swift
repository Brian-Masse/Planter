//
//  RoomCreationScene.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI


struct RoomCreationScene: View  {
    
    enum RoomCreationScene: Int, CaseIterable, Identifiable {
        case overview
        
        var id: Int {
            self.rawValue
        }
    }
    
//    MARK: Vars
    @State var scene: RoomCreationScene = .overview
    @State var sceneComplete: Bool = false
    
    @State var name: String = ""
    @State var notes: String = ""
    
//    MARK: Struct Methods
    private func submit() {
        
        let room = PlanterRoom(ownerId: PlanterModel.shared.ownerID,
                               secondaryOwners: [],
                               name: name,
                               notes: notes,
                               plants: [])
        
        RealmManager.addObject(room)
        
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeOverviewScene() -> some View {
        
        VStack(alignment: .leading) {
            
            TextFieldWithPrompt(title: "name", binding: $name)
            TextFieldWithPrompt(title: "notes", binding: $notes)
                
            Spacer()
        }
        .onChange(of: name) { oldValue, newValue in
            sceneComplete = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
    }
    
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
        
            PlanterScene($scene,
                         sceneComplete: $sceneComplete,
                         canRegressScene: true,
                         submit: submit) { scene in
                
                switch scene {
                case.overview:
                    makeOverviewScene()
                }
            }
        }
    }
}
