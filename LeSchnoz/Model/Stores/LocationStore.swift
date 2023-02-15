//
//  LocationStore.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/14/23.
//

import Foundation

class LocationStore: ObservableObject {
    
    static let instance = LocationStore()
    
    @Published var onMapLocations: [LocationModel] = []
    @Published var listLocations: [LocationModel] = []
}
