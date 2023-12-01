//
//  PlanterSheet.swift
//  Planter
//
//  Created by Brian Masse on 11/30/23.
//

import Foundation
import SwiftUI

//MARK: PlanterSheetReceiver
//This viewModle is the source of truth for whether a view is displayed or not
class PlanterSheetViewModel: ObservableObject {
    
    static let shared = PlanterSheetViewModel()
    
    @Published private(set) var isPresented: Bool = false
    
    var content: AnyView? = nil
    
    func setPresentation( _ newValue: Bool ) {
        self.isPresented = newValue
    }
        
}

//this should only be applied to high level views that can span the entire screen
private struct PlanterSheetPresenter: ViewModifier {
    
    @ObservedObject var viewModel: PlanterSheetViewModel = PlanterSheetViewModel.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ZStack {
                if viewModel.isPresented {
                    GeometryReader { geo in
                        if let view = viewModel.content {
                            view
                                .environment(\.planterSheetDismiss, PlanterSheetDismiss(action: {
                                    withAnimation { viewModel.setPresentation(false) }
                                }))
                        }
                    }
                }
            }
        }
    }
}

//MARK: EnvironmentValues
//These allow views presented with PlanterSheet to find an environment object, and, when convenient,
//call a dismiss function to get rid of the view
extension EnvironmentValues {
    var planterSheetDismiss: PlanterSheetDismiss {
        get { self[PlanterSheetDismissKey.self] }
        set { self[PlanterSheetDismissKey.self] = newValue }
    }
}

struct PlanterSheetDismissKey: EnvironmentKey {
    static var defaultValue: PlanterSheetDismiss = PlanterSheetDismiss()
}

struct PlanterSheetDismiss {
    private var action: () -> Void
    
    func dismiss() {
        action()
    }
    
    init( action: @escaping () -> Void = { } ) {
        self.action = action
    }
}

//MARK: PlanterSheet
//This is the wrapper that goes around individual views that you want to present a PlanterSheet
//it simply looks for changes in the isPresented variable and passes them to the viewModel
//and looks for changes in the viewModel.isPresented to update the local state
private struct PlanterSheet: ViewModifier {
    
    @ObservedObject var viewModel: PlanterSheetViewModel = PlanterSheetViewModel.shared
    @Binding var isPresented: Bool
    
    let sheetContent: AnyView
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { oldValue, newValue in
                withAnimation {
                    viewModel.setPresentation(newValue)
                    viewModel.content = sheetContent
                }
            }
            .onChange(of: viewModel.isPresented) { oldValue, newValue in
                withAnimation {
                    if !newValue { isPresented = false }
                }
            }
    }
}


extension View {
    
    func planterSheet<Content: View>( isPresented: Binding<Bool>, transition: AnyTransition = .opacity, content: @escaping () -> Content ) -> some View {
        
        modifier( PlanterSheet(isPresented: isPresented, 
                               sheetContent: AnyView(content().transition( transition )) ) )
        
    }
    
    func planterSheetPresenter() -> some View {
        modifier( PlanterSheetPresenter() )
    }
}
