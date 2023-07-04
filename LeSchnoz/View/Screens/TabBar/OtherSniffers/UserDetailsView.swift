//
//  UserDetailsView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI
import Firebase

class UserDetailsVM: ObservableObject {
    static let instance = UserDetailsVM()
    @ObservedObject var firebaseManager = FirebaseManager.instance

    @Published var selectedUser: FirestoreUser?
    @Published var reviews: [ReviewModel] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfUsersReviews: DocumentSnapshot?
    
    @Published var errorMessage = ""
    @Published var shouldShowError = false
    
    @Published var sortingOption: ReviewSortingOption = .newest {
        didSet {
            if oldValue != sortingOption {
                self.reviews = []
                self.batchFirstCall()
            }
        }
    }
    
    @Published var listHasScrolledToBottom = false {
        willSet {
            if newValue == true {
                self.batchSubsequentCall()
            }
        }
    }
    
    func batchFirstCall() {
        if let selectedUser = selectedUser {
            firebaseManager.batchFirstUsersReviews(user: selectedUser, sortingOption, withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }
    
    func batchSubsequentCall() {
        if let selectedUser = selectedUser {
            firebaseManager.nextPageUsersReviews(user: selectedUser, sortingOption, withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }

    func handleReviewsCompletionWithError(reviews: [ReviewModel]?, error: Error?) {
        DispatchQueue.main.async {
            if let reviews = reviews {
                for review in reviews {
                    self.reviews.append(review)
                }
            }
            
            if let error = error {
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.shouldShowError = true
    }
    
}

struct UserDetailsView: View {
    let user: FirestoreUser
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @ObservedObject var userDetailsVM = UserDetailsVM.instance
    
    var body: some View {
        ZStack {
            background
            VStack {
                HStack {
                    userName
                    VStack {
                        avgRatingText
                        avgRatingStars
                        reviewsCountText
                    }
                }
                listOfReviews
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
    
    private var userName: some View {
        Text(userDetailsVM.selectedUser?.username ?? "")
            .font(.largeTitle)
    }
    
    private var avgRatingText: some View {
        Text("\(userDetailsVM.selectedUser?.averageStarsGiven ?? 0)")
            .font(.title3)
    }
    
    private var avgRatingStars: some View {
        Stars(color: oceanBlue.yellow, rating: .constant(Int(exactly: userDetailsVM.selectedUser?.averageStarsGiven ?? 0) ?? 0))
    }
    
    private var reviewsCountText: some View {
        Text("\(userDetailsVM.selectedUser?.reviewCount ?? 0)")
            .font(.subheadline)
    }
    
    private var listOfReviews: some View {
            List(userDetailsVM.reviews) { review in
                ReviewCell(review: review)
                    .listRowSeparator(.hidden)
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
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(user: FirestoreUser.example)
    }
}

