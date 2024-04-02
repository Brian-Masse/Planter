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
    
//    MARK: Vars
    enum PlantCreationScene: Int, CaseIterable, Identifiable {
        case basicInfo
        case waterScheduling
        case coverPhoto
        
        var id: Int {
            self.rawValue
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    @State var scene: PlantCreationScene = .basicInfo
    @State var sceneComplete: Bool = true
    
    @State var name: String = ""
    @State var notes: String = ""
    
    @State var wateringInterval: Double = Constants.DayTime * 7

    
//    MARK: Struct Methods
    private func submit() {
        let coverImageData = PlanterPlant.encodeImage( photoManager.retrievedImage )
        
        let plant = PlanterPlant(ownerID: PlanterModel.shared.ownerID,
                                 name: name,
                                 notes: notes,
                                 wateringInterval: wateringInterval,
                                 coverImageData: coverImageData)
        
        RealmManager.addObject(plant)
        
        presentationMode.wrappedValue.dismiss()
    }
    
//    MARK: ViewBuilders
    
    @ViewBuilder
    private func makeBasicInformationScene() -> some View {
        
        VStack(alignment: .leading) {
            
            StyledTextField($name, prompt: "name", question: "What do you call this plant?")
            StyledTextField($notes, prompt: "notes", question: "add any additional notes on this plant")
        }
        .onChange(of: name) { oldValue, newValue in
            sceneComplete = !(newValue.isEmpty || notes.isEmpty)
        }
        .onChange(of: notes) { oldValue, newValue in
            sceneComplete = !(newValue.isEmpty || name.isEmpty)
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
            
            StyledPhotoPicker {
                UniversalText("Choose Image", size: Constants.UIDefaultTextSize, font: Constants.titleFont)
            }
                
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
                case .basicInfo: makeBasicInformationScene()
                case .waterScheduling: makeWateringScheduleScene()
                case .coverPhoto: makePhotoPickerScene()
                }
            }
        }
    }
    
}
