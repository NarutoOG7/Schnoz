//
//  UserDetailsVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/8/23.
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
        self.reviews = []
        if let selectedUser = selectedUser {
            firebaseManager.batchFirstUsersReviews(
                userID: selectedUser.id,
                sortingOption,
                withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }
    
    func batchSubsequentCall() {
        if let selectedUser = selectedUser {
            firebaseManager.nextPageUsersReviews(
                userID: selectedUser.id,
                sortingOption,
                withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }

    func handleReviewsCompletionWithError(reviews: [ReviewModel]?, error: Error?) {
        DispatchQueue.main.async {
            if let reviews = reviews {
                for review in reviews {
                    if review.username != "Anonymous" {
                        self.reviews.append(review)
                    }
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
