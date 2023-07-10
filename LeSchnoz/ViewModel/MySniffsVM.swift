//
//  MySniffsVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/6/23.
//

import SwiftUI
import Firebase


class MySniffsVM: ObservableObject {
    static let instance = MySniffsVM()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var userStore = UserStore.instance

    
    @Published var reviews: [ReviewModel] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfMySniffs: DocumentSnapshot?
    @Published var errorMessage = ""
    @Published var shouldShowError = false
    
    @Published var listHasScrolledToBottom = false {
        willSet {
            if newValue == true {
                self.batchSubsequentCall()
            }
        }
    }
    
    @Published var sortingOption: ReviewSortingOption = .newest  {
        didSet {
            if oldValue != sortingOption {
                self.reviews = []
                self.batchFirstCall()
            }
        }
    }

    
    func batchFirstCall() {
        self.reviews = []
        firebaseManager.batchFirstUsersReviews(
            userID: userStore.user.id,
                sortingOption)
        { reviews, error in
            self.handleReviewsCompletionWithError(reviews: reviews, error: error)
        }
    }
    
    func batchSubsequentCall() {
        firebaseManager.nextPageUsersReviews(
            userID: userStore.user.id,
            sortingOption)
        { reviews, error in
            self.handleReviewsCompletionWithError(reviews: reviews, error: error)
        }
    }

    func handleReviewsCompletionWithError(reviews: [ReviewModel]?, error: Error?) {
        DispatchQueue.main.async {
            if let reviews = reviews {
                for review in reviews {
                    if !self.reviews.contains(review) { // doesn't contain
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
