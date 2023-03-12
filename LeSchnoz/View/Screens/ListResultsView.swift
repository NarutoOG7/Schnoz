//
//  ListResultsView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/12/23.
//

import SwiftUI

struct ListResultsView: View {
    
    @State private var placeSearchText = ""
    @State private var areaSearchText = ""
    @State private var schnozPlaces: [SchnozPlace] = []
    
    var body: some View {
        VStack {
            searchField(title: "Bars, Restaraunts, Breweries, etc.", input: $placeSearchText)
            searchField(title: "Near Me", input: $areaSearchText)
            list
        }
        .onChange(of: placeSearchText) { newValue in
            GooglePlacesManager.instance.performAutocompleteQuery(newValue) { results, error in
                if let error = error {
                    // TODO: Handle Error
                }
                if let results = results {
                    self.schnozPlaces = results
                }
            }
        }
    }
    
    private var list: some View {
        List(schnozPlaces, id: \.self) { place in
            Text(place.primaryText ?? place.placeID)
        }
    }

    private func searchField(title: String, input: Binding<String>) -> some View {
        TextField(title, text: input)
    }
}

struct ListResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ListResultsView()
    }
}
