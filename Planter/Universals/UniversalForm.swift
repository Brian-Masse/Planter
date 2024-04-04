//
//  UniversalForm.swift
//  Recall
//
//  Created by Brian Masse on 7/19/23.
//

import Foundation
import SwiftUI
import PhotosUI
import UIUniversals

#Preview {
    TempView()
}

struct TempView: View {
    
    @State var text: String = ""
    @State var wateringAmount: Int = 3
    @State var wateringInterval: Int = 5
    
    var body: some View {

        ScrollView {
            VStack {
                
                Spacer()
                
//                StyledPhotoPicker()
                
                StyledTextField($text,
                                prompt: "What is the name of this plant?",
                                question: "Consider giving it a descriptive name, especially if you have multiple of the same plants")
                
                StyledFormComponentTemplate(prompt: "How much water does this plant get",
                                            description: "when it gets watered should it just get a spray or be watered until it can't accept it") {
                    WaterSelector(wateringAmount: $wateringAmount)
                }
                
                StyledFormComponentTemplate(prompt: "How frequently should this plant be watered",
                                            description: "This wil schedule the plant watering at regular intervals") {
                    StyledTimeIntervalSelector(interval: $wateringInterval)
                }
                
                Spacer()
            }
        }
        .background(Colors.lightAccent)
        .tapHidesKeyboard()
    }
    
}

//MARK: StyledFormComponentTemplate

struct StyledFormComponentTemplate<C: View>: View {
    
    let form: C
    
    let prompt: String
    let description: String
    
    let fontSize: Double
    
    init( prompt: String, description: String, fontSize: Double = Constants.UISubHeaderTextSize, @ViewBuilder contentBuilder: () -> C ) {
        self.prompt = prompt
        self.description = description
        self.fontSize = fontSize
        self.form = contentBuilder()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText( prompt, size: fontSize, font: Constants.titleFont, case: .uppercase )
                .padding(.trailing, 50)
                
            form
                .padding(.bottom, Constants.UISubPadding)
                .padding(.top, -Constants.UISubPadding)
            
            UniversalText( description, size: Constants.UISmallTextSize, font: Constants.mainFont )
                .opacity(Constants.formDescriptionTextOpacity)
                .padding(.trailing, 50)
        }
        .padding()
        .rectangularBackground(0, style: .primary)
    }
    
}


//MARK: StyledTextField
struct StyledTextField: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let binding: Binding<String>
    let prompt: String
    let question: String
    
    let fontSize: CGFloat
    let uppercase: Bool
    
    let clearable: Bool
    let privateField: Bool
    
    init( _ binding: Binding<String>, prompt: String, question: String = "", fontSize: CGFloat = Constants.UISubHeaderTextSize, upperCase: Bool = false, privateField: Bool = false) {
        
        self.binding = binding
        self.prompt = prompt
        self.question = question
        
        self.fontSize = fontSize
        self.uppercase = upperCase
        
        self.clearable = false
        self.privateField = privateField
    }
    
    @FocusState var focused: Bool
    @State var highlighted: Bool = false
    
    @State var showingClearButton: Bool = false
    @State private var textIsEmpty: Bool = true
    
    private var textBinding: Binding<String> {
        Binding {
            self.uppercase ? binding.wrappedValue.uppercased() : binding.wrappedValue
        } set: { value in binding.wrappedValue = value }
    }
    
    @ViewBuilder
    private func makeTextField() -> some View {
        ZStack(alignment: .bottomLeading ) {
            if textIsEmpty {
                UniversalText( prompt, size: fontSize, font: Constants.titleFont, case: .uppercase, wrap: true )
                    .padding(.trailing, 50)
            }
            
            if privateField {
                SecureField("", text: textBinding)
            } else {
                TextField("", text: textBinding, axis: .vertical)
                    .font(Font.custom(SpaceGroteskMedium.shared.postScriptName, size: fontSize))
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            makeTextField()
            .font(.custom(Constants.mainFont.postScriptName, size: fontSize))
                .focused($focused)
                .lineLimit(10)
                .padding( .trailing, 5 )
                .universalTextField()
                .onChange(of: self.focused) { oldValue, newValue in
                    withAnimation {
                        self.showingClearButton = newValue
                        
                        self.highlighted = newValue
                    }
                }
                .onChange(of: textBinding.wrappedValue) { oldValue, newValue in withAnimation {
                    textIsEmpty = newValue.isEmpty
                } }
                .padding(.bottom, Constants.UISubPadding)
                .foregroundStyle(showingClearButton ? Colors.getAccent(from: colorScheme) : Colors.getBase(from: colorScheme, reversed: true))
            
            Divider(strokeWidth: 3)
                .padding(.bottom, Constants.UISubPadding)
                .foregroundStyle(showingClearButton ? Colors.getAccent(from: colorScheme) : Colors.getBase(from: colorScheme, reversed: true))
            
            if !textIsEmpty {
                UniversalText( prompt, size: Constants.UIDefaultTextSize, font: Constants.titleFont, case: .uppercase, wrap: true )
            }
            
            if !question.isEmpty {
                UniversalText(question, size: Constants.UISmallTextSize, font: Constants.mainFont)
                    .padding(.trailing, 30)
                    .opacity(Constants.formDescriptionTextOpacity)
            }
        }
        .padding()
        .padding(.trailing)
        .rectangularBackground(0, style: .primary)
    }
}

//MARK: Water Selector
struct WaterSelector: View {

    @Binding var wateringAmount: Int
    
    var slideGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                wateringAmount = Int( (value.location.x - 20) / 52 )
            }
    }
    
    @ViewBuilder
    private func makeSelectorNode(amount: Int, filled: Bool = false) -> some View {
        ResizableIcon(filled ? "drop.fill" : "drop", size: Constants.UISubHeaderTextSize)
            .padding(.horizontal)
            .onTapGesture { withAnimation { wateringAmount = amount } }
    }
    
    var body: some View {
        HStack {
            ForEach( 1...5, id: \.self ) { i in
                ZStack {
                    if i <= wateringAmount {
                        makeSelectorNode(amount: i, filled: true)
                    }
                    makeSelectorNode( amount: i )
                }
            }
            Spacer()
        }.gesture(slideGesture)
    }
}

//MARK: StyledTimeIntervalSelector
struct StyledTimeIntervalSelector: View {
    
    @Environment( \.colorScheme ) var colorScheme
    
    @Binding var interval: Int
    let unit: String
    
    init( interval: Binding<Int>, unit: String = "days" ) {
        self._interval = interval
        self.unit = unit
    }
    
    var floatBinding: Binding<Float> {
        Binding { Float(interval) } set: { newValue in
            interval = Int(newValue)
        }
    }
    
    var stringBinding: Binding<String> {
        Binding { "\(interval)"} set: { newValue in
            interval = Int( newValue ) ?? 0
        }
    }
    
    var body: some View {
        HStack {
            Slider(value: floatBinding, in: 1...14)
                .tint(Colors.getBase(from: colorScheme, reversed: true))
            
            HStack {
                TextField("", text: stringBinding)
                    .frame(width: CGFloat("\(interval)".count) * 10)
                    .keyboardType(.numberPad)
                    .tint(Colors.getAccent(from: colorScheme))
                
                if !unit.isEmpty {
                    UniversalText( unit, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
                }
            }.rectangularBackground(style: .secondary)
        }
    }   
}

//MARK: Styled Photo Picker
struct StyledPhotoPicker: View {
    
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    let shouldCrop: Bool
    
    init(_ image: Binding<Image?>, shouldCrop: Bool = true) {
        self._croppedImage = image
        self.shouldCrop = shouldCrop
    }
    
    @State private var showPhotoPicker: Bool = false
    @State private var showCropView: Bool = false
    
    @Binding var croppedImage: Image?
    
    @ViewBuilder
    private func makeFullImageUploader() -> some View {
        HStack {
            Spacer()
            
            VStack {
                UniversalText("Upload Image", size: Constants.UIDefaultTextSize, font: Constants.mainFont, case: .uppercase)
                
                ResizableIcon("cable.connector", size: Constants.UISubHeaderTextSize)
            }
            Spacer()
        }
        .rectangularBackground(style: .secondary)
        .onTapGesture { showPhotoPicker = true }
    }
    
    @ViewBuilder
    private func makeSmallImageUploader() -> some View {
        HStack {
            UniversalText("Change Image", size: Constants.UIDefaultTextSize, font: Constants.mainFont, case: .uppercase)
                .onTapGesture { showPhotoPicker = true }
            
            Spacer()
            
            if shouldCrop {
                UniversalText("Crop Image", size: Constants.UIDefaultTextSize, font: Constants.mainFont, case: .uppercase)
                    .onTapGesture { showCropView = true }
            }
        }
        .opacity(0.9)
        .padding(.horizontal)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Constants.UISubPadding) {
            
            UniversalText( "Select Image", size: Constants.UISubHeaderTextSize, font: Constants.titleFont, case: .uppercase )
            
            if let image = croppedImage {
                HStack {
                    Spacer()
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(Constants.UIDefaultCornerRadius)
                        .frame(height: 120)
                    Spacer()
                }.rectangularBackground(Constants.UISubPadding, style: .secondary)
            }
            
            if croppedImage == nil {
                makeFullImageUploader()
            } else {
                makeSmallImageUploader()
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoManager.imageSelection)
        .onChange(of: photoManager.retrievedImage) { oldValue, newValue in
            if newValue != nil {
                if shouldCrop { showCropView = true }
                else { self.croppedImage = photoManager.image! }
            }
        }
        .fullScreenCover(isPresented: $showCropView) {
            CropView(image: photoManager.image!) { image in
                self.croppedImage = Image(uiImage: image)
            }
        }
        .rectangularBackground(style: .primary)
    }
}

//MARK: CropView
@MainActor
fileprivate struct CropView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let image: Image
    
    let onCrop: ( UIImage ) -> Void
    
    init( image: Image, onCrop: @escaping ( UIImage ) -> Void = { _ in } ) {
        self.image = image
        self.onCrop = onCrop
    }
    
    @State private var moving: Bool = false
    @State private var offset: CGSize = .zero
    @State private var priorOffset: CGSize = .zero
    
    @State private var scale: CGFloat = 1
    @State private var priorScale: CGFloat = 0
    
    @State private var showingGrid: Bool = true
    
    private func saveImage(geo: GeometryProxy) {
        
        let renderer = ImageRenderer(content: makeImage(showGrid: false, geo: geo) )
        renderer.proposedSize = ProposedViewSize(CGSize( width: geo.size.width * 4, height: geo.size.width * 4 ))
        
        let image = renderer.uiImage!
        
        self.onCrop( image )
        
        dismiss()
    }
    
    private func moveGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                self.moving = true
                self.offset = CGSize(width: value.translation.width + self.priorOffset.width,
                                     height: value.translation.height + self.priorOffset.height)
            }
            .onEnded { value in self.moving = false }
    }
    
    private var resizeGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.scale = max(1, value + priorScale)
                self.moving = true
            }
            .onEnded { value in
                self.priorScale = self.scale - 1
                self.moving = false
            }
    }
    
//    Geo represents the size of the croppedSpace
//    imageRect represents the size of the image
    private func constrainOffset(geo: GeometryProxy, imageRect: CGSize) -> CGSize {

//        geo.size.height is the height of this entire screen, however because it is being cropped to a square we can use geo.size.width to represnt both
//        the width and the height
        
//        this is the amount of the image that hangs over the croppedSpace, on one side
        let baseHorizontalOverflow = (imageRect.width * scale - geo.size.width) / 2
        let baseVerticalOverflow = (imageRect.height * scale - geo.size.width) / 2
        
        let xMin =  min( offset.width, baseHorizontalOverflow)
        let x =     max( xMin, -baseHorizontalOverflow )

        let yMin =  min( offset.height, baseVerticalOverflow )
        let y =     max( yMin, -baseVerticalOverflow )
        
        return CGSize( width: x, height: y )
        
    }
    
    @ViewBuilder
    private func makeHeader(geo: GeometryProxy) -> some View {
        HStack {
            ResizableIcon("xmark", size: Constants.UIDefaultTextSize)
                .onTapGesture { dismiss() }
            Spacer()
            UniversalText("Crop", size: Constants.UISubHeaderTextSize, font: Constants.mainFont, case: .uppercase)
            Spacer()

            ResizableIcon("checkmark", size: Constants.UIDefaultTextSize)
                .onTapGesture { self.saveImage(geo: geo) }
        }
    }
    
    @ViewBuilder
    private func makeGrid(geo: GeometryProxy) -> some View {
        let cellCount = 5
        let space = geo.size.width / CGFloat(cellCount)
        
        ZStack(alignment: .topLeading) {
            ForEach(1...cellCount, id: \.self) { i in
                Divider(vertical: true, strokeWidth: 1)
                    .offset(x: CGFloat(i) * space)
            }
            ForEach(1...cellCount, id: \.self) { i in
                Divider(strokeWidth: 1)
                    .offset(y: CGFloat(i) * space)
            }
        }
    }
    
    @ViewBuilder
    private func makeImage(showGrid: Bool, geo: GeometryProxy) -> some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay { GeometryReader { imageGeo in
                    Color.clear
                        .onChange(of: moving) { oldValue, newValue in
                            if !newValue { withAnimation {
                                
                                self.offset = constrainOffset(geo: geo, imageRect: imageGeo.size )
                                
                                
                                self.priorOffset = self.offset
                            }}
                        }
                }}
                .scaleEffect(self.scale)
                .offset(self.offset)
                .frame(width: geo.size.width, height: geo.size.width)
            
            makeGrid(geo: geo)
                .opacity(showGrid ? 0.3 : 0)
                .frame(width: geo.size.width, height: geo.size.width)
        }
        .background(.black.opacity(0.2))
        .gesture(moveGesture(geo: geo))
        .gesture(resizeGesture)
        .clipShape(Circle())
    }
    
    @ViewBuilder
    private func makeControlButton<C: View>(title: String, @ViewBuilder contentBuilder: () -> C) -> some View {
        VStack {
            UniversalText( title, size: Constants.UIDefaultTextSize, font: Constants.mainFont )
            
            contentBuilder()
        }
        .frame(width: 120)
        .rectangularBackground(style: .primary)
    }
    
    @ViewBuilder
    private func makeControlButtons() -> some View {
        HStack {
            Spacer()
            makeControlButton(title: "Reset Edits") {
                ResizableIcon("eraser", size: Constants.UISubHeaderTextSize)
                    .onTapGesture { withAnimation {
                        self.scale = 1
                        self.offset = .zero
                    } }
            }
        
            makeControlButton(title: "Show Grid") {
                Toggle("", isOn: $showingGrid)
                    .tint(Colors.getAccent(from: colorScheme))
                    .labelsHidden()
            }
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                makeHeader(geo: geo)
                    .zIndex(100)

                Spacer()
                
                makeImage(showGrid: showingGrid, geo: geo)
                    .shadow(radius: 30)
                    .zIndex(1)
                
                Spacer()
                
                makeControlButtons()
                
                Spacer()
            }
        }
        .padding()
        .background(.black.opacity(0.3))
        .universalImageBackground(image)
    }
}
