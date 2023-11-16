//
//  AllSniffersVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI
import Firebase

class TopSniffersVM: ObservableObject {
    static let instance = TopSniffersVM()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance

    
    @Published var users: [FirestoreUser] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfAllUsers: DocumentSnapshot?
    @Published var errorMessage = ""
    @Published var shouldShowError = false

    @Published var sortingOption: SniffersSortingOption = .mostReviews {
        willSet {
            if newValue != sortingOption {
                self.users = []
                self.batchFirstCall()
            }
        }
    }
    
    @Published var listHasScrolledToBottom = false {
        willSet {
            if newValue == true {
                if users.count >= 15 {
                    self.batchSubsequentCall()
                }
            }
        }
    }

    
    func batchFirstCall() {
        self.users = []
        firebaseManager.batchFirstAllUsers(sortingOption) { users, error in
            self.handleUsersCompletionWithError(users: users, error: error)
        }
    }
    
    func batchSubsequentCall() {
        firebaseManager.nextPageAllUsers(sortingOption) { users, error in
            self.handleUsersCompletionWithError(users: users, error: error)
        }
    }

    func handleUsersCompletionWithError(users: [FirestoreUser]?, error: Error?) {
        if let users = users {
            for user in users {
                if (user.reviewCount ?? 0) > 0 {
                    if !self.users.contains(user) {
                        DispatchQueue.main.async {
                            self.users.append(user)
                        }
                    }
                }
            }
        }
            if let error = error {
                self.handleError(error)
            
        }
    }
    
    func handleError(_ error: Error) {
        self.errorMessage = error.localizedDescription
        self.shouldShowError = true
    }
}

enum SniffersSortingOption: String {
    case mostReviews = "Most Reviews"
    case harshestCritic = "Harshest Critics"
    case topSupporters = "Top Supporters"
    
    var sortingQuery: (query: String, descending: Bool) {
        switch self {
            
        case .mostReviews:
            return ("totalReviewCount", true)
        case .harshestCritic:
            return ("averageStarsGiven", false)
        case .topSupporters:
            return ("averageStarsGiven", true)

        }
    }
}


