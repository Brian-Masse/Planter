//
//  PlantCreationScene.swift
//  Planter
//
//  Created by Brian Masse on 11/29/23.
//

import Foundation
import SwiftUI
import PhotosUI
import UIUniversals

#Preview {
    PlantCreationScene()
}

struct PlantCreationScene: View {
//    MARK: Scenes
    enum PlantCreationScenes: Int, PlanterSceneEnum {
        func getTitle() -> String {
            switch self {
            case .overview:         return "Overview"
            case .scheduling:       return "Schedule"
            case .wateringNotes:    return "Watering Notes"
            case .sharing:          return "Sharing"
            }
        }
        
        case overview
        case scheduling
        case wateringNotes
        case sharing
        
        var id: Int {
            self.rawValue
        }
    }
    
    //    MARK: Vars
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    @State var scene: PlantCreationScenes = .overview
    @State var sceneComplete: Bool = true
    
    @State var name: String = ""
    @State var room: String = ""
    @State var description: String = ""
    
    @State var image: Image? = nil
    
    @State var wateringInterval: Double = Constants.DayTime * 7

//    MARK: Constants
    struct LocalConstants {
//        static let
        
    }
    
//    MARK: Struct Methods
    private func submit() {
        let coverImageData = PlanterPlant.encodeImage( photoManager.retrievedImage )
        
        let plant = PlanterPlant(ownerID: PlanterModel.shared.ownerID,
                                 name: name,
                                 notes: description,
                                 wateringInterval: wateringInterval,
                                 coverImageData: coverImageData)
        
        RealmManager.addObject(plant)
        
        presentationMode.wrappedValue.dismiss()
    }
    
//    MARK: ViewBuilders
    
    @ViewBuilder
    private func makeOverviewScene() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                StyledTextField($name,
                                prompt: "What is the name of this plant?",
                                question: "Consider giving it a descriptive name, especially if you have multiple of the same plants")
                
                StyledTextField($room,
                                prompt: "Where is this plant?",
                                question: "Consider the room its in, which self it is on, or what plant its in")
                
                StyledTextField($description, prompt: "provide any additional notes", question: "Provide any other relevant details, such as proximity to sunlight or soil quality")
            }
        }
        .onChange(of: name) { oldValue, newValue in
            sceneComplete = !(newValue.isEmpty)
        }
    }
    
    private var wateringIntervalBinding: Binding<Float> {
        Binding { Float( wateringInterval / Constants.DayTime )
            
        } set: { newValue in
            wateringInterval = Double( newValue.rounded(.down) ) * Constants.DayTime
        }
    }
    
    private var wateringIntervalLabelBinding: Binding<String> {
        Binding { "\(wateringInterval / Constants.DayTime) days"
        } set: { _ in }

    }
    
    @ViewBuilder
    private func makeWateringScheduleScene() -> some View {
        
        VStack(alignment: .leading) {
            
//            SliderWithPrompt(label: "How often would you like to water this plant",
//                             minValue: 1,
//                             maxValue: 31,
//                             binding: wateringIntervalBinding,
//                             strBinding: wateringIntervalLabelBinding,
//                             textFieldWidth: 120)
            
        }
        .onAppear { sceneComplete = true }
        
    }
    
    @ViewBuilder
    private func makePhotoPickerScene() -> some View {
        
        VStack(alignment: .leading) {
            
//            StyledPhotoPicker {
//                UniversalText("Choose Image", size: Constants.UIDefaultTextSize, font: Constants.titleFont)
//            }
                
        }
    }
    
    
    
//    MARK: Body
    var body: some View {
        PlanterScene($scene,
                     sceneComplete: $sceneComplete,
                     canRegressScene: true,
                     submit: submit) { scene in
            VStack {
                switch scene {
                case .overview: makeOverviewScene()
                case .scheduling: makeWateringScheduleScene()
                default: Text("hello")
//                case .coverPhoto: makePhotoPickerScene()
                }
            }
        }
    }
    
}
