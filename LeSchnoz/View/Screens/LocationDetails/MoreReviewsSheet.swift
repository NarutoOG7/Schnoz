//
//  MoreReviewsSheet.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import SwiftUI

struct MoreReviewsSheet: View {
    
    var reviews: [ReviewModel] = []
    
    let weenyWitch = K.Colors.OceanBlue.self
    
    var body: some View {
        list
            .background(weenyWitch.black)
    }
    
    private var list: some View {
        List(reviews) { review in
            
            cellFor(review)
                .listRowBackground(Color.clear)
            
        }
        .modifier(ClearListBackgroundMod())
    }
    
    
    private func cellFor(_ review: ReviewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(review.title)
                .font(.avenirNextRegular(size: 25))
                .foregroundColor(weenyWitch.lightBlue)
            FiveStars(color: weenyWitch.yellow,
                      rating: .constant(review.rating))
            Text(review.review)
                .font(.avenirNextRegular(size: 18))
                .foregroundColor(weenyWitch.white)
            
        }
    }
}

struct MoreReviewsSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoreReviewsSheet()
    }
}
