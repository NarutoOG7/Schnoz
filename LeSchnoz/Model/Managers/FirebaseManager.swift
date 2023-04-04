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
    
    var db: Firestore?
    private var listener: ListenerRegistration?
    
    init() {
        db = Firestore.firestore()
    }
    
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

    //MARK: - Reviews
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
    
    func getReviewsForUser(_ user: User, withCompletion completion: @escaping(_ review: ReviewModel) -> Void) {
        
        guard let db = db else { return }

        db.collection("Reviews")
        
            .whereField("userID", isEqualTo: user.id)
        
            .getDocuments { querySnapshot, error in
                
                if let error = error {
                    
                    print("Error getting reviews: \(error.localizedDescription)")
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else {
                    
                    if let snapshot = querySnapshot {
                        
                        for doc in snapshot.documents {
                            
                            let dict = doc.data()
                            
                            let review = ReviewModel(dictionary: dict)
                            
                            completion(review)
                        }
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

