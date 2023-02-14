//
//  LocationStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Combine
import CoreLocation
import MapKit
import SwiftUI

class LocationStore: ObservableObject {
    static let instance = LocationStore()
            
    @Published var favoriteLocations: [LocationModel] = []
    @Published var onMapLocations: [LocationModel] = []
    @Published var nearbyLocations: [LocationModel] = []
    @Published var hauntedHotels: [LocationModel] = []
    @Published var trendingLocations: [LocationModel] = [] 
    @Published var featuredLocations: [LocationModel] = []
    
    @Published var reviewBucket: [ReviewModel] = []
    
    func switchNewLocationIntoAllBucketsIfExists(_ location: LocationModel) {
        
        if let favIndex = favoriteLocations.firstIndex(where: { $0.location.id == location.location.id }) {
            favoriteLocations[favIndex] = location
        }
        
        if let onMapIndex = onMapLocations.firstIndex(where: { $0.location.id == location.location.id }) {
            onMapLocations[onMapIndex] = location
        }
        
        if let nearbyIndex = nearbyLocations.firstIndex(where: { $0.location.id == location.location.id }) {
            nearbyLocations[nearbyIndex] = location
        }
        
        if let hhIndex = hauntedHotels.firstIndex(where: { $0.location.id == location.location.id }) {
            hauntedHotels[hhIndex] = location
        }
        
        if let trendingIndex = trendingLocations.firstIndex(where: { $0.location.id == location.location.id }) {
            trendingLocations[trendingIndex] = location
        }

        if let featuredIndex = featuredLocations.firstIndex(where: { $0.location.id == location.location.id }) {
            featuredLocations[featuredIndex] = location
        }
    }
}
