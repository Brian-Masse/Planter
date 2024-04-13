//
//  CalendarPageView.swift
//  Planter
//
//  Created by Brian Masse on 4/5/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct CalendarPageView: View {
    
//    MARK: vars
    
    enum CalendarPageScene: String, Identifiable {
        case month
        case week
        
        var id: String { self.rawValue }
    }
    
    let plants: [PlanterPlant]
    
    @State private var calendarPageScene: CalendarPageScene = .month
    @State private var activeMonth: Date = Date.now
    
    private var schedule: [PlanterPlant.ScheduleNode] {
        var schedule: [PlanterPlant.ScheduleNode] = []
        for plant in plants {
            schedule += plant.getWateringSchedule(in: activeMonth)
        }
        schedule.sort { node1, node2 in
            node1.date <= node2.date
        }
        return schedule
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader() -> some View {
        UniversalText( "Calendar",
                       size: Constants.UIHeaderTextSize,
                       font: Constants.titleFont,
                       case: .uppercase)
        
        UniversalText( Date.now.formatted(date: .complete, time: .omitted),
                       size: Constants.UIDefaultTextSize,
                       font: Constants.mainFont,
                       case: .uppercase)
        .onTapGesture { withAnimation { activeMonth = Date.now } }
    }
    
    @ViewBuilder
    private func makeBody() -> some View {
        NavigationView {
            TabView(selection: $calendarPageScene) {
                CalendarMonthView(plants: plants, schedule: schedule, activeMonth: $activeMonth, activeScene: $calendarPageScene)
                    .tag( CalendarPageScene.month )
                
                CalendarWeekView(plants: plants, schedule: schedule, activeMonth: $activeMonth)
                    .tag( CalendarPageScene.week )
                
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            makeHeader()
            
            Spacer()
            
            makeBody()
        }
    }
}

//MARK: Preview
#Preview {
    
    let plant1 = PlanterPlant(ownerID: "100",
                              name: "fern",
                              roomName: "bedroom",
                              notes: "great",
                              wateringInstructions: "great",
                              wateringAmount: 4,
                              wateringInterval: 4,
                              statusImageFrequency: 1,
                              statusNotesFrequency: 1,
                              coverImageData: Data())
    
    let plant2 = PlanterPlant(ownerID: "100",
                              name: "cactus",
                              roomName: "bedroom",
                              notes: "great",
                              wateringInstructions: "great",
                              wateringAmount: 2,
                              wateringInterval: 10,
                              statusImageFrequency: 1,
                              statusNotesFrequency: 1,
                              coverImageData: Data())
    
    return CalendarPageView(plants: [plant1, plant2])
    
}
