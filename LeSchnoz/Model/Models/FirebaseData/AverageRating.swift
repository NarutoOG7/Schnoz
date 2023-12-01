//
//  AverageRating.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/8/23.
//

import Foundation

struct AverageRating: Codable {
    
    var id: String
    var avgRating: Double = 0
    var totalStarCount: Double
    var numberOfReviews: Int {
        willSet {
            if newValue == 0 {
                self.avgRating = 0
            } else {
                self.avgRating = getAvg(totalStars: totalStarCount, totalReviews: newValue)
            }
        }
    }
    
    func getAvg(totalStars: Double, totalReviews: Int) -> Double {
        totalStars / Double(totalReviews)
    }
        
    init(placeID: String = "",
         totalStarCount: Double = 0,
         numberOfReviews: Int = 0) {
        
        self.id = placeID
        self.totalStarCount = totalStarCount
        self.numberOfReviews = numberOfReviews
        
        self.avgRating = totalStarCount / Double(numberOfReviews)
//        let avgRating = totalStarCount / numberOfReviews
//        self.avgRating = avgRating
    }
    
    init(dictionary: [String:Any]) {
        self.avgRating = dictionary["avgRating"] as? Double ?? 0
        self.totalStarCount = dictionary["totalStarCount"] as? Double ?? 0
        self.numberOfReviews = dictionary["numberOfReviews"] as? Int ?? 0
        self.id = dictionary["id"] as? String ?? ""

    }
}

