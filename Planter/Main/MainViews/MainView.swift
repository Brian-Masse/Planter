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
    
//    MARK: TabBar
    struct TabBar: View {
        
        @Binding var page: MainPage
        
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
                
                Rectangle()
                    .frame(width: 120)
                    .aspectRatio(1/1.8, contentMode: .fit)
                    .cornerRadius(Constants.UILargeCornerRadius)
                    .rotationEffect(.degrees(25))
                    .foregroundStyle(PlanterModel.shared.activeColor)
                    .offset(x: 20, y: 10)
                    .padding(.trailing)
                
                
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
                
                TabBar(page: $page)
                    .frame(maxWidth: geo.size.width)
            }
        }
        .universalBackground()
    }
}

