//
//  AverageRating.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/8/23.
//

import Foundation

struct AverageRating: Codable {
    
    var id: String
    var avgRating: Int = 0 
    var totalStarCount: Int
    var numberOfReviews: Int {
        willSet {
            if newValue == 0 {
                self.avgRating = 0
            } else {
                self.avgRating = totalStarCount / newValue
            }
        }
    }
    
    init(placeID: String,
         totalStarCount: Int,
         numberOfReviews: Int) {
        
        self.id = placeID
        self.totalStarCount = totalStarCount
        self.numberOfReviews = numberOfReviews
        
//        let avgRating = totalStarCount / numberOfReviews
//        self.avgRating = avgRating
    }
    
    init(dictionary: [String:Any]) {
        self.avgRating = dictionary["avgRating"] as? Int ?? 0
        self.totalStarCount = dictionary["totalStarCount"] as? Int ?? 0
        self.numberOfReviews = dictionary["numberOfReviews"] as? Int ?? 0
        self.id = dictionary["id"] as? String ?? ""

    }
}

