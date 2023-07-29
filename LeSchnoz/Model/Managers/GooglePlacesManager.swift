//
//  GooglePlacesManager.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/14/23.
//

import SwiftUI
import GooglePlaces
import GoogleMaps

class GooglePlacesManager: ObservableObject {
    
    static let instance = GooglePlacesManager()
        
    @Published var error: Error?
    @Published var predictions: [GMSAutocompletePrediction]?
    
    @Published var nearbyPlaces: [GMSPlaceLikelihood] = []
    
    private let placesClient: GMSPlacesClient
    private var autocompleteSessionToken: GMSAutocompleteSessionToken?
    private var keys: NSDictionary?
    
    init() {
        if let path = Bundle.main.path(forResource: K.GhostKeys.file, ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            
            
            if let placesAPI = dict["placesAPIKey"] as? String {
                print(placesAPI)
                GMSPlacesClient.provideAPIKey(placesAPI)
            }
        }
        placesClient = GMSPlacesClient.shared()
        refreshToken()
    }
    
    
    func getNearbyLocation(withCompletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
        
        let placeFields: GMSPlaceField = [.name, .formattedAddress]
        let group = DispatchGroup()

        group.enter()
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (results, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                strongSelf.error = error
            }
            
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                    let schnozPlace = SchnozPlace(placeID: result.place.placeID ?? "")
                    schnozPlace.primaryText = result.place.name
                    schnozPlace.secondaryText = result.place.formattedAddress
                    group.enter()
                    FirebaseManager.instance.getAverageRatingForLocation(result.place.placeID ?? "") { averageRating in
                        schnozPlace.averageRating = averageRating
                    
//                    FirebaseManager.instance.getReviewsForLocation(result.place.placeID ?? "") { reviews in
//                        schnozPlace.schnozReviews = reviews
                        group.leave()
                    }
                    schnozResults.append(schnozPlace)
                }
                group.notify(queue: .main) {
                    completion(schnozResults, nil)
                }
            }
            
        }
    }
    
    func autoFilter() -> GMSAutocompleteFilter {
        let filter = GMSAutocompleteFilter()
        
        filter.types = ["food", "bar", "bowling_alley", "movie_theater"]
        
        return filter
    }
    
    
    
    func refreshToken() {
        self.autocompleteSessionToken = GMSAutocompleteSessionToken()
    }
    
    //MARK: - Filters
    func localityFilter() -> GMSAutocompleteFilter {
        let newFilter = GMSAutocompleteFilter()
        newFilter.types = ["locality"]
        return newFilter
    }
    
    //MARK: - Queries
    
    func performAutocompleteQuery(_ query: String, isLocality: Bool = false, withCompletion completion: @escaping ([SchnozPlace]?, Error?) -> Void) {
        
        //        autoFilter { autoFilter in
        let group = DispatchGroup()
        
        let filter = isLocality ? self.localityFilter() : autoFilter()
        self.placesClient.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: self.autocompleteSessionToken)
        { results, error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                    
                    let schnozPlace = SchnozPlace(placeID: result.placeID)
                    schnozPlace.primaryText = result.attributedPrimaryText.string
                    schnozPlace.secondaryText = result.attributedSecondaryText?.string
                    schnozPlace.placeID = result.placeID
                    group.enter()
                    FirebaseManager.instance.getAverageRatingForLocation(result.placeID) { averageRating in
                        schnozPlace.averageRating = averageRating
//                    FirebaseManager.instance.getReviewsForLocation(result.placeID) { reviews in
//                        schnozPlace.schnozReviews = reviews
                        group.leave()
                    }
                    
//                    group.enter()
//                    self.getPlaceDetails(result.placeID) { gmsPlace, error in
//                        if let gmsPlace = gmsPlace {
//                            schnozPlace.gmsPlace = gmsPlace
//                        }
//                        group.leave()
//                    }
                    
                    schnozResults.append(schnozPlace)
                }
                group.notify(queue: .main) {
                    completion(schnozResults, nil)
                }
            }
        }
        
        //        }
    }
    
    func getMealType(searchType: SearchType, withCopletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.types = ["servesBreakfast"]
    
        self.placesClient.findAutocompletePredictions(fromQuery: "Fort Collins", filter: filter, sessionToken: autocompleteSessionToken) { results, error in
            
            
            //        self.placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: .all) { results, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                    
                    let schnozPlace = SchnozPlace(placeID: result.placeID)
                    //                    schnozPlace.gmsPlace = result.place
                    schnozPlace.primaryText = result.attributedPrimaryText.string
                    FirebaseManager.instance.getAverageRatingForLocation(schnozPlace.placeID) { avgRating in
                        schnozPlace.averageRating = avgRating
                    }
//                    FirebaseManager.instance.getReviewsForLocation(schnozPlace.placeID) { reviews in
//                        schnozPlace.schnozReviews = reviews
//                    }
                    schnozResults.append(schnozPlace)
                }
                completion(schnozResults, nil)
            }
        }
    }
    
    
//    func getPlaceFromID(_ placeID: String, withCompletion completion: @escaping(GMSPlace?, Error?) -> Void) {
//
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue)))
//
//        self.placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
//            (place: GMSPlace?, error: Error?) in
//            if let error = error {
//                print(error.localizedDescription)
//                completion(nil, error)
//            }
//            if let place = place {
//                completion(place, nil)
//            }
//        })
//    }
    
    func getPlaceDetails(_ placeID: String, withCompletion completion: @escaping(GMSPlace?, Error?) -> Void) {
        self.placesClient.lookUpPlaceID(placeID) { place, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            if let place = place {
                completion(place, nil)
            }
        }
    }
    
    func getPhotoForPlaceID(_ placeID: String, withCompletion completion: @escaping(UIImage?, Error?) -> Void) {
        
        self.placesClient.lookUpPlaceID(placeID) { (place, error) in
            guard let place = place, error == nil else {
                completion(nil, error)
                return
            }
            // Get the first photo reference for the place.
            guard let photoMetadata = place.photos?.first else {
                completion(nil, error)
                return
            }
//             Download the actual image data.
            self.placesClient.loadPlacePhoto(photoMetadata) { (photo, error) in
                guard let photo = photo, error == nil else {
                    completion(nil, error)
                    return
                }

                completion(photo, nil)
            }
        }

    }
}

