//
//  NotificationBanner.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/27/22.
//

import SwiftUI

struct NotificationBanner: View {
    
    @Binding var message: String
    @Binding var isVisible: Bool
    
    @ObservedObject var errorManager: ErrorManager
    
    var body: some View {
        GeometryReader { geo in
            if isVisible {
                VStack {
                    ZStack {
                        banner(geo)
                        messageView
                            .offset(y: 33)
                    }
                    Spacer()
                }
                .gesture(
                    DragGesture()
                        .onEnded { _ in
                            isVisible = false
                        }
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                        self.isVisible = false
                        self.errorManager.shouldDisplay = false
                    }
                }
                .offset(y: -(geo.size.height / 5))
            
            }
        }
        
    }
    
    private func banner(_ geo: GeometryProxy) -> some View {
        return Rectangle()
            .frame(width: geo.size.width, height: 125)
            .foregroundColor(.red)
    }
    
    private var messageView: some View {
        Text(message)
            .foregroundColor(.white)
            .font(.avenirNext(size: 18))
            .multilineTextAlignment(.center)
    }
}

struct NotificationBanner_Previews: PreviewProvider {
    static var previews: some View {
        NotificationBanner(message: .constant("This is going well."),
                           isVisible: .constant(true),
                           errorManager: ErrorManager())
    }
}
