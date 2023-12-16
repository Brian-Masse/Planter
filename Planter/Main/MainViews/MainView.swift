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
        
        func getDisplayString() -> String {
            switch self {
            case .calendarPageView: return "Cale ndar"
            case .roomsPageView: return "Roo ms"
            }
        }
    }

//    MARK: Vars
    @ObservedResults( PlanterPlant.self ) var plants
    @ObservedResults( PlanterRoom.self ) var rooms
    
    var model: PlanterModel = PlanterModel()

    @State var page: MainPage = .calendarPageView
    @State var showingProfileView: Bool = false
    
//    MARK: TabBar
    struct TabBar: View {
        
        @Binding var page: MainPage
        @Binding var showingProfileView: Bool
        
        @ViewBuilder
        private func makeTabBarButton(page: MainPage ) -> some View {
            
            VStack {
                LargeTextButton( page.getDisplayString(),
                                 at: 0,
                                 aspectRatio: 1,
                                 arrow: false,
                                 style: self.page == page ? Colors.accent : Colors.secondaryLight) {
                    self.page = page
                }
            }
            .scaleEffect(1.25)
            .shadow(color: .black.opacity(0.4), radius: 10, y: 10)
            
        }
        
        var body: some View {
         
            
            ZStack(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 5) {

                    makeTabBarButton(page: .calendarPageView)
                    Spacer()
                    makeTabBarButton(page: .roomsPageView)
                }
                .padding(.horizontal)
                
                LargeTextButton("pro file", at: 30, aspectRatio: 1.6, verticalTextAlignment: .top, arrowDirection: .down) {
                    showingProfileView = true
                }
                .padding(.leading)
                .scaleEffect(1.25)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 10)
            }
            .padding()
            .padding(.bottom, 25)
            
        }
    }
    
//    MARK: Body
    var body: some View {
        
        let arrPlants = Array( plants )
        let arrRooms = Array(rooms)
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                TabView(selection: $page) {
                    CalendarPageView(plants: arrPlants).tag( MainPage.calendarPageView )
                    RoomsPageView(rooms: arrRooms).tag( MainPage.roomsPageView )
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                TabBar(page: $page, showingProfileView: $showingProfileView)
                    .frame(maxWidth: geo.size.width)
            }
            .ignoresSafeArea()
            .sheet(isPresented: $showingProfileView) {
                ProfileView( PlanterModel.profile )
                
            }
        }
        .universalImageBackground( PlanterModel.profile.getProfilePicture() )
    }
}

