//
//  PlantEditingView.swift
//  Planter
//
//  Created by Brian Masse on 12/22/23.
//

import Foundation
import SwiftUI


struct PlantEditingView: View {
    
//    MARK: Vars
    @Environment(\.presentationMode) var presentationMode
    
    let plant: PlanterPlant
    let image: Image
    
    @State var name: String = ""
    @State var notes: String = ""
    
    init(plant: PlanterPlant) {
        self.plant = plant
        
        self.image = PhotoManager.decodeImage(from: plant.coverImage) ?? Image("fern")
        
        self.name = plant.name
        self.notes = plant.notes
        
    }
    
    
//    MARK: ViewBuilder
    @ViewBuilder
    private func makeHeader() -> some View {
        
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
                            style: Colors.secondaryLight) {
                
                presentationMode.wrappedValue.dismiss()
            }
                            .padding()
        }
        
        Divider()
    }
    
    @ViewBuilder
    private func makeOverviewSection() -> some View {
        
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                
                TextFieldWithPrompt(title: "Name", binding: $name)
                    .padding(.bottom)
                
                TextFieldWithPrompt(title: "Notes", binding: $name)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            VerticalLayout {
                UniversalText("name & \nnotes",
                              size: Constants.UIHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              lineSpacing: -10 )
                
                    .rotationEffect(.degrees(-90))
            }
        }
        .secondaryOpaqueRectangularBackground()
        .padding(.vertical)

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
            .transparentRectangularBackgorund()
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
        .secondaryOpaqueRectangularBackground()
    }
    
    
//    MARK: Body
    var body: some View {

        ZStack(alignment: .bottom) {
            VStack(alignment: .leading,spacing: 0) {
                
                makeHeader()
                
                ScrollView {
                    VStack(alignment: .leading,spacing: 0) {
                        
                        makeOverviewSection()
                        
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



#Preview {
    
    let plant = PlanterPlant(ownerID: "",
                             name: "Cactus",
                             notes: "These are some great plant notes",
                             wateringInterval: 8,
                             coverImageData: Data())
    
    return PlantEditingView(plant: plant)
    
    
}
