//
//  FirebaseManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import Firebase
import CoreLocation
import MapKit
import GooglePlaces
import Combine


class FirebaseManager: ObservableObject {
    
    let constantToNeverTouch: Void = FirebaseApp.configure()
    
    static let instance = FirebaseManager()
    
    @Published var latestReviewPublished = PassthroughSubject<DocumentSnapshot, Never>()
        
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var userStore = UserStore.instance
//    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    var db: Firestore?
    private var listener: ListenerRegistration?
    private var lastDocument: QueryDocumentSnapshot?
    private var userReviewsLastDocument: QueryDocumentSnapshot?

    
    init() {
        db = Firestore.firestore()
    }
    
    //MARK: - Latest Review
    
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
        
        let id = review.title + review.username + review.locationID
        
        db.collection("Reviews").document(id).setData([
            "id" : id,
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
    
    func updateReviewInFirestore(_ review: ReviewModel, forID id: String, withCompletion completion: @escaping(K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        let timestamp = FieldValue.serverTimestamp()
        
        db.collection("Reviews").document(id)
            .updateData([
                "id" : id,
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
            .limit(to: 10)
        
        collection.getDocuments { snapshot, error in
            self.handleQuerySnapshot(snapshot, error, withCompletion: completion)
        }
        

    }
    
    func getNextPageOfReviews(withCompletion completion: @escaping(ReviewModel) -> Void) {
        
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
        // use collectionGroup() to query for all reviews across all subcollection
        let countQuery = db.collection("Reviews").count
             countQuery.getAggregation(source: .server, completion: { snapshot, error in
                guard let snapshot = snapshot else {
                    return completion(nil, error)
                }
                completion(Int(truncating: snapshot.count), nil)
            })
    }
    
    //MARK: - Fetch Reviews For Location
    
    func fetchLatestTenReviewsForLocation(_ placeID: String, withCompletion completion: @escaping ([ReviewModel]) -> (Void)) {
        
        guard let db = db else { return }
        
        let query = db.collection("Reviews")
            .whereField("locationID", isEqualTo: placeID)
            .order(by: "timestamp", descending: false)
            .limit(to: 10)
                        
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
                completion(reviews)
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
    
    //MARK: - Average Rating
    
    func getAverageRatingForLocation(_ placeID: String, withCompletion completion: @escaping (AverageRating?) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("AverageRatings")
            .whereField("placeID", isEqualTo: placeID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                } else if let snapshot = snapshot {
                                        
                    guard let doc = snapshot.documents.first else { return completion(nil) }
                        let avgRating = AverageRating(dictionary: doc.data())
                        completion(avgRating)
                }
            }
    }
    
    
    func addAverageRating(_ averageRating: AverageRating, withcCompletion completion: @escaping (K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
                
        let data: [String:Any] = [ "id" : averageRating.id,
                       "avgRating" : averageRating.avgRating,
                       "totalStarCount" : averageRating.totalStarCount,
                       "numberOfReviews" : averageRating.numberOfReviews,
                       "placeID" : averageRating.placeID ]
        
        db.collection("AverageRatings").document(averageRating.id).setData(data, merge: true) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(.savingReview)
            } else {
                completion(nil)
            }
        }
    }

    
    //MARK: - Coordinates & Address
    
    func getCoordinatesFromAddress(address: String, withCompletion completion: @escaping (CLLocation) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            guard
                let placemarks = placemarks,
                let loc = placemarks.first?.location
            else {
                
                self.errorManager.message = "No location found."
                self.errorManager.shouldDisplay = true
                
                print("error on forward geocoding.. getting coordinates from location address: \(address)")
                
                return
            }
            
            var lat = loc.coordinate.latitude.rounded(.up)
            var lon = loc.coordinate.longitude.rounded(.up)
            let newLoc = CLLocation(latitude: lat, longitude: lon)
            
            print(loc)
            completion(newLoc)
        }
    }
    
    
    func getAddressFrom(coordinates: CLLocationCoordinate2D, withCompletion completion: @escaping ((_ address: Address) -> (Void))) {
        
        let location  = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            guard
                let placemarks = placemarks,
                let location = placemarks.first
            else {
                
                self.errorManager.message = "Could not get address from these coordinates."
                self.errorManager.shouldDisplay = true
                
                return
            }
            
            if let buildingNumber = location.subThoroughfare,
               let street = location.thoroughfare,
               let city = location.locality,
               let state = location.administrativeArea,
               let zip = location.postalCode,
               let country = location.country {
                
                let address = Address(
                    address: "\(buildingNumber) \(street)",
                    city: city,
                    state: state,
                    zipCode: zip,
                    country: country)
                completion(address)
            }
        }
    }
    
}

