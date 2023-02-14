//
//  CircularButton.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct CircleButton: View {
    var size: SizesForCustomButtons
    var image: Image
    var mainColor: Color
    var accentColor: Color
    var title = ""
    var clicked: (() -> Void)
    
    let minusImageSize = 3.0
    let extraPadding = 11.5
    
    var body: some View {
        
        Button(action: clicked) {
            VStack {
                ZStack {
                    circle
                    imageView
                }
                if title != "" {
                    titleView
                }
            }
            
        }
    }
    
    private var circle: some View {
        Circle()
            .stroke(mainColor, lineWidth: 3)
            .background(Circle()
                .foregroundColor(accentColor))
            .aspectRatio(contentMode: .fit)
            .frame(width: size.rawValue)
            .shadow(color: accentColor, radius: 1.35, x: 0, y: 1)
    }
    
    private var imageView: some View {
        image
            .resizable()
            .tint(mainColor)
            .aspectRatio(contentMode: .fit)
            .frame(
                width: size.rawValue / 2,
                height: imageIsSystemMinus() ? minusImageSize : size.rawValue / 2)
            .padding(.vertical, imageIsSystemMinus() ? extraPadding : 0)
    }
    
    private var titleView: some View {
        Text(title)
            .foregroundColor(mainColor)
            .font(.avenirNextRegular(size: 13))
            .frame(width: 70)
    }
    
    private func imageIsSystemMinus() -> Bool {
        image == Image(systemName: "minus")
    }
}


//MARK: - Sizes

enum SizesForCustomButtons: CGFloat {
    case small = 50
    case medium = 60
}
