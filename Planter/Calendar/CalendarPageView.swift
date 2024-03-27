//
//  CalendarPageView.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import RealmSwift
import UIUniversals

@MainActor
struct CalendarPageView: View {

//    enum FilteredPlantKey: String, CaseIterable, Identifiable {
//        case overdue
//        case today
//        case next
//        
//        var id: String {
//            self.rawValue
//        }
//    }
//
////    MARK: Vars
//    @Namespace var calendarPageNameSpace
//    
//    static let upNextPlantCount: Int = 100
//    static let calendarPageHeaderID: String = "calendarPageHeaderID"
//    
//    @State var showingPlantCreationView: Bool = false
//    @State var scrollViewPosition: CGPoint = .zero
//    
//    @State var test: Bool = false
//    
//    let plants: [PlanterPlant]
//    
////    MARK: ViewBuilders
//    
//    
//    
////    MARK: Header
//    @ViewBuilder
//    private func makeHeader()  -> some View {
//        VStack(alignment: .leading, spacing: 0) {
//            
//            HStack {
//                UniversalText( "Planter.", size: Constants.UITitleTextSize, font: Constants.titleFont, case: .uppercase )
//                Spacer()
//            }
//            .padding(.bottom, -10)
//            
//            UniversalText( "\(PlanterModel.profile.fullName())'s plants", size: Constants.UIDefaultTextSize, font: Constants.mainFont )
//                .padding(.bottom, 7)
//        }
//    }
//    
//    
////    MARK: TodayView
//    @ViewBuilder
//    private func makeTodayView(from plants: [PlanterPlant]) -> some View {
//        ZStack {
//            if !plants.isEmpty {
//                Rectangle()
//                    .universalStyledBackgrond(.accent, onForeground: true)
//                    .cornerRadius(Constants.UILargeCornerRadius, corners: [.topLeft, .bottomRight])
//                    .ignoresSafeArea()
//                    .padding(-7)
//                
//                VStack(spacing: 0) {
//                    HStack(alignment: .top) {
//                        PlantPreviewView(plant: plants.first!, layout: .full)
//                        
//                        VerticalLayout() {
//                            UniversalText( "Today", 
//                                           size: Constants.UITitleTextSize,
//                                           font: Constants.titleFont,
//                                           case: .uppercase,
//                                           wrap: false)
//                        }
//                        .rotationEffect(.degrees(90))
//                        .padding(.horizontal, -10)
//                    }
//                    .padding(.bottom, 7)
//                    
//                    VStack {
//                        if plants.count > 1 {
//                            ForEach( 1..<plants.count, id: \.self ) { i in
//                                PlantPreviewView(plant: plants[ i ], layout: .full)
//                                
//                            }
//                        }
//                    }
//                }.padding(7)
//            }
//        }
//        .padding(.top)
//    }
//    
////    MARK: UpNextView
//    @ViewBuilder
//    private func makeUpNextView(from plants: [PlanterPlant]) -> some View {
//        VStack(alignment: .leading, spacing: 7 ) {
//            if !plants.isEmpty {
//                HStack(alignment: .top) {
//                    
//                    VerticalLayout() {
//                        UniversalText( "Up Next",
//                                       size: Constants.UITitleTextSize,
//                                       font: Constants.titleFont,
//                                       case: .uppercase,
//                                       wrap: false)
//                    }
//                    .rotationEffect(.degrees(-90))
//                    .padding(.horizontal, -10)
//                    
//                    VStack {
//                        ForEach( 0...1, id: \.self ) { i in
//                            if i < plants.count {
//                                PlantPreviewView(plant: plants[i], layout: .half)
//                            }
//                        }
//                    }
//                }
//                
//                if plants.count > 2 {
//                    ForEach( 2..<plants.count, id: \.self ) { i in
//                        PlantPreviewView(plant: plants[ i ], layout: .half )
//                    }
//                }
//            }
//        }
//    }
    
//    MARK: Body
    var body: some View {
        
        Text("Calendar Page View")
        
//        VStack(alignment: .leading) {
//            
////            let todayPlants = plants.filter { plant in
////                plant.getNextWateringDate().matches(.now, to: .day)
////            }
//            
//            let upNextPlants = plants.filter { plant in
//                let date = plant.getNextWateringDate()
//                return !date.matches(.now, to: .day) && date > .now
//            }
//    
//            makeHeader()
//                .padding(.horizontal, 7)
//            
//            
//            BlurScroll(10, scrollPositionBinding: $scrollViewPosition) {
//                VStack {
//            
//                    Divider()
//                    
//                    makeTodayView(from: plants)
//                        .padding(.horizontal, 7)
//                    
//                    VStack {
//                        makeUpNextView(from: upNextPlants)
//                        
//                        LargeRoundedButton("create plant", icon: "plus", wide: true) {
//                            showingPlantCreationView = true
//                        }
//                    }
//                    .padding(.horizontal, 7)
//                    .padding(.bottom, 50)
//                }
//            }
//        }
//        .sheet(isPresented: $showingPlantCreationView) { PlantCreationScene() }
    }
}
