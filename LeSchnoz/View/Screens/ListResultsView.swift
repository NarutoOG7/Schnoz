//
//  ListResultsView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/12/23.
//

import SwiftUI
import GooglePlaces

enum SearchType: String, CaseIterable {
    case breakfast, lunch, dinner
    
    var field: GMSPlaceField {
        switch self {
        case .breakfast:
            return .servesBreakfast
        case .lunch:
            return .servesLunch
        case .dinner:
            return .servesDinner
        }
    }
    
    var image: Image {
        let images = K.Images.SearchTypes.self
        switch self {
        case .breakfast:
            return images.blueBreakfast
        case .lunch:
            return images.blueLunch
        case .dinner:
            return images.blueDinner
        }
    }
}

struct ListResultsView: View {
    
    @Namespace var namespace
    
    @State private var placeSearchText = ""
    @State private var areaSearchText = ""
    @State private var areaSearchLocation = ""
    @State private var isEditingSearchArea = false
    
    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var listResultsVM = ListResultsVM.instance
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        VStack {
            HStack {
                backButton
                VStack(spacing: 4) {
                    searchField(title: "Bars, Restaraunts, Breweries, etc.", input: $placeSearchText)
                        
                    searchField(title: "Near Me", input: $areaSearchText)
                }
            }
            list
        }
        .padding(.top, 10)
        .padding(.horizontal)
        
        .onChange(of: placeSearchText) { newValue in
            self.isEditingSearchArea = false
            listResultsVM.searchType = nil
            let currentCity = UserStore.instance.currentLocAsAddress?.city
            let searchText = (areaSearchLocation == "" ? currentCity : areaSearchLocation) ?? ""
            let queryText = searchText + " " + newValue
            googlePlacesManager.performAutocompleteQuery(queryText) { results, error in
                if let error = error {
                    // TODO: Handle Error
                }
                if let results = results {
                    listResultsVM.schnozPlaces = results
                }
            }
        }
        
        .onChange(of: areaSearchText) { newValue in
            isEditingSearchArea = true
            googlePlacesManager.performAutocompleteQuery(newValue, isLocality: true) { results, error in
                if let error = error {
                    // TODO: Handle Error
                }
                if let results = results {
                    listResultsVM.schnozPlaces = results
                }
            }
        }
    }
    
    private var list: some View {
        let _ = print(listResultsVM.schnozPlaces.forEach({ $0.primaryText }))
        let bfast = listResultsVM.schnozPlaces.filter({ (($0.gmsPlace?.servesBreakfast) != nil) == true })
        return VStack(alignment: .trailing) {
            List(listResultsVM.schnozPlaces) { place in
                Button(action: { cellTapped(text: place.primaryText ?? "")}) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(place.primaryText ?? "")
                        Text(place.secondaryText ?? "")
                            .font(.caption)
                    }
                }
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
    
    //MARK: - Buttons
    private var backButton: some View {
        Button(action: backTapped) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.black)
        }
    }
    
    //MARK: - Methods
    
    private func cellTapped(text: String) {
        if isEditingSearchArea {
            areaSearchText = text
        }
    }
    
    private func backTapped() {
        withAnimation {
            ExploreViewModel.instance.showSearchTableView = false
        }
    }
    
}

struct ListResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ListResultsView()
    }
}

class ListResultsVM: ObservableObject {
    static let instance = ListResultsVM()
    
    @Published var searchRegion = ""
    @Published var searchType: SearchType?
    @Published var schnozPlaces: [SchnozPlace] = []

    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance

}
