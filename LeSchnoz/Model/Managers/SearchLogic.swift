//
//  SearchLogic.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 5/20/23.
//

import SwiftUI

class SearchLogic: ObservableObject {
    static let instance = SearchLogic()
    
    
    @Published var placeSearchText = "" {
        willSet {
            self.performPlaceSearch(newValue)
        }
    }
    @Published var areaSearchText = "" {
        willSet {
            if newValue == "" {
                self.placeSearch()
            } else {
                self.performLocalitySearch(newValue)
            }
        }
    }
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
    
//    func performPlaceSearch(_ query: String) {
//
//        if isEditingSearchArea {
//            handleAreaSearch()
//        } else {
//            handlePlaceSearch()
//        }
//
//        func handlePlaceSearch() {
//            listResultsVM.searchType = nil
//            let currentCity = UserStore.instance.currentLocAsAddress?.city ?? ""
//            let currentState = UserStore.instance.currentLocAsAddress?.state ?? ""
//            let searchText = (areaSearchLocation == "" ? currentCity + " \(currentState)" : areaSearchLocation)
//            let queryText = searchText + " " + query
//            self.handleAutocompleteForQuery(queryText)
//        }
//
//        func handleAreaSearch() {
//            if areaSearchText == "" {
//                listResultsVM.schnozPlaces = []
//                self.handleNearby()
//            } else {
//                self.handleAutocompleteForQuery(self.areaSearchText)
//            }
//        }
//    }
    
    
    func performPlaceSearch(_ query: String) {
        
        isEditingSearchArea = false
        listResultsVM.schnozPlaces = []
        if query == "" {
            if areaSearchText == "" {
                self.handleNearby()
            } else {
                self.handleAutocompleteForQuery(self.areaSearchText)
            }
        } else {
            listResultsVM.searchType = nil
                let currentCity = UserStore.instance.currentLocAsAddress?.city ?? ""
                let currentState = UserStore.instance.currentLocAsAddress?.state ?? ""
                let searchText = (areaSearchLocation == "" ? currentCity + " \(currentState)" : areaSearchLocation)
                let queryText = searchText + " " + query
                self.handleAutocompleteForQuery(queryText)

        }
    }
    
    func performLocalitySearch(_ query: String) {
        if query != areaSearchLocation {
//            isEditingSearchArea = true
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
            isEditingSearchArea = false
            let text =  place.primaryText ?? ""
            self.areaSearchText = text
            self.areaSearchLocation = text
            self.performPlaceSearch(text)
        } else {
            if ldvm.selectedLocation != place {
                listResultsVM.resetPlaceImage()
                self.getImageForSelectedPlace(place)
                ldvm.selectedLocation = place
                listResultsVM.selectedPlace = place
                listResultsVM.searchBarTapped = false
            }
            ldvm.reviews = []
            self.listResultsVM.shouldShowPlaceDetails = true

        }
    }
    
    

}

