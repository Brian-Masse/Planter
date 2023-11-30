//
//  PlanterScene.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI

struct PlanterScene<Content: View, Scene>: View where Scene: CaseIterable, Scene: RawRepresentable, Scene: Identifiable, Scene.AllCases: RandomAccessCollection, Scene.RawValue: StringProtocol {
    
    let contentBuilder: ( Scene ) -> Content
    
    @Binding var sceneState: Scene
    
    init( _ scene: Binding<Scene>, contentBuilder: @escaping ( Scene ) -> Content ) {
        
        self.contentBuilder = contentBuilder
        self._sceneState = scene
        
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            
            ForEach( Scene.allCases ) { content in
                Text(content.rawValue)
            }
        }
        
    }
    
}
