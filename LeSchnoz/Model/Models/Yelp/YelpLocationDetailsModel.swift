//
//  YelpLocationDetailsModel.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 9/19/23.
//

import Foundation

struct YelpLocationDetailsModel: Codable {
    let id: String
    let name: String
    let url: String
    let rating: Double
    let photos: [String]
    let isOpen: Bool
    
    
    //MARK: - Initializers
    
    init(dict: NSDictionary) {
        
        let id = dict.value(forKey: "id") as? String ?? ""
        let name = dict.value(forKey: "name") as? String ?? ""
        let url = dict.value(forKey: "url") as? String ?? ""
        let rating = dict.value(forKey: "rating") as? Double ?? 0
        let photos = dict.value(forKey: "photos") as? [String] ?? []
        let isOpen = dict.value(forKey: "is_open_now") as? Bool ?? false
        
        self.id = id
        self.name = name
        self.url = url
        self.rating = rating
        self.photos = photos
        self.isOpen = isOpen
    }
    
    //MARK: - CodingKeys
    private enum CodingKeys : String, CodingKey {
        case id
        case name
        case url
        case rating
        case photos
        case isOpen = "is_open_now"
    }
}
