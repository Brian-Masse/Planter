//
//  MainView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct MainView: View {
    
    enum MainPage: String, CaseIterable, Identifiable {
        case calendarPageView
        case roomsPageView
        
        var id: String {
            self.rawValue
        }
    }

    @ObservedResults( PlanterPlant.self ) var plants
    
    var model: PlanterModel = PlanterModel()

    @State var page: MainPage = .calendarPageView
    @State var showingProfileView: Bool = false
    
//    MARK: TabBar
    struct TabBar: View {
        
        @Binding var page: MainPage
        @Binding var showingProfileView: Bool
        
        @ViewBuilder
        private func makeTabBarButton( icon: String, page: MainPage ) -> some View {
            
            Image(systemName: icon)
                .if(self.page == page) { view in
                    view.tintRectangularBackground(45,
                                                   cornerRadius: Constants.UILargeCornerRadius)
                }
                .if(self.page != page) { view in
                    view.transparentRectangularBackgorund(45,
                                                          cornerRadius: Constants.UILargeCornerRadius)
                }
                .onTapGesture {
                    withAnimation { self.page = page }
                }
                .shadow(color: .black.opacity(0.4), radius: 10, y: 10)
            
        }
        
        var body: some View {
         
            
            HStack(alignment: .bottom, spacing: 5) {
                makeTabBarButton(icon: "calendar", page: .calendarPageView)
                
                LargeTextButton("pro file", at: 45, aspectRatio: 1.8, verticalTextAlignment: .top, arrowDirection: .down) {
                    showingProfileView = true
                }
                
                makeTabBarButton(icon: "house", page: .roomsPageView)
            }
            .padding()
            .padding(.bottom, 15)
            
        }
    }
    
//    MARK: Body
    var body: some View {
        
        let arrPlants = Array( plants )
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                TabView(selection: $page) {
                    CalendarPageView(plants: arrPlants).tag( MainPage.calendarPageView )
                    RoomsPageView().tag( MainPage.roomsPageView )
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                TabBar(page: $page, showingProfileView: $showingProfileView)
                    .frame(maxWidth: geo.size.width)
            }
            .sheet(isPresented: $showingProfileView) {
                ProfileView()
                
            }
        }
        .universalBackground()
    }
}

