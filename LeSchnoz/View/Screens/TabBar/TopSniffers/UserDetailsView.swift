//
//  UserDetailsView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI
import Firebase



struct UserDetailsView: View {
    let user: FirestoreUser
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State var showReviewSortActionSheet = false
    
    @ObservedObject var userDetailsVM = UserDetailsVM.instance
    
    var body: some View {
        ZStack {
            background
            VStack(alignment: .leading) {
                    username
                        .padding(.bottom)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        totalReviews
                        totalStars
                        averageStars
                    }
                    .padding()
                
                    listOfReviews
                }
            .padding(.top, -30)
            }

        .actionSheet(isPresented: $showReviewSortActionSheet) {
            ActionSheet(
                title: Text("Sort Options"),
                buttons: [
                    .default(Text(ReviewSortingOption.newest.rawValue), action: {
                        userDetailsVM.sortingOption = .newest
                    }),
                    .default(Text(ReviewSortingOption.oldest.rawValue), action: {
                        userDetailsVM.sortingOption = .oldest
                    }),
                    .default(Text(ReviewSortingOption.best.rawValue), action: {
                        userDetailsVM.sortingOption = .best
                    }),
                    .default(Text(ReviewSortingOption.worst.rawValue), action: {
                        userDetailsVM.sortingOption = .worst
                    }),
                    .cancel()
                    
                ]
            )
        }
        .toolbar {
            if userDetailsVM.reviews.count > 1 {
                sortReviewsButton
            }
        }
    }
    
    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [oceanBlue.lightBlue, oceanBlue.blue]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var username: some View {
        Text(user.username)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(oceanBlue.white)
    }
    
    private var totalReviews: some View {
        HStack {
            Text("Total Reviews:")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.blue)
                .italic()
            Text("\(user.reviewCount ?? 0)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }
    
    private var totalStars: some View {
        let starsCount = user.doubleAsStringWithIntFloor(user.totalStarsGiven ?? 0)

        return HStack {
            Text("Total Stars Given:")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.blue)
                .italic()
            
            Text(starsCount)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }
    
    private var averageStars: some View {
        HStack {
            Text("Average Rating:")
               .font(.title3)
               .fontWeight(.bold)
                .foregroundColor(oceanBlue.blue)
                .italic()
            
            Text(user.doubleAsStringWithIntFloor(user.averageStarsGiven ?? 0))
               .font(.title3)
               .fontWeight(.bold)
                .foregroundColor(oceanBlue.white)
                .italic()
        }
    }

    private var listOfReviews: some View {
        List(userDetailsVM.reviews) { review in
                ReviewCell(review: review, isNavigatable: true)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        let isLast = userDetailsVM.reviews.last == review
                        userDetailsVM.listHasScrolledToBottom = isLast
                    }
            }
            .modifier(ClearListBackgroundMod())
            .onAppear {
                let isNewUser = userDetailsVM.selectedUser != self.user
                if  isNewUser {
                    userDetailsVM.selectedUser = self.user
                    userDetailsVM.reviews = []
                    userDetailsVM.lastDocumentOfUsersReviews = nil
                    userDetailsVM.batchFirstCall()
                }

            }
    }
    
    
    private var sortReviewsButton: some View {
        HStack {
            Spacer()
            Button(action: sortReviewsTapped) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(oceanBlue.yellow)
                    .font(.title3)
            }
        }
    }
    
    private func sortReviewsTapped() {
        showReviewSortActionSheet = true
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
            UserDetailsView(user: FirestoreUser.example)
    }
}

