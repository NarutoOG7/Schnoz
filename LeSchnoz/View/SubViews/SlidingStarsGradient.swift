//
//  SlidingStarsGradient.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/18/23.
//

import SwiftUI
//import StarView


struct GradientStars: View {
    
    @Binding var fillPercent: CGFloat
    @State var gradients: [Color] = [.orange]
    
    var starCount: Int = 5
    let starSize: CGFloat
    let spacing: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            LinearGradient(gradient: Gradient(colors: gradients), startPoint: .leading, endPoint: .trailing)
                .mask(
                    StarRatingView(starCount: starCount, totalPercentage: (fillPercent), style: .init(borderWidth: 1), starSize: starSize, spacing: spacing)
                )
                .gesture(
                    DragGesture().onChanged({ (value) in
                        let width = geo.size.width - 40
                        let currentX = value.location.x
                        var newPercentage = 100 * currentX / width
                        newPercentage = max(0, newPercentage) // Lowerbound safety
                        newPercentage = min(100, newPercentage) // Upperbound safety
                        self.fillPercent = newPercentage
                    })
                )
                .onChange(of: fillPercent) { newValue in
                    assignGradientsWithPercent(newValue)
                }
                .onAppear {
                    assignGradientsWithPercent(self.fillPercent)
                }
        }
    }
    
    func assignGradientsWithPercent(_ percentage: CGFloat) {
        switch percentage {
            
        case  ...60:     /// case ...3: ///
            self.gradients = [.red, .orange, .yellow, .yellow]
        case 60...90:   /// case 3...4: ///
            self.gradients = [.yellow, .green]
        case 90...100:  /// case 4...5: ///
            self.gradients = [.green]
        default:
            self.gradients = [.blue, .pink]
        }
    }
}

//struct SlidingStarsGradient: View {
//    
//    @Binding var fillPercent: Float
//    @State var gradients: [Color] = [.orange]
//    
//    let frame: (width: CGFloat, height: CGFloat)
//    
//    var body: some View {
//                    let rating = (fillPercent / 5) * 100
//            let ratingString = String(format: "%.1f", fillPercent)
//            VStack {
//                Text(ratingString)
//                    .font(.largeTitle)
//                    .foregroundColor(K.Colors.OceanBlue.white)
//                LinearGradient(gradient: Gradient(colors: gradients), startPoint: .leading, endPoint: .trailing)
//                    .mask(
//                        //                StarRatingView(rating: fillPercent)
//                        StarRatingView(starCount: 5, totalPercentage: CGFloat(fillPercent), style: .init(borderColor: .red, borderWidth: 2))
////                            .frame(height: frame.height)
//                            .padding()
//                            .frame(width: 360, height: 60)
//
//                    )
//                    .gesture(
//                        DragGesture().onChanged({ (value) in
//                            let width = frame.width - 20 // Padding safety
//                            let currentX = value.location.x
//                            var newPercentage = 100 * currentX / width
//                            newPercentage = max(0, newPercentage) // Lowerbound safety
//                            newPercentage = min(100, newPercentage) // Upperbound safety
//                            self.fillPercent = Float(newPercentage)
//                        })
//                    )
//            }.cornerRadius(15)
//            
//                .onChange(of: fillPercent) { newValue in
//                    switch newValue {
//                    
//                    case  ...60:     /// case ...3: ///
//                        self.gradients = [.red, .orange, .yellow, .yellow]
//                    case 60...90:   /// case 3...4: ///
//                        self.gradients = [.yellow, .green]
//                    case 90...100:  /// case 4...5: ///
//                        self.gradients = [.green]
//                    default:
//                        self.gradients = [.blue, .pink]
//                    }
//                }
////                .frame(width: frame.width, height: frame.height)
//    }
//}

struct SlidingStarsGradient_Previews: PreviewProvider {
    static var previews: some View {
//            SlidingStarsGradient(fillPercent: .constant(3.7), frame: (100, 40))
        GradientStars(fillPercent: .constant((1 / 5) * 100), starSize: 0.01, spacing: 0)
    }
}
