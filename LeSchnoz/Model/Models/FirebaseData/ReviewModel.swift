//
//  ReviewModel.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import Foundation
import Firebase

//
//struct ReviewModel: Codable, Hashable, Identifiable {
//
//    static let example = ReviewModel(id: "1", rating: 5, review: "Incredible ventilation! The staff is professional and nice and the food is great too!", title: "Exceptional", username: "Water Bottle", userID: "ETN", locationID: "K3", locationName: "The Shack", address: "425 8th St")
//
//    var id: String
//    var rating: Int
//    var review: String
//    var title: String
//    var username: String
//    let userID: String
//    var locationID: String
//    var locationName: String
////    var location: SchnozPlace?
//    var timeStamp: Date
//    var address: String
//    var addressComp: Address
//
//    init(id: String = "",
//         rating: Int = 0,
//         review: String = "",
//         title: String = "",
//         username: String = "",
//         userID: String = "",
//         locationID: String = "",
//         locationName: String = "",
//         address: String = "",
//         addressComp: Address = Address()) {
//        self.id = id
//        self.rating = rating
//        self.review = review
//        self.title = title
//        self.username = username
//        self.userID = userID
//        self.locationID = locationID
//        self.locationName = locationName
//
////        let timestamp = Timestamp()
//        let date = Date()
//        self.timeStamp = date
//
//        self.address = address
//        self.addressComp = addressComp
//
//    }
//
//    init(dictionary: [String:Any]) {
//        self.id = dictionary["id"] as? String ?? ""
//        self.rating = dictionary["rating"] as? Int ?? 0
//        self.review = dictionary["review"] as? String ?? ""
//        self.title = dictionary["title"] as? String ?? ""
//        self.username = dictionary["username"] as? String ?? ""
//        self.userID = dictionary["userID"] as? String ?? ""
//        self.locationID = dictionary["locationID"] as? String ?? ""
//        self.locationName = dictionary["locationName"] as? String ?? ""
//        self.timeStamp = dictionary["timestamp"] as? Date ?? Date()
//        self.address = dictionary["address"] as? String ?? ""
//
//        self.addressComp = Address(dictionary: dictionary)
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case rating = "rating"
//        case review = "review"
//        case title = "title"
//        case username = "username"
//        case userID = "userID"
//        case locationID = "locationID"
//        case locationName = "locationName"
//        case timeStamp = "timestamp"
//        case address = "address"
//        case addressComp = "addressComp"
//    }
//}


struct ReviewModel: Hashable, Identifiable {

    static let example = ReviewModel(id: "1", rating: 5, review: "Incredible ventilation! The staff is professional and nice and the food is great too!", title: "Exceptional", username: "Water Bottle", userID: "ETN", locationID: "K3", locationName: "The Shack", address: Address(address: "425 8th St", city: "Steamboat Springs", state: "Colorado", zipCode: "80477", country: "USA"))

    var id: String
    var rating: Int = 0
    var review: String = ""
    var title: String = ""
    var username: String = ""
    let userID: String
    var locationID: String = ""
    var locationName: String = ""
    var location: SchnozPlace?
    var timeStamp: Timestamp
    var address: Address

    init(id: String = "",
         rating: Int = 0,
         review: String = "",
         title: String = "",
         username: String = "",
         userID: String = "",
         locationID: String = "",
         locationName: String = "",
         address: Address = Address()) {
        self.id = id
        self.rating = rating
        self.review = review
        self.title = title
        self.username = username
        self.userID = userID
        self.locationID = locationID
        self.locationName = locationName

        let timestamp = Timestamp()
        self.timeStamp = timestamp

        self.address = address

    }

    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? ""
        self.rating = dictionary["rating"] as? Int ?? 0
        self.review = dictionary["review"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.locationID = dictionary["locationID"] as? String ?? ""
        self.locationName = dictionary["locationName"] as? String ?? ""
        self.timeStamp = dictionary["timestamp"] as? Timestamp ?? Timestamp()
        self.address = Address(dictionary: dictionary)
    }
}
