//
//  SchnozModel.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/4/23.
//

import Foundation

struct SchnozModel: Codable {
    
    var formattedAddress: String
    var name: String
    var placeID: String
    
    private enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case name
        case placeID = "place_id"
    }
}
