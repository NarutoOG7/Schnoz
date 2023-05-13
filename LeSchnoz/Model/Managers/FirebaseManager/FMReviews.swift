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
    
    func fetchLatestTenReviewsForLocation(_ placeID: String, withCompletion completion: @escaping ([ReviewModel]) -> (Void)) {
        
        guard let db = db else { return }
        
        let query = db.collection("Reviews")
            .whereField("locationID", isEqualTo: placeID)
            .order(by: "timestamp", descending: false)
//            .limit(to: 10)
                        
        query.getDocuments { (snapshot, error) in
            
            if let _ = error {
                
                self.errorManager.message = error?.localizedDescription ?? ""
                self.errorManager.shouldDisplay = true
                
            } else if let snapshot = snapshot {
                
                var reviews: [ReviewModel] = []
                
                for doc in snapshot.documents {
                    let dict = doc.data()
                    let review = ReviewModel(dictionary: dict)
                    reviews.append(review)
                }
                
                self.locationReviewsLastDocument = snapshot.documents.last
                completion(reviews)
            }
        }
    }
    
    func getNextPageOfLocationReviews(placeID: String, withCompletion completion: @escaping(ReviewModel) -> Void) {
        
        if let locationReviewsLastDocument = locationReviewsLastDocument {
            guard let db = db else { return }
            
            let collection = db.collection("Reviews")
                .whereField("locationID", isEqualTo: placeID)
                .limit(to: 10)
                .start(afterDocument: locationReviewsLastDocument)
            collection.getDocuments { snapshot, error in
                self.handleQuerySnapshot(snapshot, error, withCompletion: completion)
                guard let querySnapshot = snapshot else {

                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    return
                }
                for doc in querySnapshot.documents {
                    
                    let dict = doc.data()
                    
                    let review = ReviewModel(dictionary: dict)
                    self.locationReviewsLastDocument = doc
                    completion(review)
                    
                }
            }
        }
    }

    
    func getReviewsForLocation(_ placeID: String, withCompletion completion: @escaping ([ReviewModel]) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("Reviews")
            .whereField("locationID", isEqualTo: placeID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else if let snapshot = snapshot {
                    
                    var reviews: [ReviewModel] = []
                    
                    for doc in snapshot.documents {
                        let dict = doc.data()
                        let review = ReviewModel(dictionary: dict)
                        reviews.append(review)
                    }
                    
                    completion(reviews)
                }
            }
        
    }
}
