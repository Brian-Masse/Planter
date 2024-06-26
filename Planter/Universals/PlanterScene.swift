//
//  PlanterScene.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import UIUniversals


protocol PlanterSceneEnum: CaseIterable, RawRepresentable, Hashable, Identifiable where Self.AllCases: RandomAccessCollection, Self.RawValue == Int {
    func getTitle() -> String
}

struct PlanterScene<Content: View, Scene: PlanterSceneEnum>: View {
    
//    MARK: Vars
    @Environment(\.dismiss) var dismiss
    
    @Binding var sceneState: Scene
    @Binding var sceneComplete: Bool
    
    let contentBuilder: ( Scene ) -> Content
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
    }
    
    private func regressScene() {
        if sceneState.rawValue == 0 { dismiss() }
        if allowsSceneRegression { withAnimation {
            sceneState = Scene( rawValue: sceneState.rawValue - 1 ) ?? sceneState
        } }
        sceneComplete = true
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeSceneCompletionIndicator(scene: Scene) -> some View {
        Circle()
            .stroke(.black, lineWidth: 2)
            .fill( sceneState == scene ? .black : .clear )
            .frame(width: 8, height: 8)
    }
    
    @ViewBuilder
    private func makeSceneCompletionIndicators() -> some View {
        HStack {
            ForEach( Scene.allCases, id: \.self ) { scene in
                makeSceneCompletionIndicator(scene: scene)
            }
        }
    }
    
    @ViewBuilder
    private func makeHeader() -> some View {
        
        HStack(alignment: .bottom, spacing: Constants.UIHeaderPadding) {
            Spacer()
            
            IconButton(sceneState.rawValue == 0 ? "arrow.down" : "arrow.backward") { regressScene() }
            
            VStack {
                makeSceneCompletionIndicators()
                UniversalText( sceneState.getTitle(), size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase )
            }
            
            IconButton( sceneState.rawValue != Scene.allCases.count - 1 ? "arrow.forward" : "checkmark" ) { progressScene() }
                .opacity( sceneComplete ? 1 : 0.4 )
                
            
            Spacer()
        }
        .foregroundStyle(.black)
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            makeHeader()
                .padding(.bottom, Constants.UISubPadding)
            
            VStack(spacing: 0) {
                
                contentBuilder( sceneState )
                
                Spacer()
            }
            .padding(Constants.UISubPadding)
            .rectangularBackground(0, style: .secondary)
            .padding(.bottom, -60)
        }
//        .scrollDismissesKeyboard(.immediately)
        .ignoresSafeArea()
        .padding(.vertical)
        
        .universalBackground(style: .accent)
//        .ignoresSafeArea(.keyboard)
        
    }
    
}
