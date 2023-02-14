//
//  FSImage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/12/22.
//

import Foundation

struct FSImage {
    var locID: String
    var imageURL: String
    
    init(dict: [String: Any]) {
        self.locID = dict["locID"] as? String ?? ""
        self.imageURL = dict["imageURL"] as? String ?? ""
    }
}
