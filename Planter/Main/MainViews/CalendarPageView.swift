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
    let plants: [PlanterPlant] = []
    
    @State private var activeMonth: Date = Date.now

    private var activeMonthName: String {
        let style = Date.FormatStyle().month(.abbreviated).year()
        
        return activeMonth.formatted(style)
    }
    
    private func progressMonth( backward: Bool = false ) {
        let newDate = Calendar.current.date(byAdding: .month, value: backward ? -1 : 1, to: activeMonth)
        
        self.activeMonth = newDate ?? activeMonth
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
        HStack {
            
            UniversalText( activeMonthName, size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
            
            IconButton("chevron.left") { progressMonth(backward: true) }
                .padding(.horizontal, Constants.UISubPadding )
            IconButton("chevron.right") { progressMonth() }
                .padding(.horizontal, Constants.UISubPadding )
            
            Spacer()
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            
            makeHeader()
            
            makeMonthSelector()
            
            Spacer()
        }
        
    }
}


#Preview {
    
    CalendarPageView()
    
}
