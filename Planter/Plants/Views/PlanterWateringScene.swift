//
//  PlanterWateringScene.swift
//  Planter
//
//  Created by Brian Masse on 12/8/23.
//

import Foundation
import SwiftUI
import UIUniversals

struct PlantWateringScene: View {
    
    
//    MARK: vars
    enum PlantWateringSceneEnum: Int, PlanterSceneEnum {
        func getTitle() -> String {
            return "updates"
        }
        
        var id: Int { self.rawValue }
        
        case updates
        
    }
    
    let plant: PlanterPlant
    
    @State var activeScene: PlantWateringSceneEnum = .updates
    @State var sceneComplete: Bool = true
    
    @State var showComments: Bool = false
    @State var showImage: Bool = false
    @State var showDate: Bool = false
    
    @State var date: Date = .now
    @State var comments: String = ""
    @State var image: UIImage? = nil
    
//    MARK: ViewBuilder
    
    @ViewBuilder
    private func makeSection<C: View>(_ showing: Binding<Bool>, title: String, unToggleTitle: String, content: @escaping () -> C ) -> some View {
        
        VStack(alignment: .leading) {
            if !showing.wrappedValue {
                HStack {
                    ResizableIcon( "plus", size: Constants.UIDefaultTextSize )
                    UniversalText(title, size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase, wrap: false, scale: true)
                    Spacer()
                }
                .onTapGesture { withAnimation { showing.wrappedValue = true }}
            }
            
            if showing.wrappedValue {
                content()
                
                HStack {
                    ResizableIcon("xmark", size: Constants.UISmallTextSize)
                    
                    UniversalText( unToggleTitle, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                }
                .padding(.leading)
                .opacity(0.7)
                .onTapGesture { withAnimation { showing.wrappedValue = false } }
            }
        }
    }
    
    @ViewBuilder
    private func makeUpdatesScene() -> some View {
        
        VStack(alignment: .leading) {
            makeWateringNotice()
            
            makeSection($showComments, title: "Add any additional notes", unToggleTitle: "Remove additional note") {
                StyledTextField($comments,
                                prompt: "Provide any additional notes",
                                question: "ie. The plant is getting much greener \nie. Moved the plant to a spot with better sunlight")
            }
            
            makeSection($showImage, title: "Add a photo", unToggleTitle: "Remove photo") {
                StyledPhotoPicker($image, description: "provide an image to show how the plants doing")
            }
        }
        .padding(Constants.UISubPadding)
    }
    
    @ViewBuilder
    private func makeWateringNotice() -> some View {
        if !plant.getNextWateringDate().matches(Date.now, to: .day) {
            
            let message = "This plant is scheduled to be watered on \( plant.getNextWateringDate().formatted(date: .abbreviated, time: .omitted))"
            
            VStack(alignment: .leading) {
                UniversalText("This plant does not need to be watered today!", size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase)
                    .padding(.bottom, Constants.UISubPadding)
                
                UniversalText( message, size: Constants.UISmallTextSize, font: Constants.mainFont  )
                    .padding(.leading, Constants.UISubPadding)
            }
            .foregroundStyle(.black)
            .rectangularBackground(style: .accent)
        }
    }
    
//    MARK: Struct Methods
    @MainActor
    private func submit() {
        plant.water(date: date, comments: comments)
    }
    
//    MARK: ViewBuilder
    var body: some View {
        PlanterScene($activeScene,
                     sceneComplete: $sceneComplete,
                     canRegressScene: true,
                     submit: submit) { _ in
            makeUpdatesScene()
        }
    }
}


#Preview {
    
    let plant = PlanterPlant(ownerID: "100",
                             name: "Fern",
                             roomName: "bedroom",
                             notes: "This is the second plant I got. Initially it was wilting before it dropped a seed and gave birth to the largest and healthies plant I have",
                             wateringInstructions: "always spray after watering",
                             wateringAmount: 4,
                             wateringInterval: 7,
                             statusImageFrequency: 4,
                             statusNotesFrequency: 10,
                             coverImageData: Data())
    
    return PlantWateringScene(plant: plant)
}
