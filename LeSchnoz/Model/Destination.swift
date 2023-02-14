//
//  Destination.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/13/23.
//

import Foundation

struct Destination: Codable, Equatable, Identifiable {
    var id: String
    var lat: Double
    var lon: Double
    var address: String
    var name: String
    var position: Int
    
    init(dict: [String:AnyObject]) {
        self.id = dict["id"] as? String ?? ""
        self.lat = dict["lat"] as? Double ?? 0
        self.lon = dict["lon"] as? Double ?? 0
        self.address = dict["address"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.position = dict["position"] as? Int ?? 0
    }
    //MARK: - Init From LocationModel
    init(id: String = "",
         lat: Double = -105,
         lon: Double = 39,
         address: String = "",
         name: String = "",
         position: Int = 0) {
        self.id = id
        self.lat = lat
        self.lon = lon
        self.address = address
        self.name = name
        self.position = position
    }
    
    static let base = Destination(id: "BASE", lat: 39.5501, lon: -105.7821, address: "", name: "BASE", position: 0)
}
