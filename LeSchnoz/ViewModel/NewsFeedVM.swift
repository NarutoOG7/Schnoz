//
//  NewsFeedVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/22/23.
//

import SwiftUI
import Firebase

class NewsFeedVM: ObservableObject {
    
    static let instance = NewsFeedVM()
    
    @Published var isFetchInProgress = false
    @Published var reviews: [ReviewModel] = []
    
    @Published var errorMessage = ""
    @Published var shouldShowError = false
   
    @Published var lastDocumentOfAllReviewsBatchRequest: DocumentSnapshot?

    
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
    
 
    
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    func batchFirstCall() {
        firebaseManager.batchFirstAllUsersReviews(sortingOption) { reviews, error in
            self.handleReviewsCompletionWithError(reviews: reviews, error: error)
        }
    }
    
    func batchSubsequentCall() {
        firebaseManager.nextPageAllUsersReviews(sortingOption) { reviews, error in
            self.handleReviewsCompletionWithError(reviews: reviews, error: error)
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
