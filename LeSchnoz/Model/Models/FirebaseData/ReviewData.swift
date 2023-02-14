//
//  ReviewData.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import Foundation

struct ReviewData: Codable {
    var rating: Int = 0
    var review: String = ""
    var title: String = ""
    var username: String = ""
    var locationID: String = ""
    var locationName: String = ""
}
