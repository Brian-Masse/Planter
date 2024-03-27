//
//  PlanterUniversals.swift
//  Planter
//
//  Created by Brian Masse on 12/10/23.
//

import Foundation
import SwiftUI
import UIUniversals

//    MARK: TabBar
struct HeaderTabBar<T: CaseIterable>: View where T: RawRepresentable, T: Hashable, T.AllCases: RandomAccessCollection, T.RawValue == String {
    
    @ViewBuilder
    private func makeTabBarNode( tab: T ) -> some View {
        
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 5)
                .cornerRadius(10)
            
            UniversalText( tab.rawValue,
                           size: Constants.UIDefaultTextSize,
                           font: Constants.mainFont,
                           case: .uppercase,
                           wrap: false,
                           scale: true)
            .padding(.horizontal, 7)
        }
        .shadow(color: .black.opacity(0.7), radius: 20)
        .if( tab == activeTab ) { view in view.universalStyledBackgrond(.accent, onForeground: true) }
        .if( tab != activeTab ) { view in view.universalStyledBackgrond(.secondary, onForeground: true)}
        .onTapGesture { withAnimation {
            activeTab = tab
        } }
    }
    
    @Binding var activeTab: T
    
    var body: some View {
        HStack {
            
            ForEach( T.allCases, id: \.self ) { content in
                makeTabBarNode(tab: content)
            }
            
        }
    }
}

//MARK: Vertical Layout
struct VerticalLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let size = subviews.first!.sizeThatFits(.unspecified)
        return .init(width: size.height, height: size.width)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first!.place(at: .init(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: .unspecified)
    }
}