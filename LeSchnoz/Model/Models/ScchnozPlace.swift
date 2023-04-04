//
//  ScchnozPlace.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import Foundation
import GooglePlaces

class SchnozPlace: Hashable, Identifiable {
    
    var placeID: String
    var primaryText: String?
    var secondaryText: String?
    var gmsPlace: GMSPlace? {
        willSet {
            primaryText = newValue?.name
            secondaryText = newValue?.formattedAddress
        }
    }
    
    var schnozReviews: [ReviewModel] = [] {
        willSet {
            avgRating = self.getAvgRatingIntAndString().number
        }
    }
    
    var avgRating: Int {
        get {
            self.getAvgRatingIntAndString().number
        } set { }
    }
    
    func getAvgRatingIntAndString() -> (number: Int, string: String) {
        
        var avgRatingString = ""
        var avgRatingNum = 0
        
        var totalRatingNumber = 0
        var totalReviewCount = 0
        
        for review in schnozReviews {
            totalRatingNumber += review.rating
            totalReviewCount += 1
        }
        
        if totalReviewCount > 0 {
            avgRatingNum = totalRatingNumber / totalReviewCount
            avgRatingString = String(format: "%g", avgRatingNum)
            
            if avgRatingString == "" {
                avgRatingString = "(No Reviews Yet)"
            }
        }
        return (avgRatingNum , avgRatingString)
    }
    
    //MARK: - Equatable
    static func == (lhs: SchnozPlace, rhs: SchnozPlace) -> Bool {
        lhs.placeID == rhs.placeID
    }
 
    //MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(placeID)
    }
    
    //MARK: - Initializers
    init(placeID: String) {
        self.placeID = placeID
    }

    
}
