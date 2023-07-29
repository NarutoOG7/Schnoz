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
    
    @FocusState private var focusedField: Field?

    
//    
//    @State private var placeSearchText = ""
//    @State private var areaSearchText = ""
//    @State private var areaSearchLocation = ""
//    @State private var isEditingSearchArea = false
    
    @ObservedObject var searchLogic = SearchLogic.instance
    @ObservedObject var googlePlacesManager: GooglePlacesManager
    @ObservedObject var listResultsVM: ListResultsVM
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    
    @Environment(\.colorScheme) var colorScheme
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        Group {
                VStack {
                    HStack {
                        backButton
                        VStack(spacing: 4) {
                            placesSearchField
                            areaSearchField

                        }
                    }
                    list.overlay(listResultsVM.isLoading ? ProgressView() : nil)
                    
                }
                .padding(.top, 10)
                .padding(.horizontal)
                .navigationBarHidden(true)
                
                .fullScreenCover(isPresented: $listResultsVM.shouldShowPlaceDetails ) {
                    LD()
                }
                
                .onChange(of: searchLogic.placeSearchText) { newValue in
                    searchLogic.performPlaceSearch(newValue)
                }
                
                .onChange(of: searchLogic.areaSearchText) { newValue in
                    if newValue == "" {
                        searchLogic.placeSearch()
                    } else {
                        searchLogic.performLocalitySearch(newValue)
                    }
                }
            }
        .onAppear {
            if listResultsVM.searchBarTapped {
                self.focusedField = .place
            }
        }
    }
    
    private var placesSearchField: some View {
                
        searchField(.place, input: $searchLogic.placeSearchText)
            .onTapGesture {
                searchLogic.isEditingSearchArea = false
            }
            .focused($focusedField, equals: .place)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Text("") // To Space out the Cancel Button
                }
            }
    }
    
    private var areaSearchField: some View {
        
        searchField(.area, input: $searchLogic.areaSearchText)
            .onTapGesture {
                searchLogic.isEditingSearchArea = true
            }
            .focused($focusedField, equals: .area)

            .toolbar {
                
                ToolbarItem(placement: .keyboard) {
                        Button(action: keyboardCancelTapped) {
                            Text("Cancel")
                                .foregroundColor(oceanBlue.lightBlue)
                        }
                    }

            }
    }
        
    private var list: some View {
         VStack(alignment: .trailing) {
            List(listResultsVM.schnozPlaces) { place in
//             List([SchnozPlace.example]) { place in
                
                Button {
//                    if searchLogic.isEditingSearchArea {
//                        focusedField = .place
//                    }
                    searchLogic.cellTapped(place)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(place.primaryText ?? "")
                            Text(place.secondaryText ?? "")
                                .font(.caption)
                        }
                        Spacer()
                        if place.averageRating != nil {
                            singleStarReview(place)
                        }
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
    private func searchField(_ field: Field, input: Binding<String>) -> some View {
        let fieldIsFocused = field == focusedField
        let hasCharacters: Bool = input.wrappedValue.count > 0
return  ZStack {
            
            TextField("", text: input)
                .padding(.horizontal)
                .frame(height: 45)
                .foregroundColor(oceanBlue.black)
                .tint(oceanBlue.black)
                .placeholder(when: input.wrappedValue.isEmpty, placeholder: {
                    Text(field.title)
                        .foregroundColor(oceanBlue.black.opacity(0.7))
                        .padding(.horizontal)
                })
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(oceanBlue.white)
                        .padding(2)
                    
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(oceanBlue.black))
                )
            
            HStack {
                Spacer()
                
                Button {
                    if self.focusedField == .place {
                        searchLogic.placeSearchText = ""
                    } else if self.focusedField == .area {
                        searchLogic.areaSearchText = ""
                    }
                } label: {
                    Text("Cancel")
                        .foregroundColor(oceanBlue.grayPurp)
                        .font(.avenirNextRegular(size: 16))
                        .padding(.trailing)
                }
            }
            .opacity(fieldIsFocused && hasCharacters ? 1 : 0)
        }

    }
    
    
//    private func singleStarReview(_ place: SchnozPlace) -> some View {
//        HStack {
//            Image(systemName: "star.fill")
//                .foregroundColor(oceanBlue.yellow)
//            Text("\(place.averageRating?.avgRating ?? 0)")
//                .foregroundColor(oceanBlue.yellow)
//        }
//        .opacity(place.averageRating == nil || place.averageRating?.avgRating == 0 ? 0 : 1)
//    }
    
    private func singleStarReview(_ place: SchnozPlace) -> some View {
        let rating = place.averageRating?.avgRating ?? 0
        let ratingString = String(format: "%.1f", rating)
        let percent = (rating / 5) * 100
        return HStack {
            GradientStars(fillPercent: .constant(percent), starCount: 1, starSize: 0.004, spacing: 0)
                .frame(width: 70, height: 70)
                .offset(x: 20)
            Text(ratingString)
                .foregroundColor(ratingTextColor(rating: rating))
        }
//        .opacity(place.averageRating == nil || place.averageRating?.avgRating == 0 ? 0 : 1)
    }
    
    //MARK: - Buttons
    private var backButton: some View {
        Button(action: backTapped) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(colorScheme == .dark ? oceanBlue.white : oceanBlue.blue)
        }
        .matchedGeometryEffect(id: "search", in: namespace)
        .padding(.trailing, 10)
    }
    
    //MARK: - Methods
    
    private func keyboardCancelTapped() {
        searchLogic.isEditingSearchArea = false
        self.focusedField = .none
    }
    
    private func backTapped() {
        withAnimation {
            listResultsVM.showSearchTableView = false
            listResultsVM.schnozPlaces = []
            listResultsVM.searchBarTapped = false
        }
    }
    
    private func ratingTextColor(rating: Double) -> Color {
        switch rating {
        case 0...2:
            return .red
        case 3:
            return .orange
        case 4...5:
            return .green
        default: return .orange
        }
    }

    //MARK: - Focused Field
    enum Field {
        case place, area
        
        var title: String {
            switch self {
            case .place:
                return "Bars, Restaraunts, Breweries, etc."
            case .area:
                return "Near Me"
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

enum SearchFieldType {
    case place, area
}
