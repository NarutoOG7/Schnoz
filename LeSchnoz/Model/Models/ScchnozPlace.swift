//
//  ScchnozPlace.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import Foundation
import GooglePlaces

class SchnozPlace: Hashable, Identifiable {
    
    static let example = SchnozPlace(placeID: "1", primaryText: "The Shack", secondaryText: "Steamboat Springs",
                                     averageRating: AverageRating(placeID: "1", totalStarCount: 50, numberOfReviews: 10), address: Address(), googleRating: 3.5)
    
    var placeID: String
    var primaryText: String?
    var secondaryText: String?
//    var reviews: [ReviewModel]?
    var averageRating: AverageRating?
    var address: Address?
    var googleRating: Double?
    var gmsPlace: GMSPlace? {
        willSet {
            primaryText = newValue?.name
            secondaryText = newValue?.formattedAddress
            googleRating = Double(newValue?.rating ?? 0)
            if let addressComponents = newValue?.addressComponents {
                self.address = Address(addressComponents: addressComponents)
            } else {
                print("No address components for: \(primaryText ?? "data not ready?")")
            }
        }
    }
    
    var schnozReviews: [ReviewModel] = [] {
//        get {
//            var dictValues = [String : ReviewModel]()
//            for review in self.reviews ?? [] {
//                dictValues[review.id] = review
//            }
//            return Array(dictValues.values)
//        }
        willSet {
            avgRating = self.getAvgRatingIntAndString().number
        }
    }
    
    var avgRating: Double {
        get {
            self.getAvgRatingIntAndString().number
        } set { }
    }
        
    func getAvgRatingIntAndString() -> (number: Double, string: String) {
        
        var avgRatingString = ""
        var avgRatingNum: Double = 0
        
        var totalRatingNumber: Double = 0
        var totalReviewCount = 0
        
        for review in schnozReviews {
            totalRatingNumber += review.rating
            totalReviewCount += 1
        }
        
        if totalReviewCount > 0 {
            avgRatingNum = totalRatingNumber / Double(totalReviewCount)
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

    // INIT From review
    init(review: ReviewModel) {
        self.placeID = review.locationID

        FirebaseManager.instance.getAverageRatingForLocation(placeID) { averageRating in
            self.averageRating = averageRating
        }
        
        GooglePlacesManager.instance.getPlaceDetails(review.locationID) { gmsPlace, _ in
            if let gmsPlace = gmsPlace {
                self.gmsPlace = gmsPlace
            }
        }
        
//        GooglePlacesManager.instance.getPlaceFromID(latestReview.locationID) { gmsPlace, _ in
//            // will this code be synchronous??
//            if let gmsPlace = gmsPlace {
//                self.gmsPlace = gmsPlace
//            }
//        }
    }
    
    func letterForRating() -> String {
        if let rating = googleRating {
            switch rating {
            case 0...1:
                return "F"
            case 1...2:
                return "D"
            case 2...3:
                return "C"
            case 3...4:
                return "B"
            case 4..<5:
                return "A"
            default:
                return "A+"
            }
        }
        return ""
    }
    
    
    init(placeID: String, primaryText: String, secondaryText: String, averageRating: AverageRating, address: Address, googleRating: Double) {
        self.placeID = placeID
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.averageRating = averageRating
        self.address = address
        self.googleRating = googleRating
    }
    
    static func makeSchnozPlace(_ notification: [String: AnyObject], _ completion: @escaping(SchnozPlace?) -> Void) {
      guard
        let placeID = notification["placeID"] as? String
      else {
        completion(nil)
          return
      }
        
        GooglePlacesManager.instance.getSchnozPlaceFromLocationID(placeID) { schnozPlace, error in
            if let schnozPlace = schnozPlace {
                NotificationCenter.default.post(
                    name:  Notification.Name(rawValue: "RefreshNewsFeedNotification"),
                    object: self)
                
                completion(schnozPlace)
            }
        }
    }
    
}
