//
//  UniversalButtons.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI

//MARK: LargeTextButton
struct LargeTextButton: View {
    
    enum ArrowDirection: Int {
        
        case up = 1
        case down = -1
        
        func translateToAlignment() -> Alignment {
            switch self {
            case .up: return .top
            case .down: return .bottom
            }
        }
        
    }
    
    let text: String
    let angle: Double

    let aspectRatio: Double
    let verticalTextAlignment: Alignment
    
    let arrowDirection: ArrowDirection
    let arrowWidth: CGFloat
    let arrow: Bool
    
    let action: () -> Void
    
    init( _ text: String,
          at angle: Double,
          aspectRatio: Double = 1/2,
          verticalTextAlignment: Alignment = .bottom,
          arrow: Bool = true,
          arrowDirection: ArrowDirection = .down,
          arrowWidth: CGFloat = 4,
          action: @escaping () -> Void
    ) {
        
        self.text = text
        self.angle = angle
        self.aspectRatio = aspectRatio
        self.verticalTextAlignment = verticalTextAlignment
        
        self.arrow = verticalTextAlignment == .center ? false : arrow
        self.arrowWidth = arrowWidth
        self.arrowDirection = arrowDirection
        
        self.action = action
    
    }
    
    @ViewBuilder
    private func makeShape(_ contentMode: ContentMode) -> some View {
        
        Rectangle()
            .aspectRatio(1 / aspectRatio, contentMode: contentMode)
            .frame(width: 100)
            .foregroundStyle( PlanterModel.shared.activeColor )
            .cornerRadius(Constants.UIDefaultCornerRadius)
    }
    
    @ViewBuilder
    private func makeArrow() -> some View {

        let halfArrowWidth = arrowWidth / 2
        
        GeometryReader { geo in
            
            ZStack(alignment: arrowDirection.translateToAlignment() ) {
                Rectangle()
                    .foregroundStyle(.clear)
                
                Rectangle()
                    .frame(width: arrowWidth)
                
                let arrowHeadWidth = geo.size.width / 2.5
                
                Group {
                    Rectangle()
                        .offset(x: -arrowHeadWidth / 2 + halfArrowWidth)
                        .frame(width: arrowHeadWidth, height: arrowWidth)
                        .rotationEffect(.degrees( Double(arrowDirection.rawValue) * -45))
                    
                    Rectangle()
                        .offset(x: arrowHeadWidth / 2 - halfArrowWidth)
                        .frame(width: arrowHeadWidth, height: arrowWidth)
                        .rotationEffect(.degrees( Double(arrowDirection.rawValue) * 45))
                }
                .offset(y: CGFloat(arrowDirection.rawValue) * -arrowWidth)
            }
        }
    }
    
    private func transformText() -> String {
        var text = text.components(separatedBy: .whitespaces).reduce("") { partialResult, str in
            partialResult + "\n" + str
        }
        text.removeFirst()
        return text
    }
    
    private func degreeToRad() -> Double { angle * ( Double.pi / 180 ) }
    
    private func invertVerticalTextAlignment() -> Alignment {
        switch verticalTextAlignment {
        case .top: return .bottom
        case .bottom: return .top
        default: return verticalTextAlignment
        }
    }
    
    var body: some View {
        
        let transformedText = transformText()
        
        RotatedLayout(at: degreeToRad(), scale: 0.9) {
            ZStack(alignment: verticalTextAlignment) {
                
                makeShape(.fit)
                    .overlay() { if arrow {
                        GeometryReader { geo in
                            ZStack(alignment: invertVerticalTextAlignment() ) {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                
                                makeArrow()
                                    .if(verticalTextAlignment == .top) { view in view.padding(.bottom, 20 ) }
                                    .if(verticalTextAlignment != .top) { view in view.padding(.vertical, 20 ) }
                                    .frame(height: geo.size.height / 2)
                            }
                        }
                    }}
                
                RotatedLayout(at: 0, scale: 0.7) {
                    UniversalText(transformedText,
                                  size: Constants.UIHeaderTextSize + 10,
                                  font: Constants.mainFont,
                                  case: .uppercase,
                                  scale: true,
                                  textAlignment: .center,
                                  lineSpacing: -25)
                    .scaleEffect(CGSize(width: 0.7, height: 0.7))
                    .rotationEffect(.degrees(-angle))
                    .allowsHitTesting(false)
                }
                .padding(.vertical)
                .mask(alignment: verticalTextAlignment ) { makeShape(.fill) }
            }
            .frame(width: 100, height: 100 * aspectRatio)
            .onTapGesture { withAnimation { action() } }
            .rotationEffect(.degrees(angle))
        }
    }
}

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
