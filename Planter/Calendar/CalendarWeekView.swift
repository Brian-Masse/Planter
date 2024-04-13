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
    
//    MARK: DayView
    private struct DayView: View {
        
        let day: Date
        let weekSchedule: [PlanterPlant.ScheduleNode]
        
        @Binding var showEmptyDays: Bool
        
        @State private var showingFullDay: Bool = true
        
        private var name: String {
            let style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day(.twoDigits)
            
            return day.formatted(style)
        }
        
        private func getPlantCountMessage(from schedule: [PlanterPlant.ScheduleNode]) -> String {
            "\( schedule.count ) " + (schedule.count == 1 ? "plant" : "plants")
        }
        
        private var daySchedule: [PlanterPlant.ScheduleNode] {
            weekSchedule.filter { node in
                node.date.matches(day, to: .day)
            }
        }
        
//        states whether all the plants on a given date have been watered, are to be watered, or are overdue
        private func getWateringCompletion(from schedule: [PlanterPlant.ScheduleNode]) -> PlanterPlant.PlantWateringCompletion {
            
            for node in schedule {
                let status = node.plant.getWateringStatus(from: day)
                if status == .missed { return .missed }
                if status == .upcoming { return .upcoming }
            }
            
            return .completed
        }
        
        private func getCompletionIcon(from completion: PlanterPlant.PlantWateringCompletion) -> String {
            switch completion {
            case .completed: return "checkmark"
            case .missed: return "xmark"
            case .upcoming: return ""
            }
        }
        
        @ViewBuilder
        private func makePlantCarousel() -> some View {
//            ScrollView(.vertical, showsIndicators: false) {
                VStack() {
                    ForEach(daySchedule, id: \.plant.id) { node in
                        
                        PlantSmallPreviewView(plant: node.plant)
//                        PlantFullPreviewView( plant: node.plant)
                    }
                }
                .scrollTargetLayout()
//            }
//            .scrollTargetBehavior(.viewAligned)
        }
        
        @ViewBuilder
        private func makeBody(daySchedule: [PlanterPlant.ScheduleNode]) -> some View {
            let status =        self.getWateringCompletion(from: daySchedule)
            
            RoundedContainer("") {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            UniversalText( name, size: Constants.UISubHeaderTextSize, font: Constants.mainFont, case: .uppercase )
                            
                            if daySchedule.count > 0 {
                                UniversalText( getPlantCountMessage(from: daySchedule), size: Constants.UISmallTextSize, font: Constants.mainFont )
                            }
                        }
                        
                        let icon = self.getCompletionIcon(from: status)
                        if icon != "" {
                            ResizableIcon(icon, size: Constants.UIDefaultTextSize)
                                .padding(.top, Constants.UISubPadding)
                        }
                        
                        Spacer()
                        
                        if daySchedule.count > 0 {
                            IconButton(showingFullDay ? "chevron.up" : "chevron.down", size: Constants.UISmallTextSize) { showingFullDay.toggle() }
                                .padding(.top, Constants.UISubPadding)
                        }
                    }
                    .opacity( daySchedule.isEmpty ? 0.4 : 1 )
                    .onBecomingVisible { showingFullDay = status != .completed }
                    .onChange(of: weekSchedule) { withAnimation { showingFullDay = status != .completed }}
                    .padding(.horizontal, Constants.UISubPadding)
                    
                    if showingFullDay {
                        makePlantCarousel()
                    }
                }
            }.onTapGesture { withAnimation { showingFullDay.toggle() } }
        }
        
        var body: some View {
            let daySchedule =   self.daySchedule
            
            if showEmptyDays || !daySchedule.isEmpty {
                makeBody(daySchedule: daySchedule)
            }
                
        }
    }
    
    
//    MARK: Body
    var body: some View {
        
        let weekSchedule = self.weekSchedule
        
        VStack(alignment: .leading ) {
            makeWeekSelector()
        
            Spacer()
            
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach( 1...7, id: \.self ) { i in
                            let day = Calendar.current.date(byAdding: .weekday, value: i - 1, to: week)!
                            
                            DayView(day: day, weekSchedule: weekSchedule, showEmptyDays: $showEmptyDays)
                        }
                        makeShowAllDaysToggle()
                        
                    }
                    .padding(.bottom)
                    .gesture(swipeGesture)
                }
            }
        }
    }
}
