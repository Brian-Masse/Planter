//
//  PlanterView.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI

struct PlantView: View {
    
    enum PlantPageTab: String, Identifiable, CaseIterable {
        case overview
        case calendar
        case comments
        
        var id: String {
            self.rawValue
        }
    }
    
//    MARK: Vars
    @Environment( \.colorScheme ) var colorScheme
    @Environment( \.presentationMode ) var presentationMode
    @Environment( \.planterSheetDismiss ) var planterSheetDismiss
    
    let plant: PlanterPlant
    let image: Image
    
    init( plant: PlanterPlant ) {
        self.plant = plant
        
        self.image = self.plant.getCoverImage() ?? Image("fern")
    }
    
    @State var activePage: PlantPageTab = .overview

    @State var showingWateringView: Bool = false
    
    
//    MARK: ViewBuilders
    
    @ViewBuilder
    private func makeDivider(vertical: Bool = false) -> some View {
        
        Rectangle()
            .foregroundStyle(.black)
            .if(vertical) { view in view.frame(width: 1) }
            .if(!vertical) { view in view.frame(height: 1) }
        
    }
    
//    MARK: Header
    @ViewBuilder
    private func makeTabBarNode( tab: PlantPageTab ) -> some View {
        
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 5)
                .cornerRadius(10)
            
            UniversalText( tab.rawValue, 
                           size: Constants.UISubHeaderTextSize,
                           font: Constants.mainFont,
                           case: .uppercase,
                           wrap: false,
                           scale: true)
            .padding(.horizontal, 7)
        }
        .shadow(color: .black.opacity(0.7), radius: 20)
        .foregroundStyle( tab == activePage ? PlanterModel.shared.activeColor : Colors.secondaryLight  )
        .onTapGesture { withAnimation {
            activePage = tab
        } }
    }
    
    @ViewBuilder
    private func makeTabBar() -> some View {
        
        HStack {
            ForEach( PlantPageTab.allCases, id: \.self ) { content in
                makeTabBarNode(tab: content)
            }
        }
    }
    
    @ViewBuilder
    private func makeHeader(_ geo: GeometryProxy) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            makeTabBar()
            
            HStack(spacing: 0) {
                UniversalText(plant.name,
                              size: Constants.UILargeTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              wrap: false,
                              fixed: true,
                              scale: true)
                
                Spacer()
                
                LargeTextButton("", at: 0, aspectRatio: 1, verticalTextAlignment: .top, arrow: true, style: Colors.secondaryLight) {
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
            .padding(.vertical, -10)
            
            makeDivider()
            
            UniversalText( plant.notes, size: Constants.UISmallTextSize, font: Constants.mainFont )
                .padding(.vertical, 5)
            
            makeDivider()
        }
    }
    
//    MARK: MainBody
    @ViewBuilder
    private func makeMainBody(_ geo: GeometryProxy) -> some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                HStack {
                    UniversalText( "Master\nBedroom",
                                   size: Constants.UIHeaderTextSize,
                                   font: Constants.titleFont,
                                   case: .uppercase,
                                   lineSpacing: -22)
                    Spacer()
                }
                .padding(.bottom, -20)
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width - 30, height: 250)
                    .clipped()
                    .cornerRadius(Constants.UIDefaultCornerRadius)
                    .rotation3DEffect(
                        .degrees(8),
                        axis: (x: 1.0, y: -1.0, z: 0.0)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 15, x: 10, y: 15)
                    .padding([.bottom, .trailing])
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        UniversalText( "status:\nGood",
                                       size: Constants.UIHeaderTextSize,
                                       font: Constants.titleFont,
                                       case: .uppercase,
                                       textAlignment: .trailing,
                                       lineSpacing: -22)
                        
                        UniversalText( "View\n Latest\n Comments",
                                       size: Constants.UIDefaultTextSize,
                                       font: Constants.titleFont,
                                       case: .uppercase,
                                       textAlignment: .trailing,
                                       lineSpacing: -7)
                    }
                }
            }
            .overlay {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        LargeTextButton("water plant", at: 45, aspectRatio: 1.8, verticalTextAlignment: .top, arrowDirection: .down) {
                            showingWateringView = true
                        }
                        .padding()
                        .offset(y: -25)
                    }
                    Spacer()
                    HStack {
                        LargeTextButton( "Edit Plant", at: -55, aspectRatio: 2.3, verticalTextAlignment: .top, arrowDirection: .down ) {
                            print("hello")
                        }
                        .padding(.leading)
                        .offset(y: -5)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
//    MARK: CalendarPreview
    @ViewBuilder
    private func makeCalendarDate( _ date: Date ) -> some View {
        
        let month = date.formatted( .dateTime.month(.abbreviated) )
        let day = date.formatted( .dateTime.day(.twoDigits) )
        
        VStack {
            
            UniversalText( month,
                           size: Constants.UIHeaderTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           wrap: false,
                           scale: true )
            
            UniversalText( day,
                           size: Constants.UITitleTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           wrap: false,
                           scale: true )
            .offset(y: -10)
            
            Spacer()
        }
        
    }
    
    @ViewBuilder
    private func makeCalendarPreview() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            makeDivider()
            
            HStack(alignment: .bottom) {
                
                Spacer()
                VerticalLayout() {
                    UniversalText("Up\nNext",
                                  size: Constants.UIHeaderTextSize,
                                  font: Constants.titleFont,
                                  case: .uppercase,
                                  scale: true,
                                  lineSpacing: -20)
                    .rotationEffect(.degrees(-90))
                }
                
                makeDivider(vertical: true)
                
                makeCalendarDate( plant.getNextWateringDate() )
                
                makeDivider(vertical: true)
                
                makeCalendarDate( plant.getNextWateringDate(2) )
                
                makeDivider(vertical: true)
                
                UniversalText("Water\nevery\n8days",
                              size: Constants.UIHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              scale: true,
                              lineSpacing: -10)
                
                Spacer()
            }
            .padding(.vertical, 7)
            .background(
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(Colors.secondaryLight)
                    .opacity(0.8)
                    .cornerRadius(Constants.UIDefaultCornerRadius, corners: [.topLeft, .topRight])
                    .offset(y: 5)
            )
            
            .padding([.top, .horizontal], 7)
        }
        
    }
    
//    MARK: Background
    @ViewBuilder
    private func makeBackground() -> some View {
        
        ZStack {
            self.image
                .resizable()
                .scaledToFill()
                .blur(radius: 30)
//                .padding(-50)
                .clipped()
                .ignoresSafeArea()
            
            Colors.secondaryLight.opacity(0.55)
                .ignoresSafeArea()
        }
    }
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $activePage) {
                VStack(alignment: .leading, spacing: 0) {
                    makeHeader(geo)
                    
                    makeMainBody(geo)
                    
                    Spacer()
                    
                    makeCalendarPreview()
                        .frame(height: 120)
                }.tag( PlantPageTab.overview )
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    ForEach( plant.wateringHistory, id: \.self ) { node in
                        
                        Text(node.comments)
                        
                    }
                    
                    
                }.tag( PlantPageTab.comments )
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(7)
            .background { makeBackground() }
            .sheet(isPresented: $showingWateringView) {
                PlantWateringScene(plant: plant)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}


#Preview {
    let plant = PlanterPlant(ownerID: "100",
                             name: "Fern",
                             notes: "cool plant",
                             wateringInterval: 7,
                             coverImageData: Data())
    
    return PlantView(plant: plant)
}
