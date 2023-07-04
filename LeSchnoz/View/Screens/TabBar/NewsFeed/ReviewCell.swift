//
//  ReviewCell.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/2/23.
//

import SwiftUI

struct ReviewCell: View {
    
    let review: ReviewModel
    var isShowingLocationName = true
    let oceanBlue = K.Colors.OceanBlue.self
    
    
    var body: some View {
            
             VStack(alignment: .leading, spacing: 8) {
                title
                 if isShowingLocationName {
                     locationName
                 }
                Stars(count: 5, isEditable: false, color: oceanBlue.yellow, rating: .constant(review.rating))
                reviewDescription
                username
                Divider().overlay(oceanBlue.lightBlue)
                    .padding(.top)
                 
            }
        }
    private var title: some View {
        Text(review.title)
            .font(.avenirNext(size: 18))
            .fontWeight(.bold)
            .foregroundColor(oceanBlue.white)
    }
    
    private var locationName: some View {
        Text(review.locationName)
            .font(.avenirNext(size: 16))
            .fontWeight(.bold)
            .foregroundColor(oceanBlue.lightBlue)
            .italic()
    }
    
    private var reviewDescription: some View {
        Text(review.review)
            .font(.avenirNext(size: 16))
            .foregroundColor(oceanBlue.white)
            .lineLimit(nil)
        
    }
    
    private var username: some View {
        let nameIsEmpty = review.username.isEmpty
        let nameIsBlank = review.username == "" || review.username == " "
        return HStack {
            Text(nameIsBlank || nameIsEmpty ? "Anonymous" : review.username)
                .font(.avenirNext(size: 12))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.blue)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(oceanBlue.white)
                )
            
            Spacer()
        }
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCell(review: ReviewModel.example)
    }
}
