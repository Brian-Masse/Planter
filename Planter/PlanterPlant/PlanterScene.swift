//
//  PlanterScene.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI

struct PlanterScene<Content: View, Scene>: View where Scene: CaseIterable, Scene: RawRepresentable, Scene: Identifiable, Scene.AllCases: RandomAccessCollection, Scene.RawValue == Int {
    
    let contentBuilder: ( Scene ) -> Content
    
//    MARK: Vars
    @Binding var sceneState: Scene
    @Binding var sceneComplete: Bool
    
    let submit: () -> Void
    
    let allowsSceneRegression: Bool
    
    init( _ scene: Binding<Scene>, sceneComplete: Binding<Bool>, canRegressScene: Bool, submit: @escaping() -> Void, contentBuilder: @escaping ( Scene ) -> Content ) {
        
        
        self.contentBuilder = contentBuilder
        self._sceneState = scene
        self._sceneComplete = sceneComplete
        self.submit = submit
        
        self.allowsSceneRegression = canRegressScene
    }
    
//    MARK: StructMethods
    private var onLastPage: Bool {
        sceneState.rawValue == Scene.allCases.count - 1
    }
    
    private func progressScene() {
        withAnimation {
            if onLastPage {
                submit()
            } else if sceneComplete {
                sceneState = Scene(rawValue: sceneState.rawValue + 1) ?? sceneState
            }
        }
//        sceneComplete = false
    }
    
    private func regressScene() {
        if allowsSceneRegression { withAnimation {
            sceneState = Scene( rawValue: sceneState.rawValue - 1 ) ?? sceneState
        } }
        sceneComplete = true
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            
            contentBuilder( sceneState )
            
            Spacer()
            
            LargeRoundedButton("next", icon: "arrow.forward", wide: true) { progressScene() }
            LargeRoundedButton("previous", icon: "arrow.backward", wide: true) { regressScene() }
        }
        .padding()
        .universalColoredBackground( PlanterModel.shared.activeColor )
        
    }
    
}
