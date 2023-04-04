//
//  ReviewModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation

struct ReviewModel: Hashable, Identifiable {
    
    var id: String
    var rating: Int = 0
    var review: String = ""
    var title: String = ""
    var username: String = ""
    var locationID: String = ""
    var locationName: String = ""
    var location: SchnozPlace?
    
    init(id: String = "",
         rating: Int = 0,
         review: String = "",
         title: String = "",
         username: String = "",
         locationID: String = "",
         locationName: String = "") {
        self.id = id
        self.rating = rating
        self.review = review
        self.title = title
        self.username = username
        self.locationID = locationID
        self.locationName = locationName
    }
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.rating = dictionary["rating"] as? Int ?? 0
        self.review = dictionary["review"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.locationID = dictionary["locationID"] as? String ?? ""
        self.locationName = dictionary["locationName"] as? String ?? ""
    }
}
