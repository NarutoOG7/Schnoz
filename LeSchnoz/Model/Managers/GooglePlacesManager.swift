//
//  GooglePlacesManager.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/14/23.
//

import SwiftUI
import GooglePlaces

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
    
    
    func getBreakfast() {
        
    }
    
    func getNearbyLocation() {
        
        let placeFields: GMSPlaceField = [.name, .formattedAddress]
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.error = error
            }
            
            if let places = placeLikelihoods {
                for place in places {
                        strongSelf.nearbyPlaces.append(place)
                    
                }
            }
        }
    }
 
    func filter() -> GMSAutocompleteFilter {
        let filter = GMSAutocompleteFilter()
        filter.types = ["food", "bar", "bowling_alley", "movie_theater"]
        return filter
    }
    
    func refreshToken() {
        self.autocompleteSessionToken = GMSAutocompleteSessionToken()
    }
    
    func performAutocompleteQuery(_ query: String, withCompletion completion: @escaping ([SchnozPlace]?, Error?) -> Void) {
        
//        autocompleteSessionToken = GMSAutocompleteSessionToken()
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter(), sessionToken: autocompleteSessionToken) { results, error in
            
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
    }
}

