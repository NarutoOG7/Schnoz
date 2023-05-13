//
//  MoreReviewsSheet.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import SwiftUI

struct MoreReviewsSheet: View {
    
    let placeID: String
    @State var reviews: [ReviewModel] = []
    @State var totalReviewsCount = 0
    @State private var needToFetchMore = false
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    var body: some View {
        ZStack {
            oceanBlue.black
//                .shadow(color: oceanBlue.white, radius: 10, x: 0, y: 100)
            VStack {
                handle
                list
            }
//            moreButton
        }
        .background(oceanBlue.black)
        
            .task {
                self.getTotalReviewsCount()
            }
    }
    
    private var list: some View {
        //        List(reviews) { review in
        List {
            ForEach(0..<reviews.count, id: \.self) { index in
                
                cellFor(reviews[index])
                    .listRowBackground(oceanBlue.black)
                
//                if index == reviews.endIndex - 1 {
//                   let _ = moreTapped()
//                }

            }
        }
        .modifier(ClearListBackgroundMod())
//        .foregroundColor(oceanBlue.black)
    }
    
    
    private func cellFor(_ review: ReviewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(review.title)
                .font(.avenirNextRegular(size: 25))
                .foregroundColor(oceanBlue.lightBlue)
            Stars(color: oceanBlue.yellow,
                  rating: .constant(review.rating))
            Text(review.review)
                .font(.avenirNextRegular(size: 18))
                .foregroundColor(oceanBlue.white)
            
        }
        
    }
    
    private var handle: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 100, height: 5)
            .foregroundColor(oceanBlue.lightBlue)
            .padding(.top, 7)
        
    }
    
    private var moreButton: some View {
        Button(action: moreTapped) {
            Text("Load More")
                .foregroundColor(K.Colors.OceanBlue.white)
        }
        .opacity(self.totalReviewsCount > self.reviews.count ? 1 : 0)
    }
    
    
    //MARK: - Methods
    
    private func getTotalReviewsCount() {
        if self.totalReviewsCount == 0 {
            firebaseManager.fetchTotalLocationReviewsCount(placeID: placeID) { count, error in
                guard let count = count else { return }
                self.totalReviewsCount = count
            }
        }
    }
    
    private func moreTapped() {
        if needToFetchMore {
            firebaseManager.getNextPageOfLocationReviews(placeID: placeID) { review in
                if !self.reviews.contains(review) {
                    self.reviews.append(review)
                }
                needToFetchMore = false
            }
        }
    }
}

struct MoreReviewsSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoreReviewsSheet(placeID: "12")
    }
}
