//
//  CalendarDayView.swift
//  Planter
//
//  Created by Brian Masse on 4/12/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct DayView: View {

//    MARK: Vars
    let day: Date
    let weekSchedule: [PlanterPlant.ScheduleNode]
    
    @Binding var showEmptyDays: Bool
    
    @State private var showingFullDay: Bool = true
    
    private var name: String {
        let style = Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day(.twoDigits)
        
        return day.formatted(style)
    }
    
    private var daySchedule: [PlanterPlant.ScheduleNode] {
        weekSchedule.filter { node in
            node.date.matches(day, to: .day)
        }
    }
    
//    MARK: Struct Methods
    private func getPlantCountMessage(from schedule: [PlanterPlant.ScheduleNode]) -> String {
        "\( schedule.count ) " + (schedule.count == 1 ? "plant" : "plants")
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
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makePlantCarousel() -> some View {
        VStack() {
            ForEach(daySchedule, id: \.plant.id) { node in
                PlantSmallPreviewView(plant: node.plant, accent: true)
            }
        }
        .scrollTargetLayout()
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
    
//    MARK: Body
    var body: some View {
        let daySchedule =   self.daySchedule
        
        if showEmptyDays || !daySchedule.isEmpty {
            makeBody(daySchedule: daySchedule)
        }
            
    }
}
