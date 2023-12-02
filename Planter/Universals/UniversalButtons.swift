//
//  UniversalButtons.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI


//MARK: LargeRoundedButton
struct LargeRoundedButton: View {
    
    let label: String
    let completedLabel: String
    let icon: String
    let completedIcon: String
    
    let completed: () -> Bool
    let action: () -> Void
    
    let small: Bool 
    let wide: Bool
    let color: Color?
    
    @State var tempCompletion: Bool = false
    
    init( _ label: String, to completedLabel: String = "", icon: String, to completedIcon: String = "", wide: Bool = false, small: Bool = false, color: Color? = nil, completed: @escaping () -> Bool = {false}, action: @escaping () -> Void ) {
        self.label = label
        self.completedLabel = completedLabel
        self.icon = icon
        self.completedIcon = completedIcon
        self.completed = completed
        self.action = action
        self.wide = wide
        self.small = small
        self.color = color
    }
    
    var body: some View {
        let label: String = (self.completed() || tempCompletion ) ? completedLabel : label
        let completedIcon: String = (self.completed() || tempCompletion ) ? completedIcon : icon
        
        HStack {
            if wide { Spacer() }
            if label != "" {
                UniversalText(label, size: Constants.UISubHeaderTextSize, font: .syneHeavy)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            
            if completedIcon != "" {
                Image(systemName: completedIcon)
            }
            if wide { Spacer() }
        }
        .padding(.vertical, small ? 7: 25 )
        .padding(.horizontal, small ? 25 : 25)
        .foregroundColor(.black)
        .if( color == nil ) { view in view.universalBackgroundColor() }
        .if( color != nil ) { view in view.background(color) }
        .cornerRadius(Constants.UIDefaultCornerRadius)
        .animation(.default, value: completed() )
        .onTapGesture { action() }
    }
}


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
            .if( condition() ) { view in view.tintRectangularBackground() }
            .if( !condition() ) { view in view.secondaryOpaqueRectangularBackground() }
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
