//
//  CNPostalAddress.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import Contacts

extension CNPostalAddress {
    
    func streetCityState() -> String {
        "\(self.street), \(self.city), \(self.state)"
    }
}
