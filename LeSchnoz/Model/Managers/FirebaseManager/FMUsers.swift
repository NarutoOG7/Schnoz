//
//  FMUsers.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 6/16/23.
//

import Foundation

struct FirestoreUser: Identifiable, Hashable {
    
    static let example = FirestoreUser(id: "1", username: "Spencer", reviewCount: 12, totalStarsGiven: 54, averageStarsGiven: 4.5)
    
    var id: String
    var username: String
    var reviewCount: Int?
    var totalStarsGiven: Int?
    var averageStarsGiven: Double?
    
    
    init(dict: [String:Any]) {
        self.id = dict["id"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.reviewCount = dict["totalReviewCount"] as? Int ?? 0
        self.totalStarsGiven = dict["totalStarsGiven"] as? Int ?? 0
        self.averageStarsGiven = dict["averageStarsGiven"] as? Double ?? 0
    }
    
    init(id: String = "", username: String = "", reviewCount: Int = 0, totalStarsGiven: Int = 0, averageStarsGiven: Double = 0) {
        self.id = id
        self.username = username
        self.reviewCount = reviewCount
        self.totalStarsGiven = totalStarsGiven
        self.averageStarsGiven = averageStarsGiven
    }
    
    
    init(user: User) {
        self.id = user.id
        self.username = user.name
        self.reviewCount = user.reviewCount
        self.totalStarsGiven = user.totalStarsGiven
        self.averageStarsGiven = user.averageStarsGiven
    }
    
    mutating func handleAdditionOfReview(_ review: ReviewModel) {
        self.totalStarsGiven? += review.rating
        self.reviewCount? += 1
        if let reviewCount = self.reviewCount,
           let starsCount = self.totalStarsGiven,
           reviewCount > 0 {
            self.averageStarsGiven? = Double(starsCount / reviewCount)
        }
    }
    
    mutating func handleUpdateOfReview(oldReview: ReviewModel, newReview: ReviewModel) {
        let starsDifference = newReview.rating - oldReview.rating
        self.totalStarsGiven? += starsDifference
        if let reviewCount = self.reviewCount,
           let starsCount = self.totalStarsGiven,
           reviewCount > 0 {
            self.averageStarsGiven? = Double(starsCount / reviewCount)
        }
    }
    
    mutating func handleRemovalOfReview(review: ReviewModel) {
        self.totalStarsGiven? -= review.rating
        self.reviewCount? -= 1
        if let reviewCount = self.reviewCount,
           let starsCount = self.totalStarsGiven,
           reviewCount > 0 {
            self.averageStarsGiven? = Double(starsCount / reviewCount)
        }
    }
    
}

extension FirebaseManager {
    
    func doesUserExist(id: String, _ exists: @escaping(Bool) -> Void) {
        
        guard let db = db else { exists(false)
            return }
        let usersCollection = db.collection("Users")
        
        usersCollection.whereField("id", isEqualTo: id).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username availability: \(error.localizedDescription)")
                exists(false)
            } else {
                let usernameExists = !snapshot!.isEmpty
                exists(usernameExists)
            }
        }
    }
    
    func addUserToFirestore(_ user: FirestoreUser, withcCompletion completion: @escaping(Error?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        db.collection("Users").document(user.id).setData([
            "id" : user.id,
            "username" : user.username,
            "totalStarsGiven" : user.totalStarsGiven ?? 0,
            "averageStarsGiven" : user.averageStarsGiven ?? 0,
            "totalReviewCount" : user.reviewCount ?? 0
            
        ]) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateFirestoreUser(_ user: FirestoreUser, withCompletion completion: @escaping(K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        
        guard let db = db else { return }
        
        db.collection("Users").document(user.id)
            .updateData([
                "id" : user.id,
                "username" : user.username,
                "totalStarsGiven" : user.totalStarsGiven ?? 0,
                "averageStarsGiven" : user.averageStarsGiven ?? 0,
                "totalReviewCount" : user.reviewCount ?? 0
                
            ], completion: { err in
                
                if let err = err {
                    print("Error updating review: \(err)")
                    completion(.updatingReview)
                } else {
                    print("User successfully updated!")
                    
                    let newUser = User(id: self.userStore.user.id,
                                       name: self.userStore.user.name,
                                       email: self.userStore.user.email,
                                       reviewCount: user.reviewCount ?? 0,
                                       totalStarsGiven: user.totalStarsGiven ?? 0,
                                       averageStarsGiven: user.averageStarsGiven ?? 0)
                    self.userStore.user = newUser
                    Authorization.instance.saveUserToUserDefaults(user: newUser) { error in
                        if let _ = error {
                            self.errorManager.shouldDisplay = true
                            self.errorManager.message = K.ErrorHelper.Messages.Auth.failedToSaveUser.rawValue
                        }
                    }
                    
                    completion(nil)
                }
            })
    }
    
    func batchFirstAllUsers(_ sortingOption: SniffersSortingOption, withCompletion completion: @escaping([FirestoreUser]?, Error?) -> Void) {
        let allSniffersVM = AllSniffersVM.instance
        guard let db = db else { return }
        
        let first = db.collection("Users")
        //            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .limit(to: 15)
        
        
        first.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retrieving reviews: \(error.debugDescription)")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            
            allSniffersVM.lastDocumentOfAllUsers = lastSnapshot
            var users: [FirestoreUser] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let user = FirestoreUser(dict: dict)
                print(user.id)
                users.append(user)
            }
            
            allSniffersVM.lastDocumentOfAllUsers = snapshot.documents.last
            allSniffersVM.isFetchInProgress = false
            completion(users, nil)
        }
    }
    
    func nextPageAllUsers(_ sortingOption: SniffersSortingOption, withCompletion completion: @escaping([FirestoreUser]?, Error?) -> Void) {
        let allSniffersVM = AllSniffersVM.instance
        guard let lastSnapshot = allSniffersVM.lastDocumentOfAllUsers,
              let db = db else {
            // No last snapshot available, so nothing to fetch.
            return
        }
        
        
        
        let pageSize: Int = 15
        let collectionRef = db.collection("Reviews")
        
        let nextQuery = collectionRef
        //            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .start(afterDocument: lastSnapshot)
            .limit(to: pageSize)
        
        nextQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retrieving next page of cities: \(error.debugDescription)")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // No more documents available.
                allSniffersVM.lastDocumentOfAllUsers = nil
                return
            }
            
            allSniffersVM.lastDocumentOfAllUsers = lastSnapshot
            
            var users: [FirestoreUser] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let user = FirestoreUser(dict: dict)
                users.append(user)
            }
            allSniffersVM.isFetchInProgress = false
            completion(users, nil)
        }
    }

}
