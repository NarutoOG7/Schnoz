//
//  FirebaseManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation
import GeoFire
import Firebase
import MapKit


class FirebaseManager: ObservableObject {
    
    let constantToNeverTouch: Void = FirebaseApp.configure()
    
    static let instance = FirebaseManager()
    
    @Published var favoriteLocations: [FavoriteLocation] = []
    
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userStore = UserStore.instance
    
    var db: Firestore?
    
    init() {
        db = Firestore.firestore()
    }
    

    func getSelectHotel(byID locID: String, withCompletion completion: @escaping(LocationModel) -> Void) {
        
        let ref = Database.database().reference().child("Haunted Hotels/\(locID)")
        
        ref.observe(.value) { snapshot in

            if let data = snapshot.value as? [String : AnyObject] {
                
                let locData = LocationData(data: data)
                
                var imageURLS: [URL] = []
                
                self.getLocationImages(locID: "\(locData.id)") { fsImage in
                    
                    if let url = URL(string: "\(fsImage.imageURL)") {
                        imageURLS.append(url)
                    }
                }
        
                let locModel = LocationModel(location: locData, imageURLs: imageURLS, reviews: [])
                
                completion(locModel)
                
            }
        }
    }
    
    func getHauntedHotels() {
        
        let ref = Database.database().reference().child("Haunted Hotels")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                
                self.locationStore.hauntedHotels.removeAll()
                
                if let objects = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    for object in objects {
                        
                        if let data = object.value as? [String : AnyObject] {
                            
                            let locData = LocationData(data: data)
                            
                            let locModel = LocationModel(location: locData, imageURLs: [], reviews: [])
                            
                            self.locationStore.hauntedHotels.append(locModel)
                            
                        }
                    }
                }
            }
        }
    }
 
    func getTrendingLocations(onError: @escaping(String) -> Void) {
        
        guard let db = db else { return }

        db.collection("Trending").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                
                print("Error getting documents: \(err)")
                onError("")
                
            } else {
                
                if let snapshot = querySnapshot {
                    
                    for document in snapshot.documents {
                        
                        let dict = document.data()
                        let key = dict["id"] as? Int ?? 0
                        
                        self.getHotelWithReviews("\(key)") { locModel in
                            
                            if !self.locationStore.trendingLocations.contains(locModel) {
                                
                                self.locationStore.trendingLocations.append(locModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getFeaturedLocations(onError: @escaping(String) -> Void) {
        
        guard let db = db else { return }

        db.collection("Featured").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                
                print("Error getting documents: \(err)")
                onError(err.localizedDescription)
                
            } else {
                
                if let snapshot = querySnapshot {
                    
                    for document in snapshot.documents {
                        
                        let dict = document.data()
                        let key = dict["id"] as? Int ?? 0

                        self.getHotelWithReviews("\(key)") { locModel in
                            
                            if !self.locationStore.featuredLocations.contains(locModel) {
                                
                                self.locationStore.featuredLocations.append(locModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Favorites
    
    func getFavorites(withCompletion completion: @escaping(FavoriteLocation) -> Void) {
                
        guard !userStore.isGuest else { return }
        
        guard let db = db else { return }

        db.collection("Favorites")
            .whereField("userID", isEqualTo: userStore.user.id)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else if let snapshot = snapshot {
                    
                    for doc in snapshot.documents {
                        
                        let dict = doc.data()
                        
                        let favLocation = FavoriteLocation(
                            id: dict["id"] as? String ?? "",
                            locationID: dict["locationID"] as? String ?? "",
                            userID: dict["userID"] as? String ?? "")
                        
                        completion(favLocation)
                    }
                }
            }
        
    }
    
    func addLocToFavoritesBucket(_ favLoc: FavoriteLocation, withCompletion completion: ((Bool) -> ())? = nil) {
        
        guard !userStore.isGuest else { return }
        
        guard let db = db else { return }

        db.collection("Favorites").document(favLoc.id).setData([
            "id" : favLoc.id,
            "locationID" : "\(favLoc.locationID)",
            "userID" : "\(favLoc.userID)"
            
        ]) { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                self.errorManager.message = "Check your network connection and try again."
                self.errorManager.shouldDisplay = true
                
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    func removeFavoriteFromBucket(_ favLoc: FavoriteLocation, withCompletion completion: ((Bool) -> ())? = nil) {
                
        guard let db = db else { return }

        db.collection("Favorites").document(favLoc.id)
            .delete() { err in
                
                if let err = err {
                    
                    print("Error removing favorite: \(err)")
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else {
                    print("Favorite successfully removed!")
                }
            }
    }
    //MARK: - Reviews
    func addReviewToFirestoreBucket(_ review: ReviewModel, location: LocationData, withcCompletion completion: @escaping (K.ErrorHelper.Messages.Review?) -> () = {_ in}) {
        
        guard let db = db else { return }
        
        let id = review.title + review.username + review.locationID
        
        db.collection("Reviews").document(id).setData([
            "id" : id,
            "userID" : userStore.user.id,
            "title" : review.title,
            "review" : review.review,
            "rating" : review.rating,
            "username" : review.username,
            "locationID" : "\(location.id)",
            "locationName" : location.name
            
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
        
        let id = review.title + review.username + review.locationID
        
        db.collection("Reviews").document(id)
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
        
        db.collection("Reviews").document(id)
            .updateData([
                "id" : id,
                "userID" : userStore.user.id,
                "title" : review.title,
                "review" : review.review,
                "rating" : review.rating,
                "username" : review.username,
                "locationID" : review.locationID,
                "locationName" : review.locationName
                
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
    
    func getReviewsForLocation(_ locationID: String, withCompletion completion: @escaping ([ReviewModel]) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("Reviews")
            .whereField("locationID", isEqualTo: locationID)
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
    
    func getAllReviews(withCompletion completion: @escaping(ReviewModel) -> (Void)) {
        
        guard let db = db else { return }

        db.collection("Reviews")
            .getDocuments { snapshot, error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else if let snapshot = snapshot {
                    
                    for doc in snapshot.documents {
                        
                        let dict = doc.data()
                        let review = ReviewModel(dictionary: dict)
                        
                        completion(review)
                    }
                }
            }
    }
    
    func getHotelWithReviews(_ locID: String, withCompletion completion: @escaping(LocationModel) -> Void) {
        
        getSelectHotel(byID: locID) { location in
            
            self.getReviewsForLocation(locID) { reviews in
                
                var newLoc = location
                newLoc.reviews = reviews
                
                completion(newLoc)
            }
        }
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
    
    //MARK: - Add Location to 'User Created Locations' Bucket
    
    func addUserCreatedLocationToBucket(_ loc: LocationData, _ image: UIImage?, withCompletion completion: @escaping (Error?) -> () = {_ in}) {
        
        let imageName = loc.name + UUID().uuidString
        
        if let image = image {
            
            uploadImageToFirebaseStorage(image, imageName: imageName) { error in
                
                if let error = error {
                    
                    print("Error saving image to firebase.: \(error)")
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                }
            }
        }
        
        guard let db = db else { return }
        
        let docID = userStore.user.name + " " + UUID().uuidString

        db.collection("UserCreatedLocations").document(docID).setData([
            "name" : loc.name,
            "street" : loc.address?.address as Any,
            "city" : loc.address?.city as Any,
            "state" : loc.address?.state as Any,
            "country" : loc.address?.country as Any,
            "zipCode" : loc.address?.zipCode as Any,
            "description" : loc.description as Any,
            "moreInfoLink" : loc.moreInfoLink as Any,
            "locationType" : loc.locationType as Any,
            "imageName" : image == nil ? "" : imageName
            
        ]) { error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    //MARK: - Images
    
    func uploadImageToFirebaseStorage(_ image: UIImage, imageName: String, withCompletion completion: @escaping (Error?) -> () = {_ in}) {
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference().child(imageName)
        
        let data = image.jpegData(compressionQuality: 0.2)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let data = data {
            
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                
                if let error = error {
                    print("error uploading file: \(error.localizedDescription)")
                    completion(error)
                }
                
                if let _ = metadata {
                    completion(nil)
                }
            }
        }
    }
    
    func getImageURLFromFBPath(_ urlString: String, withCompletion completion: @escaping ((_ url: URL) -> (Void))) {
        
        let storageRef = Storage.storage().reference().child(urlString)
        
        storageRef.downloadURL { url, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
                self.errorManager.message = "Check your network connection and try again."
                self.errorManager.shouldDisplay = true
            }
            
            guard let url = url else { return }
            
            completion(url)
        }
    }
    
    
    func getLocationImages(locID: String, withCompletion completion: @escaping(_ fsImage: FSImage) -> Void) {
        
        guard let db = db else { return }

        db.collection("Images")
        
            .whereField("locID", isEqualTo: locID)
        
            .getDocuments() { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                    self.errorManager.message = "Check your network connection and try again."
                    self.errorManager.shouldDisplay = true
                    
                } else {
                    
                    if let snapshot = querySnapshot {
                        
                        for document in snapshot.documents {
                            
                            let dict = document.data()
                            let image = FSImage(dict: dict)
                            
                            completion(image)
                        }
                    }
                }
            }
    }
    
    
    //MARK: - Search
    
    
    func searchByLocationName(text: String, withCompletion completion: @escaping(String) -> Void) {
           
           guard let db = db else { return }

        db.collection("Location Names")
            .whereField("name", isGreaterThanOrEqualTo: text)
            .whereField("name", isLessThanOrEqualTo: text + "/uf8ff")
            .getDocuments() { (querySnapshot, err) in
                
               if let err = err {
                   
                   print("Error getting documents: \(err)")
                   self.errorManager.message = "Check your network connection and try again."
                   self.errorManager.shouldDisplay = true
                   
               } else {
                   
                   if let snapshot = querySnapshot {
                       
                       for document in snapshot.documents {
                           
                           let dict = document.data()
                           let name = dict["name"] as? String ?? ""
                           
                           completion(name)
                       }
                   }
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
            
            print(loc)
            completion(loc)
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

