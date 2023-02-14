//
//  Address.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation

struct Address: Codable, Hashable {
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    
    init(address: String = "", city: String = "", state: String = "", zipCode: String = "", country: String = "") {
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
    
    func streetCity() -> String {
        address + ", " + city
    }
    
    func streetCityState() -> String {
        address + ", " + city + ", " + state
    }
    
    func cityState() -> String {
        city + ", " + state
    }
    
    func fullAddress() -> String {
        address + ", " + city + ", " + state + " " + zipCode + " " + country
    }
    
    func geoCodeAddress() -> String {
        address + ", " + city + ", " + state
    }
}

