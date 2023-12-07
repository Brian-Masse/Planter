//
//  ViewModifiers.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import SwiftUI
import RealmSwift

//MARK: Backgrounds
private struct UniversalBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    let padding: Bool
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                content
                    .background(
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                content.hideKeyboard()
                            }
                    )
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(colorScheme == .light ? Colors.baseLight : Colors.baseDark)
        }
    
    }
}

private struct UniversalColoredBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let color: Color
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .universalBackground(padding: false)
                .ignoresSafeArea()
//                .background(
//                    GeometryReader { geo in
//                        VStack {
////                            if colorScheme == .dark {
//                            LinearGradient(colors: [color.opacity( colorScheme == .dark ? 0.1 : 0.25), .clear], startPoint: .top, endPoint: .bottom )
//                                    .frame(maxHeight: 800)
//                                Spacer()
////                            }
////                            else if colorScheme == .light {
////                                Spacer()
////                                LinearGradient(colors: [color.opacity(0.2), .clear], startPoint: .bottom, endPoint: .top )
////                                    .frame(maxHeight: 800)
////                            }
//                        }
//                    }
//                        .universalBackground(padding: false)
//                        .ignoresSafeArea()
//                )
        }
    }
}

//MARK: TextStyle
private struct UniversalTextStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .light ? .black : .white)
    }
}

private struct ReversedUniversalTextStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .light ? .white : .black)
    }
}

private struct UniversalTextField: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .tint(Colors.tint)
            .font(Font.custom(ProvidedFont.renoMono.rawValue, size: Constants.UIDefaultTextSize))
    }
}

//MARK: Rectangular Backgrounds
private struct TransparentRectangularBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let padding: CGFloat?
    let radius: CGFloat?
    
    private func getRadius() -> CGFloat {
        if let radius { return radius }
        return Constants.UIDefaultCornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .if(padding == nil) { view in view.padding() }
            .if(padding != nil) { view in view.padding(padding!) }
            .background(.ultraThinMaterial)
            .foregroundColor(  ( Colors.tint ).opacity(0.6))
            .cornerRadius( getRadius() )
    }
}

//This is black and white
private struct OpaqueRectangularBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let padding: CGFloat?
    let stroke: Bool
    let texture: Bool
    
    func body(content: Content) -> some View {
        content
            .if(padding == nil) { view in view.padding() }
            .if(padding != nil) { view in view.padding(padding!) }
            .background(
                VStack {
                    if texture {
                        Image("PaperNoise")
                            .resizable()
                            .blendMode( colorScheme == .light ? .multiply : .lighten)
                            .opacity( colorScheme == .light ? 0.55 : 0.20)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                }
            )
            .background(colorScheme == .light ? Colors.baseLight : Colors.baseDark )
            .if(stroke) { view in
                view
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UIDefaultCornerRadius)
                            .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1)
                    )
            }
            .cornerRadius(Constants.UIDefaultCornerRadius)
    }
}

//This is the white accent and dark accent
private struct SecondaryOpaqueRectangularBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let padding: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .if(padding == nil) { view in view.padding() }
            .if(padding != nil) { view in view.padding(padding!) }
            .background( colorScheme == .dark ? Colors.secondaryDark : Colors.secondaryLight )
            .cornerRadius(Constants.UIDefaultCornerRadius)
//            .shadow(color: Colors.tint.opacity( colorScheme == .dark ? 0.2 : 0.4), radius: 50)
    }
}

//This is the titn background
private struct TintBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var model = PlanterModel.shared
    
    let padding: CGFloat?
    let radius: CGFloat?
    
    private func getRadius() -> CGFloat {
        if let radius { return radius }
        return Constants.UIDefaultCornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .if(padding == nil) { view in view.padding() }
            .if(padding != nil) { view in view.padding(padding!) }
            .foregroundColor(.black)
            .universalBackgroundColor()
            .cornerRadius(getRadius())
    }
}

//This adds extra padding to the tint background
private struct AccentBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var model = PlanterModel.shared
    
    let cornerRadius: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .padding(25)
            .foregroundColor(.black)
            .background( model.activeColor )
            .cornerRadius( cornerRadius == nil ? Constants.UIDefaultCornerRadius : cornerRadius!)
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

private struct BlurScroll: ViewModifier {
    
    let blur: CGFloat
    let coordinateSpaceName = "scroll"
    
    @State private var scrollPosition: CGPoint = .zero
    
    func body(content: Content) -> some View {
        
        let gradient = LinearGradient(stops: [
            .init(color: .white, location: 0.10),
            .init(color: .clear, location: 0.25)],
                                      startPoint: .bottom,
                                      endPoint: .top)
        
        let invertedGradient = LinearGradient(stops: [
            .init(color: .clear, location: 0.10),
            .init(color: .white, location: 0.25)],
                                              startPoint: .bottom,
                                              endPoint: .top)
        
        GeometryReader { topGeo in
            ScrollView {
                ZStack(alignment: .top) {
                    content
                        .mask(
                            VStack {
                                invertedGradient
                                
                                    .frame(height: topGeo.size.height, alignment: .top)
                                    .offset(y:  -scrollPosition.y )
                                Spacer()
                            }
                        )
                    
                    content
                        .blur(radius: 15)
                        .frame(height: topGeo.size.height, alignment: .top)
                        .mask(gradient
                            .frame(height: topGeo.size.height)
                            .offset(y:  -scrollPosition.y )
                        )
                        .ignoresSafeArea()
                }
                .padding(.bottom, topGeo.size.height * 0.25)
                .background(GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self,
                                    value: geo.frame(in: .named(coordinateSpaceName)).origin)
                })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollPosition = value
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
        }
        .ignoresSafeArea()
    }
}


//MARK: Utitilities
private struct BecomingVisible: ViewModifier {
    @State var action: (() -> Void)?

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: VisibleKey.self,
                        // See discussion!
                        value: UIScreen.main.bounds.intersects(proxy.frame(in: .global))
                    )
                    .onPreferenceChange(VisibleKey.self) { isVisible in
                        guard isVisible, let action else { return }
                        action()
//                        action = nil
                    }
            }
        }
    }

    struct VisibleKey: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) { }
    }
}

private struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct Developer: ViewModifier {
    func body(content: Content) -> some View {
        if inDev {
            content
        }
    }
}

private struct DefaultAlert: ViewModifier {
    
    @Binding var activate: Bool
    let title: String
    let description: String
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $activate) { } message: {
                Text( description )
            }

    }
}

//MARK: Transitions
private struct SlideTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transition(.push(from: .trailing))
    }
}

//MARK: Colors
private struct UniversalForegroundColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .light ? Colors.accent : Colors.accent)
    }
}

private struct UniversalBackgroundColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let ignoreSafeAreas: Edge.Set?
    
    func body(content: Content) -> some View {
        content
            .if(ignoreSafeAreas == nil ) { view in view.background(colorScheme == .light ? Colors.accent : Colors.accent) }
            .if(ignoreSafeAreas != nil ) { view in view.background(colorScheme == .light ? Colors.accent : Colors.accent, ignoresSafeAreaEdges: ignoreSafeAreas!) }
            
    }
}

//MARK: Extension
extension View {
    func universalBackground(padding: Bool = true) -> some View {
        modifier(UniversalBackground( padding: padding ))
    }
    
    func universalColoredBackground(_ color: Color) -> some View {
        modifier(UniversalColoredBackground(color: color))
    }
    
    func universalTextStyle() -> some View {
        modifier(UniversalTextStyle())
    }
    
    func reversedUniversalTextStyle() -> some View {
        modifier(ReversedUniversalTextStyle())
    }
    
    func universalTextField() -> some View {
        modifier(UniversalTextField())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
//    MARK: Rectangular Backgrounds (extension)
    func transparentRectangularBackgorund(_ padding: CGFloat? = nil, cornerRadius: CGFloat? = nil) -> some View {
        modifier(TransparentRectangularBackground(padding: padding, radius: cornerRadius))
    }
    
    func opaqueRectangularBackground(_ padding: CGFloat? = nil, stroke: Bool = false, texture: Bool = true) -> some View {
        modifier(OpaqueRectangularBackground(padding: padding, stroke: stroke, texture: texture))
    }
    
    func secondaryOpaqueRectangularBackground(_ padding: CGFloat? = nil) -> some View {
        modifier(SecondaryOpaqueRectangularBackground(padding: padding))
    }
    
    func accentRectangularBackground(_ cornerRadius: CGFloat? = nil) -> some View {
        modifier(AccentBackground(cornerRadius: cornerRadius))
    }
    
    func tintRectangularBackground(_ padding: CGFloat? = nil, cornerRadius: CGFloat? = nil) -> some View {
        modifier(TintBackground(padding: padding, radius: cornerRadius))
    }
    
    func blurScroll(_ blur: CGFloat) -> some View {
        modifier( BlurScroll(blur: blur) )
    }
    
    func onBecomingVisible(perform action: @escaping () -> Void) -> some View {
        modifier(BecomingVisible(action: action))
    }
    
    func universalForegroundColor() -> some View {
        modifier( UniversalForegroundColor() )
    }
    
    func universalBackgroundColor(ignoreSafeAreas: Edge.Set? = nil) -> some View {
        modifier( UniversalBackgroundColor(ignoreSafeAreas: ignoreSafeAreas) )
    }

    
//    MARK: Utilities
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    func delayTouches() -> some View {
        Button(action: {}) {
            highPriorityGesture(TapGesture())
        }
        .buttonStyle(NoButtonStyle())
    }
    
    @ViewBuilder
    func `if`<Content: View>( _ condition: Bool, contentBuilder: (Self) -> Content ) -> some View {
        if condition {
            contentBuilder(self)
        } else { self }
    }
    
    func developer() -> some View {
        modifier( Developer() )
    }
    
    func defaultAlert(_ binding: Binding<Bool>, title: String, description: String) -> some View {
        modifier( DefaultAlert(activate: binding, title: title, description: description) )
    }
    
//    MARK: Transitions
    func slideTransition() -> some View {
        modifier( SlideTransition() )
    }
    
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
    
    
}

//MARK: Vertical Layout
struct VerticalLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let size = subviews.first!.sizeThatFits(.unspecified)
        return .init(width: size.height, height: size.width)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first!.place(at: .init(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: .unspecified)
    }
}


struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
