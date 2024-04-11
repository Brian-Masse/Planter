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
    let plants: [PlanterPlant]
    
    @State private var activeMonth: Date = Date.now
    private var schedule: [Date] {
        var schedule: [Date] = []
        for plant in plants {
            schedule += plant.getWateringSchedule(in: activeMonth)
        }
        schedule.sort { date1, date2 in
            date1 <= date2
        }
        return schedule
    }

    private var activeMonthName: String {
        let style = Date.FormatStyle().month(.abbreviated).year()
        
        return activeMonth.formatted(style)
    }
    
    private func progressMonth( backward: Bool = false ) {
        let newDate = Calendar.current.date(byAdding: .month, value: backward ? -1 : 1, to: activeMonth)
        
        self.activeMonth = newDate ?? activeMonth
    }
    
    private func getTotalPlants(on day: Date) -> Int {
        var total: Int = 0
        for date in schedule {
            if date.matches(day, to: .day) { total += 1 }
            else if date > day { break }
        }
        return total
    }
    
//    MARK: ViewBuilder
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
    }
    
    @ViewBuilder
    private func makeMonthSelector() -> some View {
        HStack(spacing: 0) {
            
            IconButton("chevron.left") { progressMonth(backward: true) }
                .padding(.horizontal, Constants.UISubPadding )
            
            UniversalText( activeMonthName, size: Constants.UISubHeaderTextSize, font: Constants.mainFont, case: .uppercase )
                .padding(.horizontal, Constants.UISubPadding )
            
            IconButton("chevron.right") { progressMonth() }
                .padding(.horizontal, Constants.UISubPadding )
            
            Spacer()
        }
    }
    
//    MARK: Calendar
    private func getWidthOfDay(_ geo: GeometryProxy) -> CGFloat {
        (geo.size.width - 20) / 7
    }
    
    @ViewBuilder
    private func makeWeekDay(day: Int) -> some View {
        let date = Calendar.current.date(bySetting: .weekday, value: day, of: .now)!
        let style = Date.FormatStyle().weekday(.abbreviated)
        
        HStack(spacing: 0) {
            Spacer()
            UniversalText( date.formatted(style), size: Constants.UISmallTextSize + 3, font: Constants.titleFont, case: .uppercase, wrap: false, scale: true )
            Spacer()
        }.opacity(0.8)
    }
    
    @ViewBuilder
    private func makeWeekDayHeader() -> some View {
        HStack(spacing: 0) {
            ForEach( 1...7, id: \.self ) { i in
                makeWeekDay(day: i)
            }
        }
    }
    
    @ViewBuilder
    private func makeDay( _ day: Date, geo : GeometryProxy ) -> some View {
        let plantsOnDay = getTotalPlants(on: day)
        
        HStack(alignment: .top) {
            Spacer()
            VStack {
                let style = Date.FormatStyle().day(.twoDigits)
                
                UniversalText( day.formatted(style), size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase, wrap: false, scale: true )
                
                if plantsOnDay > 0 {
                    UniversalText( "\( plantsOnDay )", size: Constants.UISmallTextSize, font: Constants.titleFont )
                }
                
                Spacer()
            }
            .padding(.vertical, Constants.UISubPadding)
            Spacer()
        }
        .universalTextStyle( reversed: plantsOnDay > 0 )
        .opacity( plantsOnDay > 0 ? 0.9 : 0.5)
        .frame(height: 75)
        .rectangularBackground(2, style: plantsOnDay > 0 ? .accent : .primary)
        .frame(maxWidth: getWidthOfDay(geo))
        
    }
    
    @ViewBuilder
    private func makeCalendar(geo : GeometryProxy) -> some View {
        
        let firstOfMonth = activeMonth.startOfMonth()
        let lastOfMonth = activeMonth.endOfMonth()
        let firstWeekDay = Calendar.current.component(.weekday, from: firstOfMonth)
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach( 0..<5, id: \.self ) { i in
                HStack(spacing: 0) {
                    ForEach( 0..<7, id: \.self) { j in
                        
                        let offset = (i * 7) + j - firstWeekDay + 1
                        let endOfMonth = Calendar.current.component(.day, from: lastOfMonth)
                        
                        if (i == 0 && j < firstWeekDay - 1) || (offset >= endOfMonth) {
                            Color.clear
                                .frame(width: getWidthOfDay(geo), height: 1)
                        } else {
                            let day = Calendar.current.date(byAdding: .day, value: offset, to: firstOfMonth)
                            
                            makeDay( day!, geo: geo)
                        }
                    }
                }
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            
            makeHeader()
            
            GeometryReader { geo in
                RoundedContainer("") {
                    makeMonthSelector()
                        .padding(.bottom, Constants.UISubPadding)
                    
                    makeWeekDayHeader()
                        .padding(.bottom, Constants.UISubPadding)
                    
                    makeCalendar(geo: geo)
                }
            }
            
            Spacer()
        }  
    }
}


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
