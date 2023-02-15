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

