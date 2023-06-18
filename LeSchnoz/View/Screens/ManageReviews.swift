//
//  ManageReviews.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/28/22.
//

import SwiftUI

struct ManageReviews: View {
        
    @State private var selectedIndexSet: IndexSet?
    @State private var isEditingReview = false
    @State private var reviewsCount = 0
    @State private var shouldShowRemoveReviewConfirmation = false
        
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var listResultsVM: ListResultsVM
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        ZStack {
            oceanBlue.blue
                .edgesIgnoringSafeArea(.all)
            
            if userStore.isGuest {
                Text("Sign in to create reveiws")
                    .foregroundColor(oceanBlue.white)
            } else 
            if userStore.reviews.isEmpty {
                noReviews
            } else {
                VStack {
                    listOfReviews
                        .padding(.vertical, 30)
//                    moreButton
//                        .padding(.bottom, 20)
                }
            }
        }
        
        .alert(isPresented: $shouldShowRemoveReviewConfirmation) {
            Alert(
                title: Text("Delete items"),
                message: Text("Are you sure you want to delete the selected items?"),
                primaryButton: .destructive(Text("Delete")) {
                    // delete selected items here
                    self.delete(at: self.selectedIndexSet ?? IndexSet())
//                    userStore.reviews.remove(atOffsets: selectedIndexSet ?? IndexSet())
                    selectedIndexSet = nil
                },
                secondaryButton: .cancel()
            )
        }
        
        .task {
            assignReviews()
            getTotalReviewsCount()
        }
        
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.large)
        
    }
    
    private var noReviews: some View {
        Text("No Reviews")
            .foregroundColor(oceanBlue.white)
            .font(.avenirNext(size: 22))
    }
    
    private var listOfReviews: some View {
        
        List {
            ForEach(0..<userStore.reviews.count, id: \.self) { index in
//            ForEach(userStore.reviews, id: \.self) { review in
//                if index == userStore.reviews.endIndex - 1 {
//                   let _ = moreTapped()
//                }
                cellForReview(userStore.reviews[index])
                .listRowBackground(Color.clear)
                
            }
            .onDelete(perform: { indexSet in
                self.selectedIndexSet = indexSet
                self.shouldShowRemoveReviewConfirmation = true
            })
//            .onDelete(perform: delete)
        }
        .modifier(ClearListBackgroundMod())
        .listStyle(.insetGrouped)
        
    }
    
    //MARK: - Cell For Reviews List
    
    private func cellForReview(_ review: ReviewModel) -> some View {
        NavigationLink {
            destinationLink(review)
        } label: {
            cellLabel(review)
        }

    }
    
    private func cellLabel(_ review: ReviewModel) -> some View {
        VStack(alignment: .leading) {
            Text(review.title)
                .foregroundColor(oceanBlue.white)
                .font(.avenirNext(size: 18))
                .italic()
            Text(review.locationName)
                .foregroundColor(oceanBlue.lightBlue)
                .font(.avenirNext(size: 16))
                .italic()
        }
    }
    
    private func destinationLink(_ review: ReviewModel) -> some View {
        LocationReviewView(
            isPresented: $isEditingReview,
            review: .constant(review),
            location: .constant(review.location ?? nil),
            reviews: $userStore.reviews,
            isUpdatingReview: true,
            titleInput: review.title,
            pickerSelection: review.rating,
            descriptionInput: review.review,
            isAnonymous: review.username == "Anonymous",
            nameInput: review.username,
            userStore: userStore,
            firebaseManager: firebaseManager,
            errorManager: errorManager)
    }
    
    //MARK: - Buttons
    
    private var moreButton: some View {
        Button(action: moreTapped) {
            Text("Load All")
        }
        .opacity(self.reviewsCount > userStore.reviews.count ? 1 : 0)
    }
    

    //MARK: - Methods
    
    private func moreTapped() {
        
        firebaseManager.getNextPageOfUserReviews { review in
            userStore.reviews.append(review)
        }

    }
    
    private func delete(at offsets: IndexSet) {
        
        offsets.map { userStore.reviews[$0] }.forEach { review in
            firebaseManager.getAverageRatingForLocation(review.locationID) { avgRating in
                if var avgRating = avgRating {
                    avgRating.totalStarCount -= review.rating
                    avgRating.numberOfReviews -= 1

                    let noReviews = avgRating.numberOfReviews == 0
                    noReviews ? firebaseManager.removeAverageRating(avgRating) : firebaseManager.addAverageRating(avgRating)
                    
                    let avg = noReviews ? nil : avgRating
                    ListResultsVM.instance.refreshData(review: review, averageRating: avg, placeID: review.locationID, isRemoving: true, isAddingNew: false)
                }
            }
            firebaseManager.removeReviewFromFirestore(review)
        }
        userStore.reviews.remove(atOffsets: offsets)
        ListResultsVM.instance.latestReview = nil
    }
    
    private func assignReviews() {
        if !userStore.isGuest {
            if userStore.reviews == [] {
                firebaseManager.getReviewsForUser(userStore.user) { review in
                    userStore.reviews.append(review)
                }
            }
        }
    }
    
    private func getTotalReviewsCount() {
        if self.reviewsCount == 0 {
            firebaseManager.fetchTotalUserReviewsCount { count, error in
                guard let count = count else { return }
                self.reviewsCount = count
            }
        }
    }
}

struct ManageReviews_Previews: PreviewProvider {
    static var previews: some View {
        ManageReviews(firebaseManager: FirebaseManager(),
                      userStore: UserStore(),
                      errorManager: ErrorManager(),
                      listResultsVM: ListResultsVM())
    }
}
