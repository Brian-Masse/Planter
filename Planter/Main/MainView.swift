//
//  MainView.swift
//  Planter
//
//  Created by Brian Masse on 11/26/23.
//

import Foundation
import SwiftUI
import RealmSwift
import UIUniversals

struct MainView: View {
    
//    MARK: MainPage Enum
    enum MainPage: String, CaseIterable, Identifiable {
        case plants
        case calendar
        case social
        case profile
        
        var id: String {
            self.rawValue
        }
    }

//    MARK: Vars
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedResults( PlanterPlant.self ) var plants
    @ObservedResults( PlanterRoom.self ) var rooms
    
    var model: PlanterModel = PlanterModel()

    @State var page: MainPage = .plants
    @State var showingProfileView: Bool = false
    
//    MARK: Body
    var body: some View {
        
        let arrPlants = Array( plants )
//        let arrRooms = Array(rooms)
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                NavigationView {
                    TabView(selection: $page) {
                        
                        PlantsPageView(plants: arrPlants)
                            .tag( MainPage.plants )
                        CalendarPageView(plants: arrPlants)
                            .tag( MainPage.calendar )
                        SocialPageView(profile: PlanterModel.profile, plants: arrPlants)
                            .tag( MainPage.social )
                        ProfilePageView(profile: PlanterModel.profile)
                            .tag( MainPage.profile )
                        
                    }
                    .tabViewStyle(.automatic)
                }
                
                TabBarView(page: $page)
            }
            .sheet(isPresented: $showingProfileView) {
                ProfileView( PlanterModel.profile )
                
            }
        }
        .ignoresSafeArea()
    }
}

