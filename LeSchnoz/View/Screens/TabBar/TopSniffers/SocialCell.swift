//
//  SocialCell.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI

struct SocialCell: View {
    
    let user: FirestoreUser
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                username
                VStack(alignment: .leading, spacing: 4) {
                    totalReviews
                    totalStars
                    averageStars
                }
            }
            Spacer()
        }

        .padding()
        .background(oceanBlue.blue)
        .cornerRadius(10)

        .padding(.horizontal)

    }
    
    private var username: some View {
        Text(user.username)
            .font(.avenirNext(size: 18))
            .fontWeight(.bold)
            .foregroundColor(oceanBlue.white)
    }
    
    private var totalReviews: some View {
        HStack {
            Text("Total Reviews:")
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.lightBlue)
                .italic()
            Text("\(user.reviewCount ?? 0)")
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }
    
    private var totalStars: some View {
        let starsCount = user.totalStarsGiven ?? 0
        return HStack {
            Text("Total Stars Given:")
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.lightBlue)
                .italic()
            
            Text(String(format: "%.1f", starsCount))
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }
    
    private var averageStars: some View {
        HStack {
            Text("Average Rating:")
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.lightBlue)
                .italic()
            
            Text(user.averageStarsAsString)
                .font(.avenirNext(size: 16))
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }
}


struct SocialCell_Previews: PreviewProvider {
    static var previews: some View {
        SocialCell(user: FirestoreUser.example)
    }
}
