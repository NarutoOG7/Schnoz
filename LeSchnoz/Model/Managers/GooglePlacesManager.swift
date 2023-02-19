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
    
    
    init() {
        placesClient = GMSPlacesClient.shared()
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
    
}
