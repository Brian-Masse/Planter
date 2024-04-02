//
//  TabBarView.swift
//  Planter
//
//  Created by Brian Masse on 4/1/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct TabBarView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var page: MainView.MainPage
    
    private func getPageTitle(from page: MainView.MainPage) -> String {
        switch page {
        case .plants:   return "pla nts"
        case .calendar: return "cale ndar"
        case .social:   return "soc ial"
        case .profile:  return "pro file"
        }
        
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeTabBarButton(_ page: MainView.MainPage) -> some View {
        LargeTextButton(getPageTitle(from: page), at: 0,
                        aspectRatio: 1,
                        cornerRadius: Constants.UILargeCornerRadius,
                        verticalTextAlignment: .center,
                        arrow: false,
                        fontSize: Constants.UIHeaderTextSize,
                        style: page == self.page ? .accent : .secondary) {
            self.page = page
        }
                        .shadow(color: page == self.page ? Colors.lightAccent.opacity(0.75) : .clear, radius: 20, x: 0, y: 0)
                        .padding(1)
    }
    
    @ViewBuilder
    private func makeNewPlantButton() -> some View {
        
        LargeTextButton("pla nt", at: 0,
                        aspectRatio: 1.6,
                        cornerRadius: Constants.UILargeCornerRadius,
//                        verticalTextAlignment: .center,
                        arrow: true,
                        arrowDirection: .up,
                        fontSize: Constants.UIHeaderTextSize,
                        style: .accent) {
            print("hello")
        }
                        .padding(.leading)
                        .shadow(color: page == self.page ? Colors.lightAccent.opacity(0.75) : .clear, radius: 20, x: 0, y: 0)
        
    }
    
    @ViewBuilder
    private func makeGradient() -> some View {
        LinearGradient(stops: [.init(color: Colors.getBase(from: colorScheme), location: 0),
                               .init(color: Colors.getBase(from: colorScheme).opacity(0.75), location: 0.65),
                               .init(color: .clear, location: 1)
                              ],
                       startPoint: .bottom, endPoint: .top)   
    }
    

//    MARK: Body
    var body: some View {
        HStack(alignment: .center) {
            makeNewPlantButton()
            
            Spacer()
            
            VStack {
                HStack {
                    makeTabBarButton(.plants)
                    makeTabBarButton(.calendar)
                }
                HStack {
                    makeTabBarButton(.profile)
                    makeTabBarButton(.social)
                }
            }
        }
        .padding(Constants.UISubPadding )
        .padding(.bottom)
        .background( makeGradient() )
    }
}
