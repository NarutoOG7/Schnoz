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
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State var latestReview: ReviewModel?
    
    @State var shouldShowSuccessMessage = false
        
    let defaultReview = ReviewModel(id: "01", rating: 7, review: "Stinks like cigarette smoke and booze. To be fair, it is expected at Stanky's Place", title: "I guess it meets expectations?!", username: "MykalMayn", locationID: "00101", locationName: "Stanky's Place")
    
    var body: some View {
        GeometryReader { geo in
                ZStack {
                    backgroundImage(geo)
                searchStack(geo)
            }
            
                .task {
                    guard Authorization.instance.isSignedIn else { return }
                        DispatchQueue.main.async {
                        FirebaseManager.instance.getLatestReview { review, error in
                                
                                if let error = error {
                                    self.errorManager.message = error.localizedDescription
                                    self.errorManager.shouldDisplay = true
                                }
                                if let review = review {
                                    self.listResultsVM.latestReview = review
                                    self.latestReview = review
                                }
                            
                        }
                    }
                }
        }
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
                            Divider().frame(height: 80)
                        }
                    }.listStyle(.insetGrouped)
                }
                latestReviews(geo)
                    .padding(.top, -20)
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
                    .edgesIgnoringSafeArea(.top)
//                    .blur(radius: 1)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white]),
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
            .frame(width: geo.size.width - 60)
            .padding()
            .background(         RoundedRectangle(cornerRadius: 10)
                .fill(oceanBlue.white)
                .frame(height: 36)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
//            .padding()
            .shadow(color: .white, radius: 10)
    }
    
    private func latestReviews(_ geo: GeometryProxy) -> some View {

             VStack(alignment: .leading) {
                Text("Latest Review")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.vertical)
                 ReviewCard(review: listResultsVM.latestReview ?? ReviewModel())
                    .frame(width:  geo.size.width - 60)
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
                    .frame(width: geo.size.width / 6)
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
        if listResultsVM.nearbyPlaces.isEmpty {
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
        
        withAnimation {
            listResultsVM.showSearchTableView = true
        }
    }
    
    private func searchTypeTapped(_ searchType: SearchType) {
        listResultsVM.searchType = searchType
        
//        DispatchQueue.main.async {
        if searchType.hasEmptyBucket {
                
                
                
                NetworkServices.instance.getNearbyLocationsWithKeyword(searchType.rawValue) { places, error in
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
}

struct HomeDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        HomeDisplayView(
            userStore: UserStore(),
            listResultsVM: ListResultsVM())
    }
}
