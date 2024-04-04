//
//  PlantEditingView.swift
//  Planter
//
//  Created by Brian Masse on 12/22/23.
//

import Foundation
import SwiftUI
import UIUniversals

struct PlantEditingView: View {
    
//    MARK: Vars
    @Environment(\.presentationMode) var presentationMode
    
    let plant: PlanterPlant
    let image: Image
    
    @State var name: String = ""
    @State var notes: String = ""
    @State var instruction: String = ""
    
    init(plant: PlanterPlant) {
        self.plant = plant
        
        self.image = PhotoManager.decodeImage(from: plant.coverImage) ?? Image("fern")
        
        self.name = plant.name
        self.notes = plant.notes
        
    }
    
    
//    MARK: ViewBuilder
    @ViewBuilder
    private func makeHeader() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                UniversalText( "edit \nplant",
                               size: Constants.UITitleTextSize,
                               font: Constants.titleFont,
                               case: .uppercase,
                               scale: true,
                               lineSpacing: -40)
                
                Spacer()
                
                LargeTextButton("",
                                at: 0,
                                aspectRatio: 1,
                                verticalTextAlignment: .top,
                                arrowDirection: .down,
                                style: .secondary) {
                    
                    presentationMode.wrappedValue.dismiss()
                }
                                .padding()
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private func makeOverviewSection() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            UniversalText("Overview",
                          size: Constants.UIMainHeaderTextSize,
                          font: Constants.titleFont,
                          case: .uppercase)
            .opacity(0.75)
            
//            StyledFormSection("name & \nnotes") {
//                VStack(alignment: .leading) {
//                    
//                    StyledTextField($name, prompt: "name", question: "What do you call this plant",  fontSize: Constants.UISubHeaderTextSize)
//                        .padding(.bottom)
//                    
//                    Spacer()
//                    
//                    StyledTextField($notes, prompt: "notes", question: "Provide any additional notes on this plant", fontSize: Constants.UISubHeaderTextSize)
//                }
//                .padding(.vertical)
//            }
//            .padding(.bottom)
//            
//            StyledFormSection("Plant \nInfo") {
//                VStack(alignment: .leading) {
//                    
//                    StyledTextField($instruction, prompt: "instructions", question: "how should this plant be watered?", fontSize: Constants.UISubHeaderTextSize)
//                    
//                    Spacer()
//                    
//                    StyledTextField($instruction, prompt: "Watering Can", question: "What do you use to water this plant?", fontSize: Constants.UISubHeaderTextSize)
//                }
//            }
//            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func makePhotoPicker() -> some View {
        
//        Divider()
        
        HStack(alignment: .bottom) {
            VStack {
                HStack {
                    Spacer()
                }
                Spacer()
                UniversalText( "Upload",
                               size: Constants.UISubHeaderTextSize,
                               font: Constants.titleFont,
                               case: .uppercase)
                Spacer()
            }
            .foregroundStyle(.black)
            .rectangularBackground(style: .transparent)
            .padding()
            
            VerticalLayout {
                UniversalText("Choose a \nCover photo",
                              size: Constants.UIHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              lineSpacing: -10)
                .rotationEffect(.degrees(-90))
            }
        }
        .padding(.vertical)
        .rectangularBackground(style: .secondary)
    }
    
    
//    MARK: Body
    var body: some View {

        ZStack(alignment: .bottom) {
            VStack(alignment: .leading,spacing: 0) {
                
                makeHeader()
                    .padding(.bottom)
                
                ScrollView {
                    VStack(alignment: .leading,spacing: 0) {
                        
                        makeOverviewSection()
                            .padding(.bottom, 25)
                        
                        UniversalText("Scheduling",
                                      size: Constants.UIMainHeaderTextSize,
                                      font: Constants.titleFont,
                                      case: .uppercase)
                        .opacity(0.75)
                        
                        makePhotoPicker()
                        
                        Spacer()
                        
                    }
                }
            }
            
            LargeTextButton("do ne", at: 45, aspectRatio: 1.7, verticalTextAlignment: .bottom, arrowDirection: .up) {
            }
            .shadow(color: .black.opacity(0.3), radius: 10, y: 10)
            .offset(x: 20)
            .padding(.bottom)
        }
        .padding(7)
        .ignoresSafeArea(edges: .bottom)
        .universalImageBackground(self.image)
        
    }
    
}
