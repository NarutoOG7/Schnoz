//
//  UserStore.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation
import FirebaseAuth
import MapKit


class UserStore: ObservableObject {
    
    static let instance = UserStore()
        
    var adminKey = ""
    
    @Published var currentLocAsAddress: Address?
    @Published var currentLocation: CLLocation? {
        willSet {
            if let newValue = newValue {
                FirebaseManager.instance.getAddressFrom(coordinates: newValue.coordinate) { address in
                    self.currentLocAsAddress = address
                    print(address.city)
                }
            }
        }
    }
    
    @Published var isGuest = UserDefaults.standard.bool(forKey: "isGuest")
    @Published var isSignedIn = UserDefaults.standard.bool(forKey: "signedIn")
    @Published var reviews: [ReviewModel] = []
    @Published var selectedLocationDistanceToUser: Double = 0
    @Published var user = User()

    
    
}


