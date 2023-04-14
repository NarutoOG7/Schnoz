//
//  AverageRating.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 4/8/23.
//

import Foundation

struct AverageRating: Codable {
    var id = UUID().uuidString
    var avgRating: Int
    var totalStarCount: Int
    var numberOfReviews: Int {
        willSet {
            self.avgRating = totalStarCount / newValue
        }
    }
    var placeID: String
    
    init(totalStarCount: Int,
         numberOfReviews: Int,
         placeID: String) {
        
        self.totalStarCount = totalStarCount
        self.numberOfReviews = numberOfReviews
        self.placeID = placeID
        
        let avgRating = totalStarCount / numberOfReviews
        self.avgRating = avgRating
    }
    
    init(dictionary: [String:Any]) {
        self.avgRating = dictionary["avgRating"] as? Int ?? 0
        self.totalStarCount = dictionary["totalStarCount"] as? Int ?? 0
        self.numberOfReviews = dictionary["numberOfReviews"] as? Int ?? 0
        self.placeID = dictionary["placeID"] as? String ?? ""

    }
}

