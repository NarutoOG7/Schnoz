//
//  AllSniffersVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/24/23.
//

import SwiftUI
import Firebase

class AllSniffersVM: ObservableObject {
    static let instance = AllSniffersVM()
    
    @ObservedObject var firebaseManager = FirebaseManager.instance

    
    @Published var users: [FirestoreUser] = []
    @Published var isFetchInProgress = false
    @Published var lastDocumentOfAllUsers: DocumentSnapshot?
    @Published var errorMessage = ""
    @Published var shouldShowError = false

    @Published var sortingOption: SniffersSortingOption = .mostReviews {
        didSet {
            if oldValue != sortingOption {
                self.users = []
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
        DispatchQueue.main.async {
            if let users = users {
                for user in users {
                    self.users.append(user)
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

enum SniffersSortingOption: String {
    case mostReviews = "Most Reviews"
    case harshestCritic = "Harshest Critics"
    case topSupporters = "Top Supporters"
    
    var sortingQuery: (query: String, descending: Bool) {
        switch self {
            
        case .mostReviews:
            return ("reviewCount", true)
        case .harshestCritic:
            return ("averageStarsGiven", false)
        case .topSupporters:
            return ("averageStarsGiven", true)

        }
    }
}

