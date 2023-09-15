//
//  ReviewCard.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI
//import StarView

struct ReviewCard: View {
    
    let review: ReviewModel
    
    let oceanBlue = K.Colors.OceanBlue.self
            
    var body: some View {
            VStack(alignment: .leading,spacing: 7) {
                placeNameView
                title
                HStack {
                    GradientStars(isEditable: false, fillPercent: .constant((review.rating / 5) * 100), starSize: 0.01, spacing: -15)
//                    CustomStarRating(currentValue: .constant(review.rating), starSize: (200,40))
//                    StarRatingView(value: 5, stars: Int(review.rating))
//                    SlidingStarsGradient(fillPercent: .constant(Float(review.rating)), frame: (200, 40))
                    
                    //                    .padding(.bottom, 6)
                    timestamp
                }
                description
                name
                    .padding(.trailing, 15)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(oceanBlue.blue, lineWidth: 3))
        }
    
    
    var title: some View {
        Text(review.title)
            .font(.avenirNext(size: 20))
            .fontWeight(.medium)
            .foregroundColor(oceanBlue.blue)
            .multilineTextAlignment(.leading)
    }
    
    var placeNameView: some View {
        Text(review.locationName)
            .font(.avenirNext(size: 16))
            .foregroundColor(oceanBlue.blue)
            .multilineTextAlignment(.leading)

    }
    
//    var stars: some View {
////        Stars(color: oceanBlue.yellow,
////               rating: .constant(review.rating))
//    }
    
    var description: some View {
        Text(review.review)
            .font(.avenirNext(size: 17))
            .fontWeight(.light)
            .foregroundColor(oceanBlue.blue)
            .multilineTextAlignment(.leading)

//            .fixedSize(horizontal: true, vertical: false)
    }
    
    var name: some View {
        HStack {
            Spacer()
            Text("-\(review.username)")
                .font(.avenirNext(size: 17))
                .fontWeight(.medium)
                .foregroundColor(oceanBlue.blue)
                .multilineTextAlignment(.trailing)

        }
    }
    
    var timestamp: some View {
        Text(review.timeStamp.dateValue().timeAgoDisplay())
            .foregroundColor(oceanBlue.blue)
            .font(.caption)
    }
}

struct ReviewCard_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCard(review: ReviewModel.example)
        .padding()
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
