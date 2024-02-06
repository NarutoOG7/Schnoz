//
//  FiveStars.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI


//struct FiveStarRatingView: View {
//    @Binding var rating: Double
//
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(0..<5) { index in
//                StarShapeView(index: index, rating: rating)
//            }
//        }
//        .drawingGroup()
//    }
//}
//
//// Star Shape View
//struct StarShapeView: View {
//    let index: Int
//    let rating: Double
//
//    var body: some View {
//        let gradientColors = [
//            Color(red: 1.0, green: 0.0, blue: 0.0).opacity(1.0),   // Red
//            Color(red: 1.0, green: 0.5, blue: 0.0).opacity(1.0),   // Orange
//            Color(red: 1.0, green: 1.0, blue: 0.0).opacity(1.0),   // Yellow
//            Color(red: 0.0, green: 1.0, blue: 0.0).opacity(1.0)    // Green
//        ]
//
//        let starColor: Color
//        if Double(index + 1) <= rating {
//            starColor = gradientColors[3] // Solid green
//        } else if Double(index) + 0.5 <= rating {
//            let percentage = (rating - Double(index)) * 2
//            starColor = gradientColors[2]
////(gradientColors[3], percentage: percentage)
//        } else {
//            starColor = Color.gray // Gray outline
//        }
//
//        return ShapeStar(corners: 5, smoothness: 0.45)
//            .trim(from: 0.0, to: CGFloat(rating))
//            .stroke(starColor)
////                     .stroke(starColor, style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
//            .frame(width: 40, height: 40)
//    }
//}
//
//
//
//
//struct ShapeStar: Shape {
//    // store how many corners the star has, and how smooth/pointed it is
//    let corners: Int
//    let smoothness: Double
//
//    func path(in rect: CGRect) -> Path {
//        // ensure we have at least two corners, otherwise send back an empty path
//        guard corners >= 2 else { return Path() }
//
//        // draw from the center of our rectangle
//        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
//
//        // start from directly upwards (as opposed to down or to the right)
//        var currentAngle = -CGFloat.pi / 2
//
//        // calculate how much we need to move with each star corner
//        let angleAdjustment = .pi * 2 / Double(corners * 2)
//
//        // figure out how much we need to move X/Y for the inner points of the star
//        let innerX = center.x * smoothness
//        let innerY = center.y * smoothness
//
//        // we're ready to start with our path now
//        var path = Path()
//
//        // move to our initial position
//        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))
//
//        // track the lowest point we draw to, so we can center later
//        var bottomEdge: Double = 0
//
//        // loop over all our points/inner points
//        for corner in 0..<corners * 2  {
//            // figure out the location of this point
//            let sinAngle = sin(currentAngle)
//            let cosAngle = cos(currentAngle)
//            let bottom: Double
//
//            // if we're a multiple of 2 we are drawing the outer edge of the star
//            if corner.isMultiple(of: 2) {
//                // store this Y position
//                bottom = center.y * sinAngle
//
//                // …and add a line to there
//                path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
//            } else {
//                // we're not a multiple of 2, which means we're drawing an inner point
//
//                // store this Y position
//                bottom = innerY * sinAngle
//
//                // …and add a line to there
//                path.addLine(to: CGPoint(x: innerX * cosAngle, y: bottom))
//            }
//
//            // if this new bottom point is our lowest, stash it away for later
//            if bottom > bottomEdge {
//                bottomEdge = bottom
//            }
//
//            // move on to the next corner
//            currentAngle += angleAdjustment
//        }
//
//        // figure out how much unused space we have at the bottom of our drawing rectangle
//        let unusedSpace = (rect.height / 2 - bottomEdge) / 2
//
//        // create and apply a transform that moves our path down by that amount, centering the shape vertically
//        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
//        return path.applying(transform)
//
//    }
//}





//struct CustomStar: Shape {
//    private let fillPercentage: CGFloat
//
//    init(fillPercentage: CGFloat) {
//        self.fillPercentage = fillPercentage
//    }
//
//    private func starVertex(in rect: CGRect, at angle: Angle) -> CGPoint {
//        let innerRadius = rect.width / 4
//        let outerRadius = rect.width / 2
//        let x = rect.midX + outerRadius * CGFloat(cos(angle.radians))
//        let y = rect.midY + outerRadius * CGFloat(sin(angle.radians))
//        return CGPoint(x: x, y: y)
//    }
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        for i in 0..<5 {
//            let angle = Angle(degrees: Double(36 * i))
//            let vertex = starVertex(in: rect, at: angle)
//            if i == 0 {
//                path.move(to: vertex)
//            } else {
//                path.addLine(to: vertex)
//            }
//
//            let innerAngle = Angle(degrees: Double(36 * i + 18))
//            let innerVertex = starVertex(in: rect, at: innerAngle)
//            path.addLine(to: innerVertex)
//        }
//
//        path.closeSubpath()
//
//        // Calculate the point where to fill the star
//        let fillPercentage = min(max(0, self.fillPercentage), 1)
//        let startPoint = starVertex(in: rect, at: Angle(degrees: 180))
//        let endPoint = starVertex(in: rect, at: Angle(degrees: 180 - (360 * Double(fillPercentage))))
//
//        path.move(to: startPoint)
//        path.addLine(to: endPoint)
//
//        return path
//    }
//}
//
//struct StarPower: View {
//    @State private var ratings: [Double] = [0.75, 0.75, 0.75, 0.75, 0.75]
//    private let gradientColors: [Color] = [.red, .yellow, .green]
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 8) {
//                ForEach(0..<ratings.count, id: \.self) { index in
//                    ZStack {
//                        CustomStar(fillPercentage: CGFloat(ratings[index]) * 0.75)
//                            .foregroundColor(starForegroundColor(rating: ratings[index]))
//                            .frame(width: 40, height: 40)
//                            .onTapGesture {
//                                let newValue = Double(index + 1) * 0.75
//                                ratings[index] = min(max(0, newValue), 1)
//                            }
//
//                        CustomStar(fillPercentage: 1)
//                            .stroke(starForegroundColor(rating: ratings[index]), lineWidth: 2)
//                            .frame(width: 40, height: 40)
//                    }
//                }
//            }
//            .padding(.bottom, 30)
//
//            Slider(value: $ratings[0], in: 0...1, step: 0.01) {
//                EmptyView()
//            }
//            .accentColor(starForegroundColor(rating: ratings[0]))
//            .padding(.horizontal)
//        }
//    }
//
//    private func starForegroundColor(rating: Double) -> Color {
//        let ratingFraction = rating / 5.0
//        let index = Int(ratingFraction * Double(gradientColors.count - 1))
//        return gradientColors[index]
//    }
//}

//struct Stars: View {
//
//    var count: Int = 5
//
//    var isEditable = false
//
//    let color: Color
//
//    @Binding var rating: Int
//
//
//    var body: some View {
//
//         HStack {
//
//             ForEach(1...count, id: \.self) { index in
//
//                 Image(systemName: self.starImageNameFromRating(index))
//                     .foregroundColor(color)
//
//                     .onTapGesture {
//                         if isEditable {
//                             self.rating = index
//                         }
//                     }
//             }
//        }
//    }
//
//    private func starImageNameFromRating(_ index: Int) -> String {
//            return index <= rating ? "star.fill" : "star"
//    }
//}

//struct StarRatingView: View {
//    @State private var rating: Double = 3.5
//    private let gradientColors: [Color] = [.red, .orange, .orange, .yellow, .yellow]
//    private let starColors: [Color] = [.red, .yellow, .green]
//
//    var body: some View {
//        VStack {
////            ZStack {
////                Rectangle()
////                    .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
////                    .cornerRadius(8)
////                    .frame(height: 20)
////                Rectangle()
////                    .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
////                    .cornerRadius(8)
////                    .frame(width: CGFloat(rating * 20), height: 20)
////            }
////            .padding()
//
//            HStack(spacing: 0) {
//                ForEach(0...4, id: \.self) { index in
//                    let isAllGreen = rating == 5
//                    let isEmpty = Double(index) > rating
//                    let isRed = Double(index)
//                    Image(systemName: isEmpty ? "star" : "star.fill")
////                        .foregroundColor(starColors[Int(rating) >= index ? (Int(rating) == index ? 2 : 1) : 0])
//                        .foregroundColor(isEmpty ? .gray :
//                                            isAllGreen ? .green :
//                        )
////                        .foregroundColor(Color(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing)))
//                        .cornerRadius(8)
//                        .frame(height: 20)
//                        .onTapGesture {
//                            rating = Double(index)
//                        }
//                }
//            }
//            .padding()
//
//            Slider(value: $rating, in: 1...5, step: 0.1)
//                .padding(.horizontal)
//        }
//    }
//}

///    @State private var rating: Double = 3.5
///
///    private let gradientColors: [Color] = [.red, .yellow, .green]
///
///    private func starForegroundColor() -> Color {
///        let ratingFraction = rating / 5.0
///        let index = Int(ratingFraction * Double(gradientColors.count - 1))
///        return gradientColors[index]
///    }
///
///    var body: some View {
///        VStack {
///            Slider(value: $rating) {
///                HStack(spacing: 0) {
///                    ForEach(1...5, id: \.self) { index in
///                        Image(systemName: "star.fill")
///                            .foregroundColor(starForegroundColor())
///                            .onTapGesture {
///                                rating = Double(index)
///                            }
///                    }
///                }
///                .padding()
///            }
///            .foregroundColor(starForegroundColor())
///            .accentColor(starForegroundColor())
///            .padding(.horizontal)
///            .padding(.bottom, 30)
///
///
///        }
///    }
///}


//@State private var rating: Double = 3.5
//
//private let gradientColors: [Color] = [.red, .yellow, .green]
//
//private func starForegroundColor() -> Color {
//    let ratingFraction = rating / 5.0
//    let index = Int(ratingFraction * Double(gradientColors.count - 1))
//    return gradientColors[index]
//}
//
//var body: some View {
//    VStack {
//        ZStack {
//            Rectangle()
//                .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
//                .cornerRadius(8)
//                .frame(height: 20)
//            Rectangle()
//                .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
//                .cornerRadius(8)
//                .frame(width: CGFloat(rating / 5.0 * 100), height: 20)
//        }
//        .padding()
//
//        HStack(spacing: 0) {
//            ForEach(1...5, id: \.self) { index in
//                Image(systemName: "star.fill")
//                    .foregroundColor(starForegroundColor())
//                    .onTapGesture {
//                        rating = Double(index)
//                    }
//            }
//        }
//        .padding()
//
//        Slider(value: $rating, in: 1...5, step: 0.1)
//            .padding(.horizontal)
//    }
//}
//}
//


struct Stars: View {
    var count: Int = 5
    var isEditable = false
    let color: Color
    @Binding var rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...count, id: \.self) { index in
                Image(systemName: self.starImageNameFromRating(index))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(color)
                    .onTapGesture {
                        if isEditable {
                            self.rating = index
                        }
                    }
            }
        }
    }
    
    private func starImageNameFromRating(_ index: Int) -> String {
        return index <= rating ? "star.fill" : "star"
    }
}

struct FiveStars_Previews: PreviewProvider {
    static var previews: some View {
        Stars(
            isEditable: true,
            color: K.Colors.OceanBlue.yellow,
            rating: .constant(3))
    }
}
