//
//  User.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import Foundation

struct User: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var email: String
    var reviewCount: Int?
    var totalStarsGiven: Double?
    var averageStarsGiven: Double?
    
    init(id: String = "", name: String = "", email: String = "", reviewCount: Int = 0, totalStarsGiven: Double = 0, averageStarsGiven: Double = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.reviewCount = reviewCount
        self.totalStarsGiven = totalStarsGiven
        self.averageStarsGiven = averageStarsGiven
    }
    
    init(dict: [String:Any]) {
        self.id = dict["id"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.reviewCount = dict["totalReviewCount"] as? Int ?? 0
        self.totalStarsGiven = dict["totalStarsGiven"] as? Double ?? 0
        self.averageStarsGiven = dict["averageStarsGiven"] as? Double ?? 0

    }
}
