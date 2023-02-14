//
//  ManageReviews.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/28/22.
//

import SwiftUI

struct ManageReviews: View {
    
    
    @State private var reviews: [ReviewModel] = []
    @State private var selectedReview: ReviewModel?
    @State private var isEditingReview = false
    
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var errorManager: ErrorManager
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    var body: some View {
        ZStack {
            weenyWitch.black
                .edgesIgnoringSafeArea(.all)
            
            if userStore.reviews.isEmpty {
                noReviews
            } else {
                listOfReviews
                    .padding(.vertical, 30)
            }
        }
        .sheet(item: $selectedReview, content: { review in
            LocationReviewView(
                location: .constant(review.location ?? LocationModel.example),
                isPresented: $isEditingReview,
                review: $selectedReview,
                titleInput: review.title,
                pickerSelection: review.rating,
                descriptionInput: review.review,
                isAnonymous: review.username == "Anonymous",
                nameInput: review.username,
                userStore: userStore,
                firebaseManager: firebaseManager,
                errorManager: errorManager
            )
        })
        
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.large)
        
        .onAppear {
            self.assignReviews()
        }
    }
    
    private var noReviews: some View {
        Text("No Reviews")
            .foregroundColor(weenyWitch.lightest)
            .font(.avenirNext(size: 22))
    }
    
    private var listOfReviews: some View {
        
        List {
            ForEach(userStore.reviews, id: \.self) { review in
                Button(action: {
                    
                    self.selectedReview = review
                    self.isEditingReview = true
                    
                }, label: {
                    Text(review.title)
                        .foregroundColor(weenyWitch.brown)
                        .font(.avenirNext(size: 18))
                        .italic()
                })
                .listRowBackground(weenyWitch.lightest)
                
            }
            .onDelete(perform: delete)
        }
        .modifier(ClearListBackgroundMod())
        .listStyle(.insetGrouped)
        
    }
    
    private func delete(at offsets: IndexSet) {
        
        offsets.map { userStore.reviews[$0] }.forEach { review in
            
            firebaseManager.removeReviewFromFirestore(review)
        }
        
        userStore.reviews.remove(atOffsets: offsets)
    }
    
    private func assignReviews() {
        
        userStore.reviews = []
        
        firebaseManager.getReviewsForUser(userStore.user) { rev in
            
            var review = rev
            
            if let location = locationStore.hauntedHotels.first(where: { "\($0.location.id)" == review.locationID }) {
                
                review.location = location
            }
            
            userStore.reviews.append(review)
        }
    }
}

struct ManageReviews_Previews: PreviewProvider {
    static var previews: some View {
        ManageReviews(firebaseManager: FirebaseManager(),
                      userStore: UserStore(),
                      locationStore: LocationStore(),
                      errorManager: ErrorManager())
    }
}
