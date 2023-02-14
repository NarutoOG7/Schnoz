//
//  HotelPrice.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct HotelPriceData: Codable {
    let result: HotelResult
    
    
    struct HotelResult: Codable {
        let rates: [Rates]
    }
    
    struct Rates: Codable {
        let rate: Double
    }
}
