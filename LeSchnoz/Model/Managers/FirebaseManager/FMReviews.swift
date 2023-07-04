//
//  FMReviews.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/28/23.
//

import Foundation
import GooglePlaces
import Combine
import Firebase
import CoreLocation
import MapKit

extension FirebaseManager {
    
    //MARK: - Reviews
    
    func stopListeningForLatestReview() {
        listener?.remove()
        listener = nil
    }
    
    func getLatestReview(withCompletion completion: @escaping(ReviewModel?, Error?) -> Void) {
        
        if userStore.isSignedIn {
            
            guard let db = db else { return }
            
            let query = db.collection("Reviews")
                .order(by: "timestamp",
                       descending: true)
                .limit(to: 1)
            listener = query
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil, error)
                    }
                    if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            let dict = doc.data()
                            let review = ReviewModel(dictionary: dict)
                            completion(review, nil)
                        }
                    }
                }
        }
        
    }
    
    //MARK: - Add Remove Update
    
    func addReviewToFirestoreBucket(_ review: ReviewModel, location: SchnozPlace, withcCompletion completion: @escaping (K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        let timestamp = FieldValue.serverTimestamp()
        
        //        let id = review.title + review.username + review.locationID
        
        db.collection("Reviews").document(review.id).setData([
            "id" : review.id,
            "userID" : userStore.user.id,
            "title" : review.title,
            "review" : review.review,
            "rating" : review.rating,
            "username" : review.username,
            "locationID" : location.placeID,
            "locationName" : location.primaryText ?? "",
            "timestamp" : timestamp
            
        ]) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(.savingReview)
            } else {
                completion(nil)
            }
        }
    }
    
    func removeReviewFromFirestore(_ review: ReviewModel, withCompletion completion: @escaping(Error?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        db.collection("Reviews").document(review.id)
            .delete() { err in
                
                if let err = err {
                    
                    print("Error removing review: \(err)")
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    completion(err)
                    
                } else {
                    print("Review successfully removed!")
                    completion(nil)
                }
            }
    }
    
    func updateReviewInFirestore(_ review: ReviewModel, withCompletion completion: @escaping(K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        print("review: \(review.review), id: \(review.id), placeID: \(review.locationID), placeName: \(review.locationName), rating: \(review.rating), title: \(review.title)")
        
        guard let db = db else { return }
        
        let timestamp = FieldValue.serverTimestamp()
        
        db.collection("Reviews").document(review.id)
            .updateData([
                "id" : review.id,
                "userID" : userStore.user.id,
                "title" : review.title,
                "review" : review.review,
                "rating" : review.rating,
                "username" : review.username,
                "locationID" : review.locationID,
                "locationName" : review.locationName,
                "timestamp" : timestamp
                
            ], completion: { err in
                
                if let err = err {
                    print("Error updating review: \(err)")
                    completion(.updatingReview)
                } else {
                    print("Review successfully updated!")
                    completion(nil)
                }
            })
    }
    
    //MARK: - Fetch Reviews For User
    
    func handleQuerySnapshot(_ querySnapshot: QuerySnapshot?, _ error: Error?, withCompletion completion: @escaping(ReviewModel) -> Void) -> Void {
        
        guard let querySnapshot = querySnapshot else {
            
            self.errorManager.message = "Check your network connection and try again."
            self.errorManager.shouldDisplay = true
            return
        }
        for doc in querySnapshot.documents {
            
            let dict = doc.data()
            
            let review = ReviewModel(dictionary: dict)
            self.userReviewsLastDocument = doc
            completion(review)
            
        }
    }
    
    func getReviewsForUser(_ user: User, withCompletion completion: @escaping(_ review: ReviewModel) -> Void) {
        
        guard let db = db else { return }
        
        let collection = db.collection("Reviews")
            .whereField("userID", isEqualTo: user.id)
            .order(by: "timestamp", descending: false)
        //            .limit(to: 10)
        
        collection.getDocuments { snapshot, error in
            self.handleQuerySnapshot(snapshot, error, withCompletion: completion)
        }
        
        
    }
    
    func getNextPageOfUserReviews(withCompletion completion: @escaping(ReviewModel) -> Void) {
        
        if let userReviewsLastDocument = userReviewsLastDocument {
            guard let db = db else { return }
            
            let collection = db.collection("Reviews")
                .whereField("userID", isEqualTo: userStore.user.id)
                .order(by: "timestamp", descending: false)
                .limit(to: 10)
            
            collection.start(atDocument: userReviewsLastDocument)
            collection.getDocuments { snapshot, error in
                self.handleQuerySnapshot(snapshot, error, withCompletion: completion)
            }
        }
    }
    
    
    
    func fetchTotalUserReviewsCount(withCompletion completion: @escaping(Int?, Error?) -> Void) {
        
        guard let db = db else { return }
        let countQuery = db.collection("Reviews").whereField("userID", isEqualTo: userStore.user.id).count
        countQuery.getAggregation(source: .server, completion: { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(nil, error)
            }
            completion(Int(truncating: snapshot.count), nil)
        })
    }
    
    //MARK: - Fetch Reviews For Location
    
    func fetchTotalLocationReviewsCount(placeID: String, withCompletion completion: @escaping(Int?, Error?) -> Void) {
        
        guard let db = db else { return }
        let countQuery = db.collection("Reviews").whereField("locationID", isEqualTo: placeID).count
        countQuery.getAggregation(source: .server) { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(nil, error)
            }
            completion(Int(truncating: snapshot.count), nil)
        }
    }
    
    
    //MARK: - Location Reviews Feed
    
    func batchFirstLocationsReviews(location: SchnozPlace, _ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let ldvm = LDVM.instance
        guard let db = db else { return }
        
        let first = db.collection("Reviews")
            .whereField("locationID", isEqualTo: location.placeID)
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .limit(to: 15)
        
        first.addSnapshotListener { snapshot, error in
            
            guard let snapshot = snapshot else {
                print("Error retrieving reviews: \(error.debugDescription)")
                completion(nil, error)
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            ldvm.lastDocumentOfLocationReviews = lastSnapshot
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            
            ldvm.lastDocumentOfLocationReviews = snapshot.documents.last
            ldvm.isFetchInProgress = false
            completion(reviews, nil)
        }
    }
    
    func nextPageLocationsReviews(location: SchnozPlace, _ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let ldvm = LDVM.instance
        guard let lastSnapshot = ldvm.lastDocumentOfLocationReviews,
              let db = db else {
            // No last snapshot available, so nothing to fetch.
            return
        }
        
        let nextQuery = db.collection("Reviews")
            .whereField("locationID", isEqualTo: location.placeID)
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .start(afterDocument: lastSnapshot)
            .limit(to: 15)
        
        nextQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retrieving next page of cities: \(error.debugDescription)")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // No more documents available.
                ldvm.lastDocumentOfLocationReviews = nil
                return
            }
            
            ldvm.lastDocumentOfLocationReviews = lastSnapshot
            
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            ldvm.isFetchInProgress = false
            completion(reviews, nil)
        }
    }
    
    
  
    
    //MARK: - News Feed
    
    func batchFirstAllUsersReviews(_ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let newsFeedVM = NewsFeedVM.instance
        guard let db = db else { return }
        
        let first = db.collection("Reviews")
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
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
            
            newsFeedVM.lastDocumentOfAllReviewsBatchRequest = lastSnapshot
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            
            
            print(reviews.count)
            newsFeedVM.lastDocumentOfAllReviewsBatchRequest = snapshot.documents.last
            newsFeedVM.isFetchInProgress = false
            completion(reviews, nil)
        }
    }
    
    func nextPageAllUsersReviews(_ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let newsFeedVM = NewsFeedVM.instance
        guard let lastSnapshot = newsFeedVM.lastDocumentOfAllReviewsBatchRequest,
              let db = db else {
            // No last snapshot available, so nothing to fetch.
            return
        }
        
        
        
        let pageSize: Int = 15
        let collectionRef = db.collection("Reviews")
        
        let nextQuery = collectionRef
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .start(afterDocument: lastSnapshot)
            .limit(to: pageSize)
        
        nextQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retrieving next page of cities: \(error.debugDescription)")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // No more documents available.
                newsFeedVM.lastDocumentOfAllReviewsBatchRequest = nil
                return
            }
            
            newsFeedVM.lastDocumentOfAllReviewsBatchRequest = lastSnapshot
            
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            
            print(reviews.count)
            newsFeedVM.isFetchInProgress = false
            completion(reviews, nil)
        }
    }

    //MARK: - User's Feed
    
    func batchFirstUsersReviews(user: FirestoreUser, _ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let userDetailsVM = UserDetailsVM.instance
        guard let db = db else { return }
        
        let first = db.collection("Reviews")
            .whereField("userID", isEqualTo: user.id)
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .limit(to: 15)
        
        first.addSnapshotListener { snapshot, error in
            
            guard let snapshot = snapshot else {
                print("Error retrieving reviews: \(error.debugDescription)")
                completion(nil, error)
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            userDetailsVM.lastDocumentOfUsersReviews = lastSnapshot
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            
            userDetailsVM.lastDocumentOfUsersReviews = snapshot.documents.last
            userDetailsVM.isFetchInProgress = false
            completion(reviews, nil)
        }
    }
    
    func nextPageUsersReviews(user: FirestoreUser, _ sortingOption: ReviewSortingOption, withCompletion completion: @escaping([ReviewModel]?, Error?) -> Void) {
        let userDetailsVM = UserDetailsVM.instance
        guard let lastSnapshot = userDetailsVM.lastDocumentOfUsersReviews,
              let db = db else {
            // No last snapshot available, so nothing to fetch.
            return
        }
        
        let nextQuery = db.collection("Reviews")
            .whereField("userID", isEqualTo: user.id)
            .order(by: sortingOption.sortingQuery.query, descending: sortingOption.sortingQuery.descending)
            .start(afterDocument: lastSnapshot)
            .limit(to: 15)
        
        nextQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retrieving next page of cities: \(error.debugDescription)")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // No more documents available.
                userDetailsVM.lastDocumentOfUsersReviews = nil
                return
            }
            
            userDetailsVM.lastDocumentOfUsersReviews = lastSnapshot
            
            var reviews: [ReviewModel] = []
            
            for doc in snapshot.documents {
                let dict = doc.data()
                let review = ReviewModel(dictionary: dict)
                reviews.append(review)
            }
            userDetailsVM.isFetchInProgress = false
            completion(reviews, nil)
        }
    }
    
}

