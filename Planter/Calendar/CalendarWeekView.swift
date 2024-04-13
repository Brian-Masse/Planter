//
//  CalendarWeekView.swift
//  Planter
//
//  Created by Brian Masse on 4/12/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct CalendarWeekView: View {
    
//    MARK: Vars
    let plants: [PlanterPlant]
    let schedule: [PlanterPlant.ScheduleNode]
    
    @Binding var activeMonth: Date
    
    @State var showEmptyDays: Bool = true
    
    var weekSchedule: [PlanterPlant.ScheduleNode] {
        let dayOfMonth = Calendar.current.component(.day, from: week) + 7
        return schedule.filter { node in
            
            let specificDay = Calendar.current.component(.day, from: node.date)

            let difference = dayOfMonth - specificDay
            
            return difference < 7 && difference > 0
        }
    }
    
    init(plants: [PlanterPlant], schedule: [PlanterPlant.ScheduleNode], activeMonth: Binding<Date>) {
        self.plants = plants
        self.schedule = schedule
        self._activeMonth = activeMonth
    }

    
    private var week: Date {
        let weekDay = Calendar.current.component(.weekday, from: activeMonth)
        
        return Calendar.current.date(byAdding: .weekday, value: -(weekDay - 1), to: activeMonth) ?? activeMonth
    }
    
    private var weekName: String {
        let style = Date.FormatStyle().month(.defaultDigits).day(.twoDigits)
        
        return "week of Sunday, \( week.formatted(style) )"
    }
    
    private func progressWeek(backward: Bool = false) {
        let newDate = Calendar.current.date(byAdding: .weekOfYear, value: backward ? -1 : 1, to: activeMonth)
        
        activeMonth = newDate ?? activeMonth
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let direction = value.translation.width / abs(value.translation.width)
                withAnimation{
                    progressWeek(backward: direction == 1 )
                }
            }
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeWeekSelector() -> some View {
        HStack {
            IconButton("chevron.left") { progressWeek(backward: true) }
            
            UniversalText( weekName, size: Constants.UISubHeaderTextSize, font: Constants.mainFont, case: .uppercase )
            
            IconButton("chevron.right") { progressWeek() }
        }
    }
    
    @ViewBuilder
    private func makeShowAllDaysToggle() -> some View {
        let message = showEmptyDays ? "hide empty days" : "show empty days"
        let icon    = showEmptyDays ? "square.3.layers.3d.down.right.slash" : "square.3.layers.3d.down.right"
        
        HStack {
            
            Spacer()
            UniversalText( message, size: Constants.UISmallTextSize, font: Constants.mainFont )
            ResizableIcon( icon, size: Constants.UISmallTextSize )
            Spacer()
        }
        .if(showEmptyDays) { view in view.foregroundStyle(.black) }
        .rectangularBackground( style: showEmptyDays ? .accent : .secondary )
        .onTapGesture { withAnimation { showEmptyDays.toggle() } }
        
    }
    
//    MARK: Body
    var body: some View {
        
        let weekSchedule = self.weekSchedule
        
        VStack(alignment: .leading ) {
            makeWeekSelector()
                .padding(.horizontal, Constants.UISubPadding)
        
            Spacer()
            
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach( 1...7, id: \.self ) { i in
                            let day = Calendar.current.date(byAdding: .weekday, value: i - 1, to: week)!
                            
                            DayView(day: day, weekSchedule: weekSchedule, showEmptyDays: $showEmptyDays)
                        }
                        makeShowAllDaysToggle()
                            .padding(.bottom, Constants.UIBottomPagePadding)
                        
                    }
                    .padding(.bottom)
//                    .gesture(swipeGesture)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
