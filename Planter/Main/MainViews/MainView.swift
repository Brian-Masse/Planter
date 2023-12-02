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
    
    
//    MARK: Body
    var body: some View {
        
        let arrPlants = Array( plants )
        
        VStack(alignment: .leading) {
            TabView(selection: $page) {
                CalendarPageView(plants: arrPlants).tag( MainPage.calendarPageView.rawValue )
                RoomsPageView().tag( MainPage.roomsPageView.rawValue )
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .universalBackground()
    }
}

