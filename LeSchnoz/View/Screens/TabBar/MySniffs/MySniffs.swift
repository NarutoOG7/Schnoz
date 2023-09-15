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
                    .toolbar {
                        if viewModel.reviews.count > 1 {
                            sortReviewsButton
                        }
                    }
                
            }
        }
        .task {
                viewModel.batchFirstCall()
            
        }
        .alert(isPresented: $shouldShowRemoveReviewConfirmation) {
            Alert(
                title: Text("Delete Review"),
                message: Text("Are you sure you want to delete the selected review?"),
                primaryButton: .destructive(Text("Delete")) {
                    self.delete(at: self.selectedIndexSet ?? IndexSet())
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
            /// This will remove the stupid disclosure indicator that comes with a Navigation Link
        )
        
        
    }
    
    
    //MARK: - Buttons
    
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
    
    //MARK: - Methods
    
    private func delete(at offsets: IndexSet) {
        offsets.map { viewModel.reviews[$0] }.forEach { review in
            firebaseManager.getAverageRatingForLocation(review.locationID) { oldAverage in
                if var average = oldAverage {
                    print(average)
                    print(review.rating)
                    average.totalStarCount -= review.rating
                    average.numberOfReviews -= 1
                    
                    ListResultsVM.instance.refreshData(review: review, averageRating: average, placeID: review.locationID, refreshType: .remove)
                    LDVM.instance.selectedLocation?.averageRating = average
                    
                    // Firestore User
                    if var firestoreUser = userStore.firestoreUser {
                        firestoreUser.totalStarsGiven? -= review.rating
                        firestoreUser.reviewCount? -= 1
                        if let reviewCount = firestoreUser.reviewCount,
                           let starsCount = firestoreUser.totalStarsGiven,
                           reviewCount > 0 {
                            firestoreUser.averageStarsGiven? = starsCount / Double(reviewCount)
                        }
                     
        //                userStore.firestoreUser = newUser
                        firebaseManager.updateFirestoreUser(firestoreUser)
                        
                        
//                        let newUser = firestoreUser.handleRemovalOfReview(review: review)
//                        self.userStore.firestoreUser = newUser
//                        firebaseManager.updateFirestoreUser(newUser)

                    }
                    
                    // Remove Review
                    firebaseManager.removeReviewFromFirestore(review)
                    
                    // Update or Remove AvgRating
                    let noReviews = average.numberOfReviews == 0
                    noReviews ? firebaseManager.removeAverageRating(average) : firebaseManager.addAverageRating(average)
                    
                    // Refresh data
                    self.viewModel.reviews.removeAll(where: { $0 == review })
                    LDVM.instance.reviews.removeAll(where: { $0 == review })
                    userStore.reviews.remove(atOffsets: offsets)
                }
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
            pickerSelection: CGFloat((review.rating / 5) * 100),
            descriptionInput: review.review,
            isAnonymous: review.username == "Anonymous",
            //            nameInput: review.username,
            userStore: userStore,
            firebaseManager: firebaseManager,
            errorManager: errorManager)
    }
}
