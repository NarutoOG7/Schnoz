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
    
    @ObservedObject var exploreVM = ExploreViewModel.instance
    
    @Published var error: Error?
    @Published var predictions: [GMSAutocompletePrediction]?
    
    @Published var nearbyPlaces: [GMSPlaceLikelihood] = []
    
    private let placesClient: GMSPlacesClient
    private var autocompleteSessionToken: GMSAutocompleteSessionToken?
    
    
    init() {
        placesClient = GMSPlacesClient.shared()
        refreshToken()
    }
    
    func getNearbyLocation(withCompletion completion: @escaping([SchnozPlace]?, Error?) -> Void) {
        
        let placeFields: GMSPlaceField = [.name, .formattedAddress]
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (results, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.error = error
            }
            
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                    let schnozPlace = SchnozPlace(placeID: result.place.placeID ?? "")
                    schnozPlace.primaryText = result.place.name
                    schnozPlace.secondaryText = result.place.formattedAddress
                    FirebaseManager.instance.getReviewsForLocation(result.place.placeID ?? "") { reviews in
                        schnozPlace.schnozReviews = reviews
                    }
                    schnozResults.append(schnozPlace)
                }
                completion(schnozResults, nil)
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
        
        let filter = isLocality ? self.localityFilter() : autoFilter()
        
        self.placesClient.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: self.autocompleteSessionToken)
        { results, error in
            
            if let error = error {
                // TODO: Verify error handling
                //                let errorManager = ErrorManager.instance
                //                errorManager.message = error.localizedDescription
                //                errorManager.shouldDisplay = true
                completion(nil, error)
            }
            
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                    
                    let schnozPlace = SchnozPlace(placeID: result.placeID)
                    schnozPlace.primaryText = result.attributedPrimaryText.string
                    schnozPlace.secondaryText = result.attributedSecondaryText?.string
                    schnozPlace.placeID = result.placeID
                    FirebaseManager.instance.getReviewsForLocation(result.placeID) { reviews in
                        schnozPlace.schnozReviews = reviews
                    }
                    schnozResults.append(schnozPlace)
                }
                completion(schnozResults, nil)
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
                // TODO: Handle Error
                print(error.localizedDescription)
                completion(nil, error)
            }
            var schnozResults = [SchnozPlace]()
            if let results = results {
                for result in results {
                                        
                    let schnozPlace = SchnozPlace(placeID: result.placeID)
//                    schnozPlace.gmsPlace = result.place
                    schnozPlace.primaryText = result.attributedPrimaryText.string
                    FirebaseManager.instance.getReviewsForLocation(schnozPlace.placeID) { reviews in
                        schnozPlace.schnozReviews = reviews
                    }
                    schnozResults.append(schnozPlace)
                }
                completion(schnozResults, nil)
            }
        }
    }
    
}

