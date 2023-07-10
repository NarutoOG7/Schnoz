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
    var isShowingUsername = true
    var needsToHandleColorScheme = false
    let oceanBlue = K.Colors.OceanBlue.self
    
    @Environment(\.colorScheme) var colorScheme
        
    var body: some View {
            
             VStack(alignment: .leading, spacing: 8) {
                title
                 if isShowingLocationName {
                     locationName
                 }
                 HStack {
                     Stars(count: 5, isEditable: false, color: oceanBlue.yellow, rating: .constant(review.rating))
                     timestamp
                 }
                reviewDescription
                 if isShowingUsername {
                     username
                 }
                Divider().overlay(oceanBlue.lightBlue)
                    .padding(.top)
                 
            }
        }
    private var title: some View {
         Text(review.title)
            .font(.avenirNext(size: 18))
            .fontWeight(.bold)
            .foregroundColor(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
    }
    
    private var locationName: some View {
        Text(review.locationName)
            .foregroundColor(shouldBeDark()  ? oceanBlue.white : oceanBlue.lightBlue)
            .font(.avenirNext(size: 16))
            .fontWeight(.medium)
            .italic()
    }
    
    private var reviewDescription: some View {
        Text(review.review)
            .font(.avenirNext(size: 16))
            .foregroundColor(shouldBeDark()  ? oceanBlue.white : oceanBlue.blue)
            .lineLimit(nil)
        
    }
    
    private var username: some View {
        let nameIsEmpty = review.username.isEmpty
        let nameIsBlank = review.username == "" || review.username == " "
        return HStack {
            Text(nameIsBlank || nameIsEmpty ? "Anonymous" : review.username)
                .font(.avenirNext(size: 12))
                .fontWeight(.bold)
                .foregroundColor(shouldBeDark()  ? oceanBlue.blue : oceanBlue.white)                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(shouldBeDark() ? oceanBlue.white : oceanBlue.blue)
                )
            
            Spacer()
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
        }
        .padding()
    }
}
