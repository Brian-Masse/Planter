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

struct PlantCreationScene: View {
//    MARK: Scenes
    enum PlantCreationScenes: Int, PlanterSceneEnum {
        func getTitle() -> String {
            switch self {
            case .overview:         return "Overview"
            case .scheduling:       return "Watering"
            case .wateringNotes:    return "Recording"
            case .photo:            return "Cover Photo"
//            case .sharing:          return "Sharing"
            }
        }
        
        case overview
        case scheduling
        case wateringNotes
//        case sharing
        case photo
        
        var id: Int {
            self.rawValue
        }
    }
    
    //    MARK: Vars
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    @State var scene: PlantCreationScenes = .overview
    @State var sceneComplete: Bool = false
    
    @State var name: String = ""
    @State var room: String = ""
    @State var description: String = ""

    @State var wateringInterval: Int = 7
    @State var wateringAmount: Int = 3
    @State var wateringInstructions: String = ""

    @State var statusImageFrequency: Int = 3
    @State var statusNotesFrequency: Int = 10
    
    @State var image: UIImage?

    init( image: UIImage? = nil ) {
        self.image = image
    }
    
//    MARK: Constants
    struct LocalConstants {
//        static let
        
    }
    
//    MARK: Struct Methods
    private func submit() {
        let coverImageData = PlanterPlant.encodeImage( image )
        
        print(coverImageData)
        print(image == nil)
        
        let plant = PlanterPlant(ownerID: PlanterModel.shared.ownerID,
                                 name: name,
                                 roomName: room,
                                 notes: description,
                                 wateringInstructions: wateringInstructions,
                                 wateringAmount: wateringAmount,
                                 wateringInterval: Double(wateringInterval) * Constants.DayTime,
                                 statusImageFrequency: statusImageFrequency,
                                 statusNotesFrequency: wateringInterval,
                                 coverImageData: coverImageData)

        RealmManager.addObject(plant)
        
        presentationMode.wrappedValue.dismiss()
    }
    
//    MARK: Overview
    private func checkOverviewSceneCompletion() {
        sceneComplete = !name.isEmpty && !room.isEmpty
    }
    
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
            .padding(.bottom, Constants.UIBottomOfPagePadding )
        }
        .onChange(of: name) { checkOverviewSceneCompletion() }
        .onChange(of: room) { checkOverviewSceneCompletion() }
        
        .onChange(of: name) { oldValue, newValue in
            sceneComplete = false
        }
    }
    
//    MARK: Schedule
    @ViewBuilder
    private func makeWateringScheduleScene() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                StyledFormComponentTemplate(prompt: "How Frequently Should this plant be watered?",
                                            description: "This will automatically schedule the plant to be watered at the interval you select") {
                    StyledTimeIntervalSelector(interval: $wateringInterval)
                }
                
                StyledFormComponentTemplate(prompt: "How much water should this plant get?",
                                            description: "") {
                    WaterSelector(wateringAmount: $wateringAmount)
                }
                
                StyledTextField($wateringInstructions,
                                prompt: "Add additional instructions",
                                question: "are there any special requirements for watering this plant?" )
            }
            .padding(.bottom, Constants.UIBottomOfPagePadding )
        }.onAppear { sceneComplete = true }
    }
    
//    MARK: Recording
    @ViewBuilder
    private func makeRecordingScene() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                StyledFormComponentTemplate(prompt: "Status Picture Frequency",
                                            description: "How frequently would you like to provide a status picture when watering this plant") {
                    StyledTimeIntervalSelector(interval: $statusImageFrequency, maxInterval: 10, preText: "every", unit: "times")
                }
                
                StyledFormComponentTemplate(prompt: "Status notes Frequency",
                                            description: "How frequently would you like to provide a status update when watering this plant") {
                    StyledTimeIntervalSelector(interval: $statusNotesFrequency, maxInterval: 14, preText: "every", unit: "times")
                }
            }
        }
        .onAppear { sceneComplete = true }
    }
    
    @ViewBuilder
    private func makePhotoPickerScene() -> some View {
        StyledPhotoPicker($image, 
                          description: "choose a great photo to display for this plant",
                          maxPhotoWidth: .infinity,
                          shouldCrop: false)
        .onAppear { sceneComplete = true }
    }
    
    
    
//    MARK: Body
    var body: some View {
        PlanterScene($scene,
                     sceneComplete: $sceneComplete,
                     canRegressScene: true,
                     submit: submit) { scene in
            VStack {
                switch scene {
                case .overview:         makeOverviewScene()
                case .scheduling:       makeWateringScheduleScene()
                case .wateringNotes:    makeRecordingScene()
                case .photo:            makePhotoPickerScene()
                }
            }
        }
    }
    
}
