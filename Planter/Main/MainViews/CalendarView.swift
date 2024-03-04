//
//  CalendarView.swift
//  Planter
//
//  Created by Brian Masse on 12/21/23.
//

import Foundation
import SwiftUI
import UIUniversals


struct CalendarView: View {
    
//    MARK: Vars
    @Environment(\.colorScheme) var colorScheme
    
    let plants: [PlanterPlant]
    
    @State var activeDate: Date = .now
    
    @State var dateToHighlight: Date = .now
    
//    MARK: Gestures
    private func incremenetMonth(by value: Int) {
        let newDate = Calendar.current.date(byAdding: .month, value: value, to: activeDate)
        withAnimation {
            self.activeDate = newDate ?? activeDate
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                
                if value.translation.width > 0 {
                    incremenetMonth(by: -1)
                } else {
                    incremenetMonth(by: 1)
                }
            }
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader() -> some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    
                    UniversalText( activeDate.formatted(.dateTime.month(.wide)),
                                   size: Constants.UIHeaderTextSize,
                                   font: Constants.titleFont,
                                   case: .uppercase)
                    
                    UniversalText( activeDate.formatted(.dateTime.year(.defaultDigits)),
                                   size: Constants.UIHeaderTextSize,
                                   font: Constants.titleFont,
                                   case: .uppercase)
                    
                }
                
                Spacer()
                
                Menu {
                    ForEach(0..<12) { i in
                        
                        let newDate = activeDate.setMonth(to: i + 1)
                        
                        let monthName = newDate.formatted(.dateTime.month(.wide))
                        
                        Button( monthName) {
                            withAnimation {
                                activeDate = newDate
                            }
                        }
                    }
                } label: {
                    LargeTextButton("sel ect",
                                    at: 0,
                                    aspectRatio: 1,
                                    arrow: false,
                                    style: .secondary) {
                    }
                                    .foregroundStyle(.black)
                                    .shadow(color: .black.opacity(0.3), radius: 10, y: 10)
                    
                }
            }
            
            Divider()
        }
        .padding(.horizontal, 20)
    }
    
    
//    MARK: DayPreview
    @ViewBuilder
    private func makeDayPreview(for day: Date) -> some View {
        
        let dayTitle = day.formatted(.dateTime.day(.twoDigits))
        let isWeekend = day.matches(dayOfWeek: 1) || day.matches(dayOfWeek: 7)
        
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                if day.matches(.now, to: .day) {
                    Circle()
                        .universalStyledBackgrond(.accent)
                        .frame(width: 10, height: 10)
                }
                Spacer()
            }
            
            UniversalText(dayTitle, size: Constants.UISubHeaderTextSize, font:
                            Constants.titleFont)
            .opacity(isWeekend ? 0.5 : 1)
            
        }
        .frame(height: 60)
        .onTapGesture { withAnimation {
            dateToHighlight = day
        } }
        .background(
            Rectangle()
                .cornerRadius(Constants.UIDefaultCornerRadius)
                .padding(-7)
                .foregroundStyle( dateToHighlight.matches(day, to: .day) ? Colors.getAccent(from: colorScheme) : .clear)
        )
    }
    
    private func getDateOffset() -> Int {
        
        let componentDay = DateComponents(day: 1)
        
        let firstDayOfMonth = Calendar.current.nextDate(after: activeDate,
                                                        matching: componentDay, matchingPolicy: .previousTimePreservingSmallerComponents,
                                                        direction: .backward)
     
        let weekDay = Calendar.current.component(.weekday, from: firstDayOfMonth ?? activeDate)
        return weekDay - 1
    }
    
    @ViewBuilder
    private func makeDays() -> some View {
        
        let range = Calendar.current.range(of: .day, in: .month, for: activeDate)
        let dayCount = range?.count ?? 30
        
        let coloumns: CGFloat = 7
        let spacing: CGFloat = 7

        GeometryReader { geo in
            
            let min = (geo.size.width - (coloumns - 1) * spacing ) / coloumns
            let offset = getDateOffset()
            
            VStack(spacing: 0) {
                
                HStack {
                    ForEach(1...7, id: \.self) { day in
                        
                        let date = Calendar.current.date(bySetting: .weekday, value: day, of: activeDate)
                        
                        let title = date?.formatted(.dateTime.weekday(.abbreviated))
                        
                        Spacer()
                        UniversalText(title ?? "-",
                                      size: Constants.UIDefaultTextSize,
                                      font: Constants.titleFont,
                                      case: .uppercase,
                                      wrap: false,
                                      scale: true)
                        Spacer()
                    }
                }
                
                LazyVGrid(columns: [ .init(.adaptive(minimum: min, maximum: 100),
                                           spacing: spacing) ],
                          spacing: spacing) {
                    
                    ForEach( 1...dayCount + offset, id: \.self ) { day in
                        
                        if day <= offset {
                            Rectangle()
                                .foregroundStyle(.clear)
                            
                        } else {
                            let date = activeDate.setDay(to: day - offset)
                            
                            makeDayPreview(for: date)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(Rectangle())
                .gesture( dragGesture )
        )
    }
    
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            makeHeader()
            
            Spacer()
            
            makeDays()
        }
        .universalBackground()
    }
        
    
}

//#Preview {
//    CalendarView(plants: [])
//}


