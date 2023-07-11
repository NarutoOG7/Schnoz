//
//  ManageReviews.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/28/22.
//

import SwiftUI


struct MySniffs: View {
    
    @State private var selectedIndexSet: IndexSet?
    @State private var isEditingReview = false
    @State private var reviewsCount = 0
    @State private var shouldShowRemoveReviewConfirmation = false
    @State private var showReviewSortActionSheet = false
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var listResultsVM: ListResultsVM
    @ObservedObject var viewModel = MySniffsVM.instance
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        ZStack {
            oceanBlue.blue
                .edgesIgnoringSafeArea(.all)
            
            
            if userStore.isGuest {
                Text("Sign in to manage reveiws")
                    .foregroundColor(oceanBlue.white)
            } else
            if viewModel.reviews.isEmpty && !viewModel.isFetchInProgress {
                noReviews
            } else {
                listOfReviews
                //                        .padding(.vertical, 5)
                    .toolbar {
                        if viewModel.reviews.count > 1 {
                            sortReviewsButton
                        }
                    }
                
            }
        }
        .onAppear {
            viewModel.reviews = []
            viewModel.batchFirstCall()
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
        
        .actionSheet(isPresented: $showReviewSortActionSheet) {
            ActionSheet(
                title: Text("Sort Options"),
                buttons: [
                    .default(Text(ReviewSortingOption.newest.rawValue), action: {
                        viewModel.sortingOption = .newest
                    }),
                    .default(Text(ReviewSortingOption.oldest.rawValue), action: {
                        viewModel.sortingOption = .oldest
                    }),
                    .default(Text(ReviewSortingOption.best.rawValue), action: {
                        viewModel.sortingOption = .best
                    }),
                    .default(Text(ReviewSortingOption.worst.rawValue), action: {
                        viewModel.sortingOption = .worst
                    }),
                    .cancel()
                    
                ]
            )
        }
        
        
        .navigationTitle("My Sniffs")
        .navigationBarTitleDisplayMode(.large)
        
    }
    
    private var noReviews: some View {
        Text("No Reviews")
            .foregroundColor(oceanBlue.white)
            .font(.avenirNext(size: 22))
    }
    
    private var listOfReviews: some View {
        
        List {
                        
            ForEach(0..<viewModel.reviews.count, id: \.self) { index in
                cellForReview(viewModel.reviews[index])
                    .listRowBackground(Color.clear)
                    .onAppear {
                        let isLast = viewModel.reviews.endIndex == index
                        viewModel.listHasScrolledToBottom = isLast
                    }
                
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
            ReviewDestinationLink(review: review, isPresented: $isEditingReview)
        } label: {
            ReviewCell(review: review, isShowingUsername: false)
        }

        .padding(.trailing, -30)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.clear, lineWidth: 1)
            ///  // // This will remove the stupid disclosure indicator that comes with a Navigation Link // //  ///
        )
        
        
    }
    
    //MARK: - Methods
    
//    private func delete(at offsets: IndexSet) {
//
//        offsets.map { viewModel.reviews[$0] }.forEach { review in
//
//            firebaseManager.getAverageRatingForLocation(review.locationID) { avgRating in
//                handleNewRating(avgRating, review)
//            }
//        }
//        func handleNewRating(_ avgRating: AverageRating?, _ review: ReviewModel) {
//            if var avgRating = avgRating {
//                avgRating.totalStarCount -= review.rating
//                avgRating.numberOfReviews -= 1
//
//                let noReviews = avgRating.numberOfReviews == 0
//                noReviews ? firebaseManager.removeAverageRating(avgRating) : firebaseManager.addAverageRating(avgRating)
//
//                let avg = avgRating
//                ListResultsVM.instance.refreshData(review: review, averageRating: avg, placeID: review.locationID, isRemoving: true, isAddingNew: false)
//                if var firestoreUser = userStore.firestoreUser {
//                    firestoreUser.handleRemovalOfReview(ogUser: firestoreUser, review: review)
//                }
//                firebaseManager.removeReviewFromFirestore(review)
//                self.viewModel.reviews.removeAll(where: { $0 == review })
//                LDVM.instance.reviews.removeAll(where: { $0 == review })
//                userStore.reviews.remove(atOffsets: offsets)
//                ListResultsVM.instance.latestReview = nil
//                LDVM.instance.selectedLocation?.averageRating = avgRating

//
//            }
//        }
//    }
    
    private func delete(at offsets: IndexSet) {
        offsets.map { viewModel.reviews[$0] }.forEach { review in
            firebaseManager.getAverageRatingForLocation(review.locationID) { oldAverage in
                if var average = oldAverage {
                    average.totalStarCount -= review.rating
                    average.numberOfReviews -= 1
                    
                    let noReviews = average.numberOfReviews == 0
                    noReviews ? firebaseManager.removeAverageRating(average) : firebaseManager.addAverageRating(average)
                    
                    ListResultsVM.instance.refreshData(review: review, averageRating: average, placeID: review.locationID, isRemoving: true, isAddingNew: false)
                    LDVM.instance.selectedLocation?.averageRating = average
                    
                    // Firestore User
                    if var firestoreUser = userStore.firestoreUser {
                        firestoreUser.handleRemovalOfReview(review: review)
                    }
                    
                    // Remove Review
                    firebaseManager.removeReviewFromFirestore(review)
                    
                    // Refresh data
                    self.viewModel.reviews.removeAll(where: { $0 == review })
                    LDVM.instance.reviews.removeAll(where: { $0 == review })

                    userStore.reviews.remove(atOffsets: offsets)
                }
            }
        }
    }
    
//    private func delete(at offsets: IndexSet) {
//        //        let group = DispatchGroup()
//        //        group.enter()
//        offsets.map { viewModel.reviews[$0] }.forEach { review in
//            handleNewLocationAverage(review)
//            handleFirestoreUserAverage(review)
//            removeReviewFromFirestore(review)
//            refreshData(review: review, offsets: offsets)
//        }
//    }
    
    private func handleNewLocationAverage(_ review: ReviewModel) {
        firebaseManager.getAverageRatingForLocation(review.locationID) { oldAverage in
            if var average = oldAverage {
                average.totalStarCount -= review.rating
                average.numberOfReviews -= 1

                let noReviews = average.numberOfReviews == 0
                noReviews ? firebaseManager.removeAverageRating(average) : firebaseManager.addAverageRating(average)

                ListResultsVM.instance.refreshData(review: review, averageRating: average, placeID: review.locationID, isRemoving: true, isAddingNew: false)
                LDVM.instance.selectedLocation?.averageRating = oldAverage
            }
        }
    }
    
    private func handleFirestoreUserAverage(_ review: ReviewModel) {
        if var firestoreUser = userStore.firestoreUser {
            firestoreUser.handleRemovalOfReview(review: review)
        }
    }
    
    private func removeReviewFromFirestore(_ review: ReviewModel) {
        firebaseManager.removeReviewFromFirestore(review) { error in
            if let error = error {
                
            } else {
                ListResultsVM.instance.latestReview = nil

            }
            
        }
        
    }
    
    private func refreshData(review: ReviewModel, offsets: IndexSet) {
        self.viewModel.reviews.removeAll(where: { $0 == review })
        LDVM.instance.reviews.removeAll(where: { $0 == review })

        userStore.reviews.remove(atOffsets: offsets)
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

struct ManageReviews_Previews: PreviewProvider {
    static var previews: some View {
        MySniffs(
            userStore: UserStore(),
            errorManager: ErrorManager(),
            listResultsVM: ListResultsVM())
        .padding(.top)
    }
}


struct ReviewCellLabel: View {
    
    let review: ReviewModel
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
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
}


struct ReviewDestinationLink: View {
    
    let review: ReviewModel
    
    @Binding var isPresented: Bool
    
    @ObservedObject var userStore = UserStore.instance
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    
    var body:  some View {
        LocationReviewView(
            isPresented: $isPresented,
            review: .constant(review),
            location: .constant(review.location ?? nil),
            reviews: $userStore.reviews,
            isUpdatingReview: true,
            titleInput: review.title,
            pickerSelection: review.rating,
            descriptionInput: review.review,
            isAnonymous: review.username == "Anonymous",
            //            nameInput: review.username,
            userStore: userStore,
            firebaseManager: firebaseManager,
            errorManager: errorManager)
    }
}
