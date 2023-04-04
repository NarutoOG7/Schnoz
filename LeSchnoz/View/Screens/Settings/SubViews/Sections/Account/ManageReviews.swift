//
//  ManageReviews.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/28/22.
//

import SwiftUI

struct ManageReviews: View {
    
    
    @State private var reviews: [ReviewModel] = []
    @State private var selectedIndexSet: IndexSet?
    @State private var isEditingReview = false
    
    @State private var shouldShowRemoveReviewConfirmation = false
    
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        ZStack {
            oceanBlue.blue
                .edgesIgnoringSafeArea(.all)
            
            if userStore.reviews.isEmpty {
                noReviews
            } else {
                listOfReviews
                    .padding(.vertical, 30)
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
                        location: .constant(review.location ?? SchnozPlace(placeID: "")),
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
                    Text(review.title)
                        .foregroundColor(oceanBlue.white)
                        .font(.avenirNext(size: 18))
                        .italic()
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
    
    private func delete(at offsets: IndexSet) {
        
        offsets.map { userStore.reviews[$0] }.forEach { review in
            ListResultsVM.instance.refreshData(review, placeID: review.locationID, isRemoving: true, isAddingNew: false)
            firebaseManager.removeReviewFromFirestore(review)
        }
        userStore.reviews.remove(atOffsets: offsets)
        self.reviews.remove(atOffsets: offsets)
        ListResultsVM.instance.latestReview = nil
    }
    
    private func assignReviews() {
        
        userStore.reviews = []
        self.reviews = []
        
        firebaseManager.getReviewsForUser(userStore.user) { review in
            userStore.reviews.append(review)
            self.reviews.append(review)
        }
    }
    
}

struct ManageReviews_Previews: PreviewProvider {
    static var previews: some View {
        ManageReviews(firebaseManager: FirebaseManager(),
                      userStore: UserStore(),
                      errorManager: ErrorManager())
    }
}
