//
//  Location.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import MapKit
import CoreLocation
import SwiftUI
import Firebase
import Contacts

struct LocationData: Identifiable, Equatable, Codable, Hashable {
    
    static let example = LocationData(id: 1111,
                                  name: "Bannack",
                                  address: Address(address: "721 Bannack Rd",
                                                   city: "Dillon",
                                                   state: "MT",
                                                   zipCode: "59725",
                                                   country: "USA"),
                                  description: "Bannack State Park is a National Historic Landmark and is the best preserved of all Montana ghost towns. Back in the “Old West”, during the mighty gold rush of 1862, Bannack’s population grew over 3,000. Today, no residents remain in this town.",
                                  moreInfoLink: "https://fwp.mt.gov/stateparks/bannack-state-park",
                                  locationType: "Ghost Town",
                                  tours: true,
                                  imageName: "FairbanksBridge.jpg",
                                  distanceToUser: nil,
                                  price: 120)
    
    var id: Int
    var name: String
    var address: Address?
    var description: String?
    var moreInfoLink: String?
    var locationType: String?
    var tours: Bool?
    var hours: String?
    var likes: Int?
    var imageName: String?
    var distanceToUser: Double?
    var price: Double?
    var hotelKey: String?
    var geoKey: String?
    var imageURL: URL?
    
    var imageURLS: [URL] = []
    
    init(data: [String : AnyObject]) {
        
        let id = data["id"] as? Int ?? Int.random(in: 200...300)
        let name = data["name"] as? String ?? ""
        let street = data["street"] as? String ?? ""
        let city = data["city"] as? String ?? ""
        let state = data["state"] as? String ?? ""
        let country = data["country"] as? String ?? ""
        let zipCode = data["zipCode"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let moreInfoLink = data["moreInfoLink"] as? String ?? ""

        let imageName = data["imageName"] as? String ?? ""
        let hasTours = data["offersGhostTours"] as? Bool ?? false
        let hotelKey = data["hotelKey"] as? String ?? ""

        self.id = id
        self.name = name
        self.address = Address(address: street,
                               city: city,
                               state: state,
                               zipCode: zipCode,
                               country: country)
        self.description = description
        self.moreInfoLink = moreInfoLink
        self.imageName = imageName
        self.tours = hasTours
        self.hotelKey = hotelKey

    }
   
    
        init(id: Int,
             name: String,
             address: Address?,
             description: String?,
             moreInfoLink: String?,
             locationType: String?,
             tours: Bool?,
             imageName: String?,
             distanceToUser: Double?,
             price: Double?) {
            
            self.id = id
            self.name = name
            self.address = address
            self.description = description
            self.moreInfoLink = moreInfoLink
            self.locationType = locationType
            self.tours = tours
            self.imageName = imageName
            self.distanceToUser = distanceToUser
            self.price = price
        }
    

    mutating func addPrice(_ price: Double) {
        var result = self
        result.price = price
        self = result
    }
    
    //MARK: - Equatable
    
    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    
}


