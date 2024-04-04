//
//  UniversalButtons.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI
import UIUniversals

//MARK: ConditionalLargeRoundedButton

struct ConditionalLargeRoundedButton: View {
    
    let title: String
    let icon: String
    
    let wide: Bool
    let allowTapOnDisabled: Bool
    
    let condition: () -> Bool
    let action: () -> Void
    
    init( title: String, icon: String, wide: Bool = true, allowTapOnDisabled: Bool = false, condition: @escaping () -> Bool, action: @escaping () -> Void ) {
        self.title = title
        self.icon = icon
        self.wide = wide
        self.allowTapOnDisabled = allowTapOnDisabled
        self.condition = condition
        self.action = action
    }
    
    var body: some View {
        HStack {
            if wide { Spacer() }
            if title != "" { UniversalText(title, size: Constants.UISubHeaderTextSize, font: Constants.titleFont) }
            Image(systemName: icon)
            if wide { Spacer() }
            
        }
            .padding(10)
            .if( condition() ) { view in view.rectangularBackground(style: .accent) }
            .if( !condition() ) { view in view.rectangularBackground(style: .secondary) }
            .onTapGesture { withAnimation {
                if condition() || allowTapOnDisabled { action() }
            }}
    }
}

//MARK: ContextMenuButton

struct ContextMenuButton: View {
    
    let title: String
    let icon: String
    let action: () -> Void
    let role: ButtonRole?
    
    init( _ title: String, icon: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.role = role
        self.action = action
    }
    
    var body: some View {
            
        Button(role: role, action: action) {
            Label(title, systemImage: icon)
        }
    }
}
