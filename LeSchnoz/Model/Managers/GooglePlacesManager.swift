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
    
    
    func getClosestEstablishment(withCompletion completion: @escaping(SchnozPlace?, Error?) -> Void) {
        
        if let currentLocation = UserStore.instance.currentLocation {
            
            placesClient
                .currentPlace(callback: { likelihoodList, error in
                    if let error = error {
                        completion(nil, error)
                    }
                    
                    guard
                        let list = likelihoodList?.likelihoods,
                        let first = list.first,
                        let _ = first.place.types?.contains("restaurant")
                            
                    else {
                        completion(nil, NSError(domain: "Proximity", code: 0))
                        return
                    }
                    let establishmentLocation = CLLocation(latitude: first.place.coordinate.latitude, longitude: first.place.coordinate.longitude)
                    let distance = currentLocation.distance(from: establishmentLocation)
                    
                    if distance < 100 {
                        let schnozPlace = SchnozPlace(placeID: first.place.placeID ?? "")
                        schnozPlace.primaryText = first.place.name
                        schnozPlace.secondaryText = first.place.formattedAddress
                        FirebaseManager.instance.getAverageRatingForLocation(first.place.placeID ?? "") { averageRating in
                            schnozPlace.averageRating = averageRating
                            completion(schnozPlace, nil)
                        }
                    }
                    
                })
        }
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
    
//    func getNearbyLocation(withCompletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
//        
//        let placeFields: GMSPlaceField = [.name, .formattedAddress]
//
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (results, error) in
//            
//            guard let strongSelf = self else { return }
//            
//            if let error = error {
//                print(error.localizedDescription)
//                strongSelf.error = error
//            }
//            
//            var schnozResults = [SchnozPlace]()
//            if let results = results {
//                for result in results {
//                    SchnozPlace.makeSchnozPlace(result) { schnozPlace in
//                        if let schnozPlace = schnozPlace {
//                            schnozResults.append(schnozPlace)
//                        }
//                    }
//                }
//            }
//            completion(schnozResults, nil)
//            
//        }
//    }
    
    func autoFilter() -> GMSAutocompleteFilter {
        let filter = GMSAutocompleteFilter()
        
//        filter.types = ["food", "bar", "bowling_alley", "movie_theater", "point_of_interest"]
///        meal_takeaway
        ///
        filter.types = ["establishment"]
        
///        "point_of_interest"
///        establishment
//        filter.types = ["food"]
//                        "bar",
//                        "bowling_alley",
//                        "amusement_park",
//                        "movie_theater"]
        
        
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
        
        let group = DispatchGroup()
        
        let filter = isLocality ? self.localityFilter() : autoFilter()
        let q = isLocality ? query :  query
        self.placesClient.findAutocompletePredictions(
            fromQuery: q,
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
    
//    func performAutocompleteQuery(_ query: String, isLocality: Bool = false, withCompletion completion: @escaping ([SchnozPlace]?, Error?) -> Void) {
//        
//        let filter = isLocality ? self.localityFilter() : autoFilter()
//        let q = isLocality ? query :  query
//        self.placesClient.findAutocompletePredictions(
//            fromQuery: q,
//            filter: filter,
//            sessionToken: self.autocompleteSessionToken)
//        { results, error in
//            
//            if let error = error {
//                print(error.localizedDescription)
//                completion(nil, error)
//            }
//            
//            var schnozResults = [SchnozPlace]()
//            if let results = results {
//                for result in results {
//                    
//                    SchnozPlace.makeSchnozPlace(result) { schnozPlace in
//                        if let schnozPlace = schnozPlace {
//                            schnozResults.append(schnozPlace)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func getSchnozPlaceFromLocationID(_ locationID: String,
                                      withCompletion completion: @escaping(SchnozPlace?, Error?) -> Void) {
        let schnozPlace = SchnozPlace(placeID: locationID)
        
        self.getPlaceDetails(locationID) { gmsPlace, error in
            if let gmsPlace = gmsPlace {
                schnozPlace.gmsPlace = gmsPlace
                completion(schnozPlace, nil)
            }
            if let error = error {
                completion(nil, error)
            }
        }
    }
    
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

