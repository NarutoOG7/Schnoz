//
//  StarRatingView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/23/23.
//

import SwiftUI



public struct StarRatingView: View {
    
    public struct Style {
        
        public let fillColor: Color
        public let lineWidth: CGFloat
        public let borderColor: Color
        public let starExtrusion: CGFloat
        
        public init(
            fillColor: Color = .yellow,
            borderColor: Color = .yellow,
            borderWidth: CGFloat = 4,
            starExtrusion: CGFloat = 20) {
            self.fillColor = fillColor
            self.borderColor = borderColor
            self.lineWidth = borderWidth
            self.starExtrusion = starExtrusion
        }
        
    }
    
    private let starCount: Int
   @State var totalPercentage: CGFloat
    private let style: Style
    private let starSize: CGFloat
    private let spacing: CGFloat
    private var percantageList: [CGFloat] = []
    
    public init(starCount: Int = 5, totalPercentage: CGFloat, style: Style = .init(), starSize: CGFloat, spacing: CGFloat) {
        self.starCount = starCount
        self.totalPercentage = totalPercentage
        self.style = style
        self.starSize = starSize
        self.spacing = spacing
        self.percantageList = self.calculatePercantageList(
            starCount: starCount,
            totalPercentage: totalPercentage
        )
    }
    
    private func calculatePercantageList(starCount: Int, totalPercentage: CGFloat) -> [CGFloat] {
        
        var result: [CGFloat] = []
        
        let total = totalPercentage * CGFloat(starCount)
        
        let fullStarCount = Int(total / 100)
        for _ in 0..<fullStarCount {
            result.append(100)
        }
        
        if result.count == starCount { return result }
        
        let remaining = total.truncatingRemainder(dividingBy: 100)
        result.append(remaining)
        
        while result.count != starCount {
            result.append(0)
        }
        
        return result
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<starCount) { idx in
                StarView(
                    percentage: self.percantageList[idx],
                    starSize: starSize,
                    style: StarView.Style(
                        fillColor: self.style.fillColor,
                        borderColor: self.style.borderColor,
                        borderWidth: self.style.lineWidth,
                        starExtrusion: self.style.starExtrusion
                    )
                    
                )
                .onTapGesture {
                    /// not firing?
                    self.totalPercentage = CGFloat(idx)
                }
            }
        }
    }
    
}
struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(totalPercentage: 50, starSize: 0.01, spacing: 10)
    }
}


public struct StarShape: Shape {
    
    public var starExtrusion: CGFloat = 20.0
    public var scaleFactor: CGFloat = 1.0

    
    private func pointFrom(angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * scaleFactor * cos(angle) + offset.x, y: radius * scaleFactor * sin(angle) + offset.y)
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)

        let pointsOnStar = 5

        var angle: CGFloat = -.pi / 2
        let angleIncrement = CGFloat(.pi * 2.0 / Double(pointsOnStar))
        let radius = rect.midX

        for i in 1...pointsOnStar {
            
            let point = self.pointFrom(angle: angle, radius: radius, offset: center)
            let nextPoint = self.pointFrom(angle: angle + angleIncrement, radius: radius, offset: center)
            let midPoint = self.pointFrom(angle: angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)

            if i == 1 { // First point
                path.move(to: point)
            }

            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)

            angle += angleIncrement
        }

        path.closeSubpath()

        return path
    }
    
}

public struct StarView: Animatable, View {
    
    public struct Style {
        public let fillColor: Color
        public let lineWidth: CGFloat
        public let borderColor: Color
        public let starExtrusion: CGFloat
        
        public init(
            fillColor: Color = .yellow,
            borderColor: Color = .yellow,
            borderWidth: CGFloat = 4,
            starExtrusion: CGFloat = 20
        ) {
            self.fillColor = fillColor
            self.borderColor = borderColor
            self.lineWidth = borderWidth
            self.starExtrusion = starExtrusion
        }
    }
    
    private let style: Style
    private var fillPercentage: CGFloat
    private let starSize: CGFloat
    
    public var animatableData: Double {
        get {
            return Double(fillPercentage)
        }
        set {
            fillPercentage = CGFloat(newValue)
        }
    }
    
    
    public init(percentage: CGFloat, starSize: CGFloat, style: Style = .init()) {
        self.fillPercentage = percentage
        self.starSize = starSize
        self.style = style
    }
        
    private func needsToBeFilledWidth(totalWidth: CGFloat) -> CGFloat {
        return totalWidth * (100 - fillPercentage) / 100
    }
    
    public var body: some View {
           GeometryReader { geometry in
               StarShape(scaleFactor: min(geometry.size.width, geometry.size.height) * starSize) // Adjust 40.0 based on the desired star size
                   .stroke(style.borderColor, lineWidth: style.lineWidth)
                   .overlay(
                       Rectangle()
                           .foregroundColor(style.fillColor)
                           .offset(x: -needsToBeFilledWidth(totalWidth: geometry.size.width))
                           .clipShape(
                               StarShape(scaleFactor: min(geometry.size.width, geometry.size.height) * starSize) // Adjust 40.0 based on the desired star size
                           )
                   )
           }
       }
    
}
