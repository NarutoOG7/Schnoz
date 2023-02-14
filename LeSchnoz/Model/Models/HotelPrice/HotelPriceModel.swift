//
//  HotelPriceModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct HotelPriceModel {
    
    let prices: [Double]
    
    var avgPrice: Double {
        var total: Double = 0.0
        for price in prices {
            total += price
        }
        return total / Double(prices.count)
    }
    
    var lowestPrice: Double {
        prices.min() ?? 0
    }
}
