//
//  CalendarMonthView.swift
//  Planter
//
//  Created by Brian Masse on 4/12/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct CalendarMonthView: View {
    
    let plants: [PlanterPlant]
    let schedule: [PlanterPlant.ScheduleNode]
    
    @Binding var activeMonth: Date
    @Binding var activeScene: CalendarPageView.CalendarPageScene
    
//    MARK: Struct Methods
    private func progressMonth( backward: Bool = false ) {
        let newDate = Calendar.current.date(byAdding: .month, value: backward ? -1 : 1, to: activeMonth)
        
        self.activeMonth = newDate ?? activeMonth
    }
    
    private var activeMonthName: String {
        let style = Date.FormatStyle().month(.abbreviated).year()
        
        return activeMonth.formatted(style)
    }
    
    private func getTotalPlants(on day: Date) -> Int {
        var total: Int = 0
        for node in schedule {
            if node.date.matches(day, to: .day) { total += 1 }
            else if node.date > day { break }
        }
        return total
    }
    
    private func switchToDay(_ day: Date) {
        let currentDayOfMonth   = Calendar.current.component(.day, from: activeMonth)
        let newDayOfMonth       = Calendar.current.component(.day, from: day)
        
        let newDate = Calendar.current.date(byAdding: .day, value: newDayOfMonth - currentDayOfMonth, to: activeMonth)
        
        withAnimation {
            self.activeMonth = newDate ?? activeMonth
            
            activeScene = .week
        }
    }
    
//    MARK: Gestures
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let direction = value.translation.width / abs( value.translation.width )
                withAnimation { progressMonth( backward: direction == 1 ) }
            }
    }
    
//    MARK: ViewBuilder
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
        .if(plantsOnDay > 0) { view in view.foregroundStyle(.black) }
        .universalTextStyle( reversed: plantsOnDay > 0 )
        .opacity( plantsOnDay > 0 ? 0.9 : 0.5)
        .frame(height: 75)
        .rectangularBackground(2, style: plantsOnDay > 0 ? .accent : .primary)
        .onTapGesture { switchToDay(day) }
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
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    makeMonthSelector()
                        .padding(.bottom, Constants.UISubPadding)
                    
                    RoundedContainer("") {
                        
                        makeWeekDayHeader()
                            .padding(.bottom, Constants.UISubPadding)
                        
                        makeCalendar(geo: geo)
                    }
                }
//                .gesture(sw   ipeGesture)
            }
        }
    }
}
