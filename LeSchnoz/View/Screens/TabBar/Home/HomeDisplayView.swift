//
//  HomeDisplayView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/22/23.
//

import SwiftUI
import Combine
import Firebase

struct HomeDisplayView: View {
  
    @Namespace var namespace
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var listResultsVM: ListResultsVM
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var userLocManager = UserLocationManager.instance
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State var latestReview: ReviewModel?
    @State var latestReviewPlace: SchnozPlace?
    
    @State var shouldShowSuccessMessage = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geo in
                ZStack {
                    backgroundImage(geo)
                        
                searchStack(geo)
            }
            
                .task {
                    
                    guard Authorization.instance.isSignedIn else { return }
                        FirebaseManager.instance.getLatestReview { review, error in
                            
                            if let error = error {
                                self.errorManager.message = error.localizedDescription
                                self.errorManager.shouldDisplay = true
                            }
                            if let review = review {
                                DispatchQueue.main.async {
                                self.listResultsVM.latestReview = review
                                self.latestReview = review
                                
                                self.latestReviewPlace = SchnozPlace(review: review)
                            }
                            
                        }
                    }
//                    listResultsVM.searchRegion = ""
//                    SearchLogic.instance.areaSearchLocation = ""

                }
        }
        .fullScreenCover(isPresented: $listResultsVM.shouldShowPlaceDetails) {
            LD()
        }
        .alert("Allow Always?", isPresented: $userLocManager.shouldAskAlwaysPermission, actions: {
            Button("Cancel" , role: .cancel) {}
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    // Ask the system to open that URL.
                     UIApplication.shared.open(url)
                }
            } label: {
                Text("Allow Always")
            }
            


        }, message: {
            Text("We need your permission to track your location in order to send you recommendations.")
        })

    }

    
    private func searchStack(_ geo: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Spacer(minLength: geo.size.height * 0.33)
                searchView(geo)
                HStack(spacing: geo.size.width / 15) {
                    ForEach(SearchType.allCases.indices, id: \.self) { index in
                        searchTypeOptionView(SearchType.allCases[index], geo)
                        if index != SearchType.allCases.indices.last {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 0.5, height: 80)
                                .foregroundColor(colorScheme == .dark ? oceanBlue.yellow : oceanBlue.blue)
//                            Divider().frame(height: 80)
                        }
                    }.listStyle(.insetGrouped)
                }
                latestReview(geo)
                    .padding(.top, -20)
                    .padding(.horizontal)
                Spacer()
            }
        }
    }
    
    private func schnozLogo(_ geo: GeometryProxy) -> some View {
        Image("SchnozLogoOutline")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geo.size.width / 2)
            .offset(y: -30)
    }
    
    private func backgroundImage(_ geo: GeometryProxy) -> some View {
        VStack {
            ZStack {
                Image("restaurant")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
//                    .frame(width: geo.size.width + 20)
//                    .blur(radius: 1)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, colorScheme == .dark ? Color.black : Color.white]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
                schnozLogo(geo)
            }
            .frame(width: geo.size.width, height: geo.size.height * 0.4)
            Spacer()
        }
    }
    
    private func searchView(_ geo: GeometryProxy) -> some View {
            
            Button(action: searchTapped) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 20, alignment: .leading)
                        .foregroundColor(oceanBlue.grayPurp)
                        .font(.subheadline)
                    
                    Text("What are you looking for, \(userStore.user.name)?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(oceanBlue.blue)
                        .font(.subheadline)
                }
                .matchedGeometryEffect(id: "search", in: namespace)
                
            }
            .padding()
            .background(         RoundedRectangle(cornerRadius: 10)
                .fill(oceanBlue.white)
                .frame(height: 36)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            .shadow(color: .white, radius: 10)
    }
    
    private func latestReview(_ geo: GeometryProxy) -> some View {
             VStack(alignment: .leading) {
                Text("Latest Review")
                    .font(.headline)
                    .foregroundColor(oceanBlue.blue)
                    .padding(.vertical)
                 Button(action: self.latestReviewTapped) {
//                     ReviewCard(review: listResultsVM.latestReview ?? ReviewModel())
                     ReviewCell(review: listResultsVM.latestReview ?? ReviewModel(), needsToHandleColorScheme: true, isNavigatable: true)
//                        .frame(width:  geo.size.width - 60)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(oceanBlue.blue, lineWidth: 3))
                 }
            }
        }
    
    private func searchTypeOptionView(_ searchType: SearchType, _ geo: GeometryProxy) -> some View {
        Button {
            searchTypeTapped(searchType)
        } label: {
            VStack {
                searchType.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: geo.size.width / 10)
                    .foregroundColor(oceanBlue.lightBlue)
                    .fontWeight(.ultraLight)
//                    .frame(width: geo.size.width / 6)
                Text(searchType.rawValue.capitalized)
                    .font(.footnote)
                    .foregroundColor(oceanBlue.lightBlue)
                    .lineLimit(1)
                    .padding(.leading, searchType == .breakfast ? -15 : 0)
                    .offset(x: searchType == .breakfast ? 6 : 0)
            }
        }

    }
    
    //MARK: - Methods
    
    private func searchTapped() {
        if listResultsVM.nearbyPlaces.isEmpty || listResultsVM.currentLocationChanged == true {
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
        } else {
            listResultsVM.schnozPlaces = listResultsVM.nearbyPlaces
        }
        listResultsVM.searchBarTapped = true
        withAnimation {
            listResultsVM.showSearchTableView = true
        }
    }
    
    private func searchTypeTapped(_ searchType: SearchType) {
        listResultsVM.searchType = searchType

        if searchType.hasEmptyBucket {
            let isAllSearch = searchType == .all
            let keyword = isAllSearch ? "Food" : searchType.rawValue
                NetworkServices.instance.getNearbyLocationsWithKeyword(keyword) { places, error in
                    if let error = error {
                        self.errorManager.message = error.localizedDescription
                        self.errorManager.shouldDisplay = true
                    }
                    if let places = places {
                        searchType.addPlacesToBucket(places)

                            listResultsVM.schnozPlaces = places
                        listResultsVM.isLoading = false
                    }
                }
        } else {
            listResultsVM.schnozPlaces = searchType.places
        }
        listResultsVM.showSearchTableView = true
    }
    
//    private func searchTypeTapped(_ searchType: SearchType) {
//        listResultsVM.searchType = searchType
//
//        if searchType.hasEmptyBucket {
//            let isAllSearch = searchType == .all
//            let keyword = isAllSearch ? "food" : searchType.rawValue // food
//            GooglePlacesManager.instance.performAutocompleteQuery(keyword) { places, error in
//                    if let error = error {
//                        self.errorManager.message = error.localizedDescription
//                        self.errorManager.shouldDisplay = true
//                    }
//                    if let places = places {
//                        searchType.addPlacesToBucket(places)
//
//                            listResultsVM.schnozPlaces = places
//                        listResultsVM.isLoading = false
//                    }
//                }
//        } else {
//            listResultsVM.schnozPlaces = searchType.places
//        }
//        listResultsVM.showSearchTableView = true
//    }
    
    private func latestReviewTapped() {
        LDVM.instance.selectedLocation = self.latestReviewPlace
        self.listResultsVM.shouldShowPlaceDetails = true
//        SearchLogic.instance.getImageForSelectedPlace(self.latestReviewPlace ?? SchnozPlace(placeID: ""))
//        LDVM.instance.reviews = []
//        LDVM.instance.selectedLocation = self.latestReviewPlace
    }
    

}

struct HomeDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDisplayView(
            userStore: UserStore(),
            listResultsVM: ListResultsVM())
    }
}