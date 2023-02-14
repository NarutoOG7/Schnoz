//
//  FavoritesLogic.swift
//  SpookySpots
//
//  Created by Spencer Belton on 5/2/22.
//

import SwiftUI

class FavoritesLogic: ObservableObject {
    
    static let instance = FavoritesLogic()
    
    private var hotels: [FavoriteLocation] = []
    
    @ObservedObject var firebaseManager = FirebaseManager.instance
    @ObservedObject var locationStore = LocationStore.instance
    @ObservedObject var userStore = UserStore.instance
    
    init() {
        loadFromFirebase()
    }
    
    func loadFromFirebase() {
        
        if userStore.isSignedIn {
            
            firebaseManager.getFavorites { favLoc in
                
                self.hotels.append(favLoc)
                
                self.locationStore.favoriteLocations = []
                
                self.firebaseManager.getHotelWithReviews(favLoc.locationID) { locModel in
                    
                    self.locationStore.favoriteLocations.append(locModel)
                }
            }
        }
    }
    
    func contains(_ hotel: LocationModel) -> Bool {
        hotels.contains(where: { $0.locationID == "\(hotel.location.id)" })
    }
    
    func addHotel(_ hotel: LocationModel) {
        
        objectWillChange.send()
        
        let favLoc = FavoriteLocation(id: UUID().uuidString,locationID: "\(hotel.location.id)", userID: userStore.user.id)
        
        hotels.append(favLoc)
        
        locationStore.favoriteLocations.append(hotel)
        
        FirebaseManager.instance.addLocToFavoritesBucket(favLoc)

    }
    
    func removeHotel(_ hotel: LocationModel) {
        
        objectWillChange.send()
        
        locationStore.favoriteLocations.removeAll(where: { $0.location.id == hotel.location.id })
        
        if let favLoc = hotels.first(where: { $0.locationID == "\(hotel.location.id)" }) {
            
            FirebaseManager.instance.removeFavoriteFromBucket(favLoc)
            
            hotels.removeAll(where: { $0.id == favLoc.id })
        }
        
    }

}
