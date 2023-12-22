//
//  CalendarView.swift
//  Planter
//
//  Created by Brian Masse on 12/21/23.
//

import Foundation
import SwiftUI



struct CalendarView: View {
    
//    MARK: Vars
    let plants: [PlanterPlant]
    
    @State var activeDate: Date = .now
    
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
                        
                        let newDate = Calendar.current.date(bySetting: .month,
                                                            value: i + 1,
                                                            of: activeDate)
                        
                        let monthName = newDate?.formatted(.dateTime.month(.wide))
                        
                        Button( monthName ?? "") {
                            withAnimation {
                                activeDate = newDate ?? activeDate
                            }
                        }
                    }
                } label: {
                    LargeTextButton("sel ect",
                                    at: 0,
                                    aspectRatio: 1,
                                    arrow: false,
                                    style: Colors.secondaryLight) {
                    }
                                    .foregroundStyle(.black)
                    
                }
                
                
                Spacer()
            }
            
            Divider()
                .padding(.trailing, 20)
        }
        .padding(.leading, 20)
    }
    
    
//    MARK: DayPreview
    @ViewBuilder
    private func makeDayPreview(for day: Date) -> some View {
        
        let dayTitle = day.formatted(.dateTime.day(.twoDigits))
        
        VStack {
            
            if day.matches(.now, to: .day) {
                Circle()
                    .foregroundStyle(PlanterModel.shared.activeColor)
                    .frame(width: 10, height: 10)
            }
            
            UniversalText(dayTitle, size: Constants.UISubHeaderTextSize, font:
                            Constants.titleFont)
        }
        
        
    }
    
    
//    MARK: Body
    var body: some View {
        
        VStack(alignment: .leading) {
            
            makeHeader()
            
            Spacer()
            
            makeDayPreview(for: .now)
            
        }
    }
    
}

#Preview {
    CalendarView(plants: [])
}


