//
//  ReviewCell.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/2/23.
//

import SwiftUI
//import StarView


//var body: some View {
//
//    VStack(alignment: .leading, spacing: 8) {
//
//        VStack(alignment: .leading, spacing: 4) {
//            title
//            HStack {
//                Stars(count: 5, isEditable: false, color: oceanBlue.yellow, rating: .constant(review.rating))
//                timestamp
//            }
//            reviewDescription
//            username
//                .padding(.top, 10)
//            locationName
//            locationAddress
//        }
//        Divider().overlay(oceanBlue.lightBlue)
//            .padding(.top)
//    }
//}

struct ReviewCell: View {
    
    let review: ReviewModel
    var isShowingLocationName = true
    var isShowingUsername = true
    var needsToHandleColorScheme = false
    let oceanBlue = K.Colors.OceanBlue.self
    
    @Environment(\.colorScheme) var colorScheme
            
    var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                if isShowingLocationName {
                    locationName
                    locationAddress
                }
                
                title
                    .padding(.top, 3)
                
                HStack {
//                    CustomStarRating(currentValue: .constant(review.rating), starSize: (100,50))
                    GradientStars(fillPercent: .constant((review.rating / 5) * 100), starSize: 0.007, spacing: -40)

//                    GradientStars(fillPercent: .constant(Float(review.rating)), starSize: 20)
                    //                Stars(count: 5, isEditable: false, color: oceanBlue.yellow, rating: .constant(review.rating))
//                    SlidingStarsGradient(fillPercent: .constant(Float(review.rating)), frame: (100, 60))
//                    StarRatingView(starCount: 5, totalPercentage: review.rating)
//                                        .frame(width: 100, height: 60)
                        .frame(height: 40)
                    timestamp
                }
                .offset(x: -20)

                reviewDescription
                if isShowingUsername {
                    username
                        .padding(.top, 10)
                }
                //           Divider().overlay(oceanBlue.lightBlue)
                //               .padding(.top)
                
            }
        
    }
  
    private var title: some View {
         Text(review.title)
            .font(.avenirNext(size: 18))
            .multilineTextAlignment(.leading)
            .fontWeight(.medium)
            .italic()
            .foregroundColor(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
    }
    
    private var locationName: some View {
        Text(review.locationName)
            .foregroundColor(shouldBeDark()  ? oceanBlue.white : oceanBlue.blue)
            .font(.avenirNext(size: 19))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)

    }
    
    private var locationAddress: some View {
        Text(review.address.cityState())
            .foregroundColor(shouldBeDark()  ? oceanBlue.white : oceanBlue.blue)
            .font(.avenirNext(size: 16))
//            .fontWeight(.medium)
            .multilineTextAlignment(.leading)

    }
    
    private var reviewDescription: some View {
        Text(review.review)
            .font(.avenirNext(size: 16))
            .foregroundColor(shouldBeDark()  ? oceanBlue.white : oceanBlue.blue)
            .fontWeight(.medium)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)

        
    }
    
    private var username: some View {
        let nameIsEmpty = review.username.isEmpty
        let nameIsBlank = review.username == "" || review.username == " "
        return HStack {
            Spacer()

            Text(nameIsBlank || nameIsEmpty ? "Anonymous" : review.username)
                .font(.avenirNext(size: 14))
                .fontWeight(.bold)
//                .foregroundColor(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
                .foregroundColor(shouldBeDark()  ? oceanBlue.blue : oceanBlue.white)                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
                        .fill(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
                )
            
        }
    }
    
    var timestamp: some View {
        Text(review.timeStamp.dateValue().timeAgoDisplay())
            .foregroundColor(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
            .font(.caption)
    }
    
    func shouldBeDark() -> Bool {
        let isDarkMode = needsToHandleColorScheme && colorScheme == .dark
        let noHandleOfColorScheme = !needsToHandleColorScheme
        let shouldBeDark = isDarkMode || noHandleOfColorScheme
        
        return shouldBeDark
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationLink {
            Text("Hello World")
        } label: {
            
            ReviewCell(review: ReviewModel.example, needsToHandleColorScheme: true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(K.Colors.OceanBlue.blue, lineWidth: 3))
        }
        .padding()
    }
}
