//
//  LocationModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/25/22.
//

import Foundation

struct LocationModel: Identifiable, Equatable, Hashable {

    static let example = LocationModel(location: LocationData.example, imageURLs: [], reviews: [])
    
    var id = UUID()
    var location: LocationData
    var imageURLs: [URL]
    var reviews: [ReviewModel] {
        willSet {
            avgRating = self.getAvgRatingIntAndString().number
            print(avgRating)
        }
    }
    
    var mainImageURL: URL? {
        imageURLs.first
    }
    
    var avgRating: Int {
        get {
            self.getAvgRatingIntAndString().number
        }
        set { }
    }
        
    func getAvgRatingIntAndString() -> (number: Int, string: String) {
        
        var avgRatingString = ""
        var avgRatingNum = 0
        
        var totalRatingNumber = 0
        var totalReviewCount = 0
        
        for review in reviews {
            
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
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        lhs.location.id == rhs.location.id
    }
    
}
