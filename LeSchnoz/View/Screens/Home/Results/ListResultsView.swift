//
//  ListResultsView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/12/23.
//

import SwiftUI
import GooglePlaces

struct ListResultsView: View {
    
    @Namespace var namespace
    
    @State private var placeSearchText = ""
    @State private var areaSearchText = ""
    @State private var areaSearchLocation = ""
    @State private var isEditingSearchArea = false
    
    @ObservedObject var googlePlacesManager: GooglePlacesManager
    @ObservedObject var listResultsVM: ListResultsVM
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        Group {
            if listResultsVM.shouldShowPlaceDetails {
                if let selectedPlace = listResultsVM.selectedPlace {
                    LD(location: selectedPlace)
//                    EmptyView()
                }
            } else {
                VStack {
                    HStack {
                        backButton
                        VStack(spacing: 4) {
                            searchField(title: "Bars, Restaraunts, Breweries, etc.", input: $placeSearchText)
                            
                            searchField(title: "Near Me", input: $areaSearchText)
                        }
                    }
                    list.overlay(listResultsVM.isLoading ? ProgressView() : nil)
                    
                }
                .padding(.top, 10)
                .padding(.horizontal)
                
                
                .onChange(of: placeSearchText) { newValue in
                    performPlaceSearch(newValue)
                }
                
                .onChange(of: areaSearchText) { newValue in
                    if newValue == "" {
                        self.areaSearchLocation = ""
                    } else {
                        performLocalitySearch(newValue)
                    }
                }
            }
        }
    
    }
        
    private var list: some View {
         VStack(alignment: .trailing) {
            List(listResultsVM.schnozPlaces) { place in
                
                Button {
                    cellTapped(place)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.primaryText ?? "")
                            Text(place.secondaryText ?? "")
                                .font(.caption)
                        }
                        singleStarReview(place)
                    }
                }
                .id(place.placeID)

            }.listStyle(.plain)
            Text("Powered by Google")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.vertical)
        }
            
    }
    
    
    //MARK: - Search Field
    private func searchField(title: String, input: Binding<String>) -> some View {
        TextField(title, text: input)
            .padding(.horizontal)
            .frame(height: 45)
            .background(
        RoundedRectangle(cornerRadius: 20)
            .fill(oceanBlue.lightBlue)
            .padding(2)

            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(oceanBlue.blue)))
            

    }
    
    
    private func singleStarReview(_ place: SchnozPlace) -> some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(oceanBlue.yellow)
            Text("\(place.averageRating?.avgRating ?? 0)")
                .foregroundColor(oceanBlue.yellow)
        }
        .opacity(place.averageRating == nil ? 0 : 1)
    }
    
    //MARK: - Buttons
    private var backButton: some View {
        Button(action: backTapped) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.black)
        }
        .matchedGeometryEffect(id: "search", in: namespace)
    }
    
    //MARK: - Methods
    
    private func cellTapped(_ place: SchnozPlace) {
        if isEditingSearchArea {
            let text =  place.primaryText ?? ""
            areaSearchText = text
            areaSearchLocation = text
            performPlaceSearch(text)
        } else {
            listResultsVM.shouldShowPlaceDetails = true
            listResultsVM.selectedPlace = place
        }
    }
    
    private func backTapped() {
        withAnimation {
            listResultsVM.showSearchTableView = false
            listResultsVM.schnozPlaces = []
        }
    }

    
    private func performLocalitySearch(_ query: String) {
        if query != areaSearchLocation {
            isEditingSearchArea = true
            googlePlacesManager.performAutocompleteQuery(query, isLocality: true) { results, error in
                if let error = error {
                    self.errorManager.message = error.localizedDescription
                    self.errorManager.shouldDisplay = true
                }
                if let results = results {
                    listResultsVM.schnozPlaces = results
                }
            }
        }
    }
    
    private func performPlaceSearch(_ query: String) {
        if placeSearchText == "" {
            if listResultsVM.nearbyPlaces.isEmpty {
                self.getNearby()
            } else {
                listResultsVM.schnozPlaces = listResultsVM.nearbyPlaces
            }
        } else {
            self.isEditingSearchArea = false
            listResultsVM.searchType = nil
            let currentCity = UserStore.instance.currentLocAsAddress?.city
            let searchText = (areaSearchLocation == "" ? currentCity : areaSearchLocation) ?? ""
            let queryText = searchText + " " + query
            googlePlacesManager.performAutocompleteQuery(queryText) { results, error in
                if let error = error {
                    self.errorManager.message = error.localizedDescription
                    self.errorManager.shouldDisplay = true
                }
                if let results = results {
                    listResultsVM.schnozPlaces = results
                }
            }
        }
    }
    
   private func getNearby() {
        NetworkServices.instance.getNearbyLocationsWithKeyword("food") { places, error in
            if let error = error {
                self.errorManager.message = error.localizedDescription
                self.errorManager.shouldDisplay = true
            }
            if let places = places {
                    listResultsVM.nearbyPlaces = places
                    listResultsVM.schnozPlaces = places
                listResultsVM.isLoading = false
            }
        }
    }
}

struct ListResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ListResultsView(googlePlacesManager: GooglePlacesManager(),
                        listResultsVM: ListResultsVM(),
                        userStore: UserStore(),
                        errorManager: ErrorManager())
    }
}
