//
//  LocationCollection.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct LocationCollection: View {
    
    var collectionType: LocationCollectionTypes
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State var nearbyLocations = [LocationModel]()
    @State var featuredLocations = [LocationModel]()
    @State var trendingLocations = [LocationModel]()
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var exploreVM: ExploreViewModel
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
    @ObservedObject var locationStore: LocationStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            titleView
            locationsList
        }
    }
    
    //MARK: - Subviews
    
    private var titleView: some View {
        Text(collectionType.rawValue)
            .font(.avenirNext(size: 22))
            .fontWeight(.bold)
            .offset(x: 15, y: 17)
            .foregroundColor(oceanBlue.blue)
    }
    
    private var locationsList: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack {
                    switch collectionType {
                    case .search:
                        searchLocationsView
                    case .nearby:
                        nearbyLocationsView
                    case .trending:
                        trendingLocationsView
                    case .featured:
                        featuredList
                    }
                }
            })
        }
    }
    
    //MARK: - Search Locations
    private var searchLocationsView: some View {
        
        let notSearching = exploreVM.searchText.isEmpty
        
        let filteredLocations = locationStore.hauntedHotels
            .filter({ notSearching ? true : $0.location.name.localizedCaseInsensitiveContains(exploreVM.searchText)
            })
        
        return ForEach(0..<filteredLocations.count, id: \.self) { index in
            NavigationLink {
                LD(location: $locationStore.hauntedHotels[index],
                   userStore: userStore,
                   firebaseManager: firebaseManager,
                   errorManager: errorManager)
            } label: {
                MainLocCell(location: locationStore.hauntedHotels[index])
            }
        }
    }
    
    //MARK: - Trending Locations
    
    private var trendingLocationsView: some View {
        
        ForEach(0..<locationStore.trendingLocations.count, id: \.self) { index in
                            
                NavigationLink {
                    
                    LD(location: $locationStore.trendingLocations[index],
                       userStore: userStore,
                       firebaseManager: firebaseManager,
                       errorManager: errorManager)
                    
                } label: {
                    
                    let location = locationStore.trendingLocations[index]
                    
                    MainLocCell(location: location)
                        .padding(isLastInTrending(location)
                                 ? .horizontal : .leading)
                        .padding(.vertical)
                }
            
        }
    }
    
    private func isLastInTrending(_ location: LocationModel) -> Bool {
        location.location.id == locationStore.trendingLocations.last?.location.id ?? UUID().hashValue
    }
    
    //MARK: - Featured
    
    private var featuredList: some View {
        
        ForEach(0..<locationStore.featuredLocations.count, id: \.self) { index in
                            
                NavigationLink {
                    
                    LD(location: $locationStore.featuredLocations[index],
                       userStore: userStore,
                       firebaseManager: firebaseManager,
                       errorManager: errorManager)
                    
                } label: {
                    
                    let location = locationStore.featuredLocations[index]
                    
                    MainLocCell(location: location)
                        .padding(isLastInFeatued(location)
                                 ? .horizontal : .leading)
                        .padding(.vertical)
                }
            
        }
    }
    
    private func isLastInFeatued(_ location: LocationModel) -> Bool {
        location.location.id == locationStore.featuredLocations.last?.location.id ?? UUID().hashValue
    }
    
    //MARK: - Nearby Locations
    
    private var nearbyLocationsView: some View {
        
        let view: AnyView
        
        if userStore.currentLocation == nil {
            
            view = AnyView(Text("Need Current Location").fontWeight(.light).padding())
            
        } else {
            
            view = AnyView(
                
                ForEach(0..<locationStore.nearbyLocations.count, id: \.self) { index in
                                            
                        NavigationLink {
                            
                            LD(location: $locationStore.nearbyLocations[index],
                               userStore: userStore,
                               firebaseManager: firebaseManager,
                               errorManager: errorManager)
                            
                        } label: {
                            
                            let location = locationStore.nearbyLocations[index]
                            
                            MainLocCell(location: location)
                                .padding(isLastInNearbyList(location)
                                         ? .horizontal : .leading)
                                .padding(.vertical)
                        }
                })
        }
        
        return view
    }
    
    private func isLastInNearbyList(_ location: LocationModel) -> Bool {
        location.location.id == locationStore.nearbyLocations.last?.location.id ?? UUID().hashValue
    }
}

//MARK: - Preview

struct LocationCollection_Previews: PreviewProvider {
    
    static let locationStore = LocationStore()
    
    static var previews: some View {
        LocationCollection(collectionType: .featured,
                           userStore: UserStore(),
                           exploreVM: ExploreViewModel(),
                           firebaseManager: FirebaseManager(),
                           errorManager: ErrorManager(),
                           locationStore: LocationStore())
    }
}


//MARK: - Location Collection Types

enum LocationCollectionTypes: String {
    case search = ""
    case nearby = "Nearby Spooks"
    case trending = "Trending"
    case featured = "Featured"
}

