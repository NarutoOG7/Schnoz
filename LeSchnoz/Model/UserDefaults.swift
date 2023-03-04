//
//  UserDefaults.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/2/23.
//

import Foundation

extension UserDefaults {
    
    func setPlaceText(_ text: String) {
        set(text, forKey: UserDefaultsKeys.placeText.rawValue)
    }
    
    func setSearchAreaText(_ text: String) {
        set(text, forKey: UserDefaultsKeys.searchAreaText.rawValue)
    }
}

enum UserDefaultsKeys: String {
    case placeText
    case searchAreaText
}
