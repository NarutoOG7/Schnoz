//
//  SlideOverCard.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct SlideOverCard<Content: View> : View {
    
    @GestureState private var dragState = DragState.inactive
    
    @State var position = CardPosition.bottom
    
    @Binding var canSlide: Bool
    
    var color: Color
    var handleColor: Color
    var screenSize: CGFloat
    
    var content: () -> Content
    
    var body: some View {
        
        let drag = DragGesture()
            .updating($dragState) { (drag, state, transaction) in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return VStack {
            
            Handle(color: handleColor)
                .padding(.bottom, 5)
            self.content()
            Spacer()
            
        }
        .frame(width: UIScreen.main.bounds.width, height: screenSize + 300)
        .background(color)
        .cornerRadius(10)
        .shadow(color: .white.opacity(0.13), radius: 10)
        .offset(y: self.position.size(from: screenSize) + self.dragState.translation.height)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragState.isDragging)
        .gesture(canSlide ? drag : nil)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.size(from: screenSize) + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition
        
        if cardTopEdgeLocation <= CardPosition.middle.size(from: screenSize) {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }
        
        if (cardTopEdgeLocation - positionAbove.size(from: screenSize)) < (positionBelow.size(from: screenSize) - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
    
    //MARK: - Card Position
    enum CardPosition: CGFloat {
        case bottom, middle, top
        
        func size(from screenSize: CGFloat) -> CGFloat {
            switch self {
                
            case .bottom:
                return screenSize / 1.2
            case .middle:
                return screenSize / 2.5
            case .top:
                return screenSize / 25
            }
        }
    }
}

struct SlideOverCard_Previews: PreviewProvider {
    static var previews: some View {
        SlideOverCard(canSlide: .constant(true), color: Color.black, handleColor: .white, screenSize: 900) {
            VStack {
                Text("Hello,")
                    .foregroundColor(Color.white)
                Text("My name is Spencer.")
                Text("There is water boiling on the stove.")
            }
        }
    }
}


//MARK: - Drag State
enum DragState {
    
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}





//MARK: - Handle
struct Handle: View {
    
    var color: Color
    
    private let handleThickness = CGFloat(5.0)
    
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(color)
            .padding(10)
    }
}

