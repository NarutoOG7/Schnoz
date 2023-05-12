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
            
            if userStore.reviews.isEmpty {
                noReviews
            } else {
                VStack {
                    listOfReviews
                        .padding(.vertical, 30)
                    moreButton
                        .padding(.bottom, 20)
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
            ForEach(userStore.reviews, id: \.self) { review in
                NavigationLink {
                    LocationReviewView(
                        isPresented: $isEditingReview,
                        review: .constant(review),
                        location: .constant(review.location ?? nil),
//                        location: .constant(review.location ?? SchnozPlace(placeID: "")),
                        reviews: $userStore.reviews,
                        isUpdatingReview: true,
                        titleInput: review.title,
                        pickerSelection: review.rating,
                        descriptionInput: review.review,
                        isAnonymous: review.username == "Anonymous",
                        nameInput: review.username,
                        userStore: userStore,
                        firebaseManager: firebaseManager,
                        errorManager: errorManager
                    )
                } label: {
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
        
        if userStore.reviews == [] {
            firebaseManager.getReviewsForUser(userStore.user) { review in
                userStore.reviews.append(review)
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
