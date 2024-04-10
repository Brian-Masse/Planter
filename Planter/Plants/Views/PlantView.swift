//
//  PlanterView.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI
import UIUniversals

struct PlantView: View {
    
//    MARK: Vars
    @Environment( \.colorScheme ) var colorScheme
    @Environment( \.presentationMode ) var presentationMode
    
    @State var showingPlantwateringScene = false
    
    let plant: PlanterPlant
    let image: Image
    
    init( plant: PlanterPlant ) {
        self.plant = plant
        self.image = plant.getImage()
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader() -> some View {
        
        HStack() {
            if plant.isFavorite {
                ResizableIcon("staroflife.fill", size: Constants.UIHeaderTextSize)
            }
            UniversalText(plant.name, size: Constants.UIMainHeaderTextSize, font: Constants.titleFont, case: .uppercase)
            
            Spacer()
            
            DismissButton()
        }
    }
    
    @ViewBuilder
    private func makeOverview() -> some View {
        VStack(alignment: .leading) {
            UniversalText(plant.notes, size: Constants.UISmallTextSize, font: Constants.mainFont)
            
            UniversalText( "\(plant.roomName) plant", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
        }
    }
    
//    MARK: Watering Instructions
    @ViewBuilder
    private func makeWateringAmountVisual() -> some View {
        HStack {
            ForEach( 1...5, id: \.self ) { i in
                ResizableIcon( i <= plant.wateringAmount ? "drop.fill" : "drop", size: Constants.UISubHeaderTextSize - 5)
            }
        }
    }
    
    @ViewBuilder
    private func makeWateringInstructions() -> some View {
        
        VStack(alignment: .leading, spacing: Constants.UISubPadding) {
            
            UniversalText("Instructions", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase)
                .padding(.trailing)
            
            UniversalText( plant.getWaterIntervalMessage(), size: Constants.UIDefaultTextSize, font: Constants.mainFont, case: .uppercase)
                .padding(.trailing)
                .padding(.top, -Constants.UISubPadding)
            
            HStack {
                Spacer()
                
                UniversalText( plant.wateringInstructions, size: Constants.UISmallTextSize, font: Constants.mainFont, textAlignment: .trailing )
                    .padding(.bottom, Constants.UISubPadding)
            }
            
            plant.getImage()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .padding(.horizontal)
                .padding(.bottom, Constants.UISubPadding)
            
                UniversalText( "Watering Amount", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase  )
                
                makeWateringAmountVisual()
                    .padding(.leading)
        }
        .padding(.bottom)
        .foregroundStyle(.black)
        .rectangularBackground(style: .primary, reverseStyle: true)
    }
    
//    MARK: ActionButtons
    
    @ViewBuilder
    private func makeInformatics() -> some View {
        HStack {
            PlantFavoriteToggle(plant: plant, alignment: .leading)
            
            Spacer()
            
            if plant.isPrimaryWaterer() {
                VStack(alignment: .leading, spacing: 0) {
                    ResizableIcon("drop.fill", size: Constants.UIDefaultTextSize)
                    UniversalText("primary\nwaterer",
                                  size: Constants.UISubHeaderTextSize,
                                  font: Constants.titleFont,
                                  case: .uppercase,
                                  lineSpacing: -10)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func makeActionButton( title: String, isPrimary: Bool = true, action: @escaping () -> Void ) -> some View {

        UniversalButton {
            HStack {
                Spacer()
                UniversalText( title,
                               size: Constants.UISubHeaderTextSize,
                               font: Constants.titleFont,
                               case: .uppercase,
                               wrap: false)
                Spacer()
            }
            .if(isPrimary) { view in view.foregroundStyle( .black) }
            .rectangularBackground( style: isPrimary ? .accent : .primary, cornerRadius: Constants.UILargeCornerRadius )
            .shadow(color: Colors.getAccent(from: colorScheme).opacity( isPrimary ? 0.3 : 0 ), radius: 15, x: 0, y: 0)
        } action: { action() }
    }
    
    @ViewBuilder
    private func makeActionButtons() -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                makeActionButton(title: "Water", isPrimary: plant.wateringToday()) { showingPlantwateringScene = true }
                makeActionButton(title: "Postpone", isPrimary: false) {}
            }
            HStack(spacing: 0) {
                makeActionButton(title: "share") {}
                makeActionButton(title: "edit") {}
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeHeader()
                .padding(.horizontal, Constants.UISubPadding)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    makeOverview()
                        .padding(.bottom)
                        .padding(.horizontal, Constants.UISubPadding)
                    
                    makeWateringInstructions()
                        .padding(.bottom)
                        .padding(.horizontal, Constants.UISubPadding)
                    
                    makeInformatics()
                        .padding(.bottom)
                        .padding(.horizontal, Constants.UISubPadding)
                    
                    makeActionButtons()
                    
                    Spacer()
                }
            }
        }
        .universalImageBackground(self.image)
        .fullScreenCover(isPresented: $showingPlantwateringScene) {
            PlantWateringScene(plant: plant)
        }
    }
}

struct TestView: View {
    
    @State var plant: PlanterPlant
    
    init() {
        self.plant = PlanterPlant(ownerID: "100",
                                 name: "Fern",
                                 roomName: "bedroom",
                                 notes: "This is the second plant I got. Initially it was wilting before it dropped a seed and gave birth to the largest and healthies plant I have",
                                 wateringInstructions: "always spray after watering",
                                 wateringAmount: 4,
                                 wateringInterval: 7 * Constants.DayTime,
                                 statusImageFrequency: 4,
                                 statusNotesFrequency: 10,
                                 coverImageData: Data())
    }
    
    var body: some View {
        PlantView(plant: plant)
        
    }
    
}

#Preview {
   TestView()
}
