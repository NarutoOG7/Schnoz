//
//  LDVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 7/7/23.
//

import SwiftUI
import Firebase

class LDVM: ObservableObject {
    static let instance = LDVM()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    
    @Published var selectedLocation: SchnozPlace?
    @Published var reviews: [ReviewModel] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfLocationReviews: DocumentSnapshot?
    
    @Published var errorMessage = ""
    @Published var shouldShowError = false
    
    @Published var shouldShowLeaveAReviewView = false
    
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
        if let selectedLocation = selectedLocation {
            firebaseManager.batchFirstLocationsReviews(location: selectedLocation, sortingOption, withCompletion: { reviews, error in
                self.handleReviewsCompletionWithError(reviews: reviews, error: error)
            })
        }
    }
    
    func batchSubsequentCall() {
        if let selectedLocation = selectedLocation {
            firebaseManager.nextPageLocationsReviews(location: selectedLocation, sortingOption, withCompletion: { reviews, error in
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
                print(error.localizedDescription)
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.shouldShowError = true
    }
}
