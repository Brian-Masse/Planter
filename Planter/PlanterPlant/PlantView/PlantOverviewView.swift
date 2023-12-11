//
//  PlantOverviewView.swift
//  Planter
//
//  Created by Brian Masse on 12/9/23.
//

import Foundation
import SwiftUI

struct PlantOverviewView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let plant: PlanterPlant
    let geo: GeometryProxy
    let image: Image
    
    @State var showingWateringView: Bool = false
    
//    MARK: Header
    
    @ViewBuilder
    private func makeHeader(_ geo: GeometryProxy) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .bottom, spacing: 0) {
                UniversalText(plant.name,
                              size: Constants.UILargeTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              wrap: false,
                              scale: true)
                
                Spacer()
                
                LargeTextButton("", at: 0, aspectRatio: 1, verticalTextAlignment: .top, arrow: true, style: Colors.secondaryLight) {
                    presentationMode.wrappedValue.dismiss()
                }
                .scaleEffect(0.9)
                .padding([.vertical, .trailing], 7)
            }
            .frame(height: 100)
            
            Divider()
            
            UniversalText( plant.notes, size: Constants.UISmallTextSize, font: Constants.mainFont )
                .padding(.vertical, 5)
            
            Divider()
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
                
                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width - 50, height: 250)
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
            
            Divider()
            
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
                
                Divider(vertical: true)
                
                makeCalendarDate( plant.getNextWateringDate() )
                
                Divider(vertical: true)
                
                makeCalendarDate( plant.getNextWateringDate(2) )
                
                Divider(vertical: true)
                
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
    
//    MARK: body
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            makeHeader(geo)
            
            makeMainBody(geo)
//            
            Spacer()
//            
            makeCalendarPreview()
                .frame(height: 120)
            
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.horizontal, 7)
        .sheet(isPresented: $showingWateringView) {
            PlantWateringScene(plant: plant)
        }
    }
    
}
//
//#Preview {
//    let plant = PlanterPlant(ownerID: "100",
//                             name: "Cactus",
//                             notes: "cool plant",
//                             wateringInterval: 7,
//                             coverImageData: Data())
//    
//    return PlantView(plant: plant)
//}
