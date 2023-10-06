//
//  SearchLogic.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 5/20/23.
//

import SwiftUI

class SearchLogic: ObservableObject {
    static let instance = SearchLogic()
    
    
    @Published var placeSearchText = ""
    
    @Published var areaSearchText = ""
    @Published var areaSearchLocation = ""
    @Published var isEditingSearchArea = false
    
    @ObservedObject var listResultsVM = ListResultsVM.instance
    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var ldvm = LDVM.instance
    

    
    func handleNearby() {
        if listResultsVM.nearbyPlaces.isEmpty {
            self.getNearby()
        } else {
            listResultsVM.schnozPlaces = listResultsVM.nearbyPlaces
        }
    }
    
    func handleAutocompleteForQuery(_ query: String) {
        googlePlacesManager.performAutocompleteQuery(query) { results, error in
            if let error = error {
                self.errorManager.message = error.localizedDescription
                self.errorManager.shouldDisplay = true
            }
            if let results = results {
                self.listResultsVM.schnozPlaces = results
            }
        }
    }
    
    
    func getNearby() {
        NetworkServices.instance.getNearbyLocationsWithKeyword("food") { places, error in
            if let error = error {
                self.errorManager.message = error.localizedDescription
                self.errorManager.shouldDisplay = true
            }
            if let places = places {
                self.listResultsVM.nearbyPlaces = places
                self.listResultsVM.schnozPlaces = places
                self.listResultsVM.isLoading = false
            }
        }
    }
    

    
    
    func performPlaceSearch(_ query: String) {
        
        listResultsVM.schnozPlaces = []
        if query == "" {
            if areaSearchText == "" {
                self.handleNearby()
            } else {
                self.handleAutocompleteForQuery(self.areaSearchText)
            }
        } else {
            listResultsVM.searchType = nil
            self.handleAutocompleteForQuery(query)
        }
    }
    
    func performLocalitySearch(_ query: String) {
        if query != areaSearchLocation {
            googlePlacesManager.performAutocompleteQuery(query, isLocality: true) { results, error in
                if let error = error {
                    self.errorManager.message = error.localizedDescription
                    self.errorManager.shouldDisplay = true
                }
                if let results = results {
                    self.listResultsVM.schnozPlaces = results
                }
            }
        }
    }
    
    
    func getImageForSelectedPlace(_ place: SchnozPlace) {
        listResultsVM.getPlaceImage(place) { image, error in
            if let error = error {
                self.errorManager.message = error.localizedDescription
                self.errorManager.shouldDisplay = true
            }
            if let image = image {
                self.listResultsVM.placeImage = image
            }
        }
        self.listResultsVM.shouldShowPlaceDetails = true
        self.listResultsVM.selectedPlace = place
        LDVM.instance.selectedLocation = place
    }
    
    func placeSearch() {
        self.areaSearchLocation = ""
        if placeSearchText == "" {
            self.handleNearby()
        } else {
            self.handleAutocompleteForQuery(placeSearchText)
        }
    }
    
    func cellTapped(_ place: SchnozPlace) {
        
        if isEditingSearchArea {
            let primary =  place.primaryText ?? ""
            let secondary = place.secondaryText ?? ""
            let text = "\(primary) \(secondary)"
            self.areaSearchText = text
            self.areaSearchLocation = text
            isEditingSearchArea = false
            self.performPlaceSearch(text)
            
        } else {
            if ldvm.selectedLocation != place {
                listResultsVM.resetPlaceImage()
                self.getImageForSelectedPlace(place)
                ldvm.selectedLocation = place
                listResultsVM.selectedPlace = place
                listResultsVM.searchBarTapped = false
                ifNeededGrabGMSPlace()
            }
            ldvm.reviews = []
            self.listResultsVM.shouldShowPlaceDetails = true

        }
    }
    
    
    func ifNeededGrabGMSPlace() {
        if ldvm.isQuerySearching {
            GooglePlacesManager.instance.getPlaceDetails(ldvm.selectedLocation?.placeID ?? "") { gmsPlace, _ in
                if let gmsPlace = gmsPlace {
                    LDVM.instance.selectedLocation?.gmsPlace = gmsPlace
                }
            }
        }
    }
    

    func placeTextChanged(_ text: String) {
        self.performPlaceSearch(text)
        self.isEditingSearchArea = false
        LDVM.instance.isQuerySearching = true
    }
    
    func areaTextChanged(_ text: String) {
        self.isEditingSearchArea = true
        if text == "" {
            self.placeSearch()
        } else {
            self.performLocalitySearch(text)
        }
    }
    
}

