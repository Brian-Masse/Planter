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
    
    var body: some View {
    
        VStack {
            
            Spacer()
            
            StyledTextField($text,
                            prompt: "What is the name of this plant?",
                            question: "Consider giving it a descriptive name, especially if you have multiple of the same plants")
            
            Spacer()
        }
        .background(Colors.lightAccent)
        .tapHidesKeyboard()
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
    
    private var textBinding: Binding<String> {
        Binding {
            self.uppercase ? binding.wrappedValue.uppercased() : binding.wrappedValue
        } set: { value in binding.wrappedValue = value }
    }
    
    @ViewBuilder
    private func makeTextField() -> some View {
        ZStack(alignment: .bottomLeading ) {
            if textBinding.wrappedValue.isEmpty {
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
                .padding(.bottom, Constants.UISubPadding)
            
            Divider(strokeWidth: 3)
                .padding(.bottom, Constants.UISubPadding)
            
            if !question.isEmpty {
                UniversalText(question, size: Constants.UISmallTextSize, font: Constants.mainFont)
                    .padding(.trailing, 30)
                    .opacity(0.5)
            }
        }
        .foregroundStyle(showingClearButton ? Colors.getAccent(from: colorScheme) : Colors.getBase(from: colorScheme, reversed: true))
        .padding()
        .padding(.trailing)
        .rectangularBackground(0, style: .primary)
    }
}



//MARK: Time Selector

//MARK: StyledToggle
struct StyledToggle<C: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: C
    let wide: Bool
    let binding: Binding<Bool>
    
    init( _ binding: Binding<Bool>, wide: Bool = true, titleBuilder: () -> C ) {
        self.binding = binding
        self.title = titleBuilder()
        self.wide = wide
    }
    
    var body: some View {
        
        HStack {
     
            title
            
            if wide { Spacer() }
            
            Toggle("", isOn: binding)
                .tint(Colors.getAccent(from: colorScheme))
        }
    }
}

//MARK: StyledDatePicker

struct StyledDatePicker: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var date: Date
    let title: String
    let fontSize: CGFloat
    
    init( _ date: Binding<Date>, title: String, fontSize: CGFloat = Constants.UIHeaderTextSize ) {
        self._date = date
        self.title = title
        self.fontSize = fontSize
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText( title, size: fontSize, font: Constants.titleFont )
            DatePicker(selection: $date, displayedComponents: .date) {
                UniversalText( "select", size: Constants.UIDefaultTextSize, font: Constants.titleFont )
            }
            .tint(Colors.getAccent(from: colorScheme))
            .rectangularBackground(style: .secondary)
        }
    }
    
    
}

//MARK: Styled Photo Picker

struct StyledPhotoPicker<C: View>: View {
    
    @ObservedObject var photoManager = PlanterModel.photoManager
    
    let content: C
    
    init( contentBuilder: () -> C ) {
        self.content = contentBuilder()
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if let _ = photoManager.retrievedImage {
                
                photoManager.image!
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(Constants.UIDefaultCornerRadius)
                
                
                
            } else {
                PhotosPicker(selection: $photoManager.imageSelection,
                             photoLibrary: .shared()) {
                    self.content
                }
            }
                
        }
        
    }
    
}

//MARK: StyledForm
struct StyledFormSection<C: View>: View {
    
    let name: String
    let content: C
    
    init( _ name: String, contentBuilder: () -> C ) {
        self.name = name
        self.content = contentBuilder()
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            
            content
                .padding(25)
            
            Spacer()
            
            VerticalLayout {
                UniversalText(name,
                              size: Constants.UIMainHeaderTextSize,
                              font: Constants.titleFont,
                              case: .uppercase,
                              lineSpacing: -25 )
                
                    .rotationEffect(.degrees(-90))
            }
            .opacity(0.75)
            .padding(.trailing, -20)
            .mask {
                Rectangle()
                    .cornerRadius(Constants.UIDefaultCornerRadius, corners: [.topRight, .bottomRight])
            }
        }
        .rectangularBackground(0, style: .secondary)
    }
    
}
