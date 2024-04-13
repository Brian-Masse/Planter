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
    
    @State var showingPlantCreationScene: Bool = false
    
    private func getPageTitle(from page: MainView.MainPage) -> String {
        switch page {
        case .plants:   return "pla nts"
        case .calendar: return "cale ndar"
        case .social:   return "soc ial"
        case .profile:  return "pro file"
        }
    }
    
    private func getPageIcon(from page: MainView.MainPage) -> String {
        switch page {
        case .plants:   return "laurel.leading"
        case .calendar: return "list.bullet.rectangle.portrait"
        case .social:   return "shared.with.you"
        case .profile:  return "wallet.pass"
        }
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeTabBarButton(_ page: MainView.MainPage) -> some View {
        ResizableIcon(getPageIcon(from: page), size: Constants.UIDefaultTextSize)
            .frame(width: 45, height: 45)
            .if(page == self.page) { view in
                view
                    .foregroundStyle(.black)
                    .rectangularBackground(style: .accent, cornerRadius: Constants.UILargeCornerRadius)
                    .padding(.horizontal, 2)
            }
            .onTapGesture { withAnimation { self.page = page } }
            .shadow(color: page == self.page ? Colors.lightAccent.opacity(0.75) : .clear, radius: 20, x: 0, y: 0)
            .padding(.horizontal, -2)
            .zIndex(5)
    }
    
    @ViewBuilder
    private func makeHomeButton() -> some View {
        HStack {
            ResizableIcon("laurel.leading", size: Constants.UISubHeaderTextSize)
            ResizableIcon("laurel.trailing", size: Constants.UISubHeaderTextSize)
        }
        .onTapGesture { withAnimation { self.page = .plants }}
        .foregroundStyle(   page == .plants ? .black : Colors.getBase(from: colorScheme, reversed: true))
        .frame(width:       page == .plants ? 40 : 55, height: page == .plants ? 30: 55)
        .padding()
        .background(        page == .plants ? Colors.getAccent(from: colorScheme) : .clear )
        .background( .ultraThinMaterial )
        .cornerRadius( Constants.UILargeCornerRadius )
        .shadow(color:      page == .plants ? Colors.lightAccent.opacity(0.55) : .clear, radius: 20, x: 0, y: 0)
        .zIndex(10)
        
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
        ZStack(alignment: .top) {
            makeGradient()
            
            HStack(alignment: .center) {
                Spacer()
                
                makeHomeButton()
                
                HStack(spacing: 0) {
                    makeTabBarButton(.calendar)
                    makeTabBarButton(.profile)
                    makeTabBarButton(.social)
                }
                .rectangularBackground(7, style: .transparent, cornerRadius: Constants.UILargeCornerRadius)
                .frame(height: 75)
                
                Spacer()
            }
            .padding(.top, Constants.UISubPadding)
            .padding(Constants.UISubPadding + 10 )
            .shadow(color: .black, radius: 25, y: 5)
        }
        .frame(height: 160)
        .fullScreenCover(isPresented: $showingPlantCreationScene) {
            PlantCreationScene()
        }
    }
}

//MARK: Preview
struct TestTabView: View {
    
    @State var page: MainView.MainPage = .calendar
    
    var body: some View {
        VStack {
            Spacer()
            
            TabBarView(page: $page)
        }
        .background(.white)
        .ignoresSafeArea()
            
    }
    
}

#Preview {
    TestTabView()
}
