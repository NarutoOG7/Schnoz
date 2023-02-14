//
//  Binding.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

extension Binding where Value == String? {
    func toNonOptional() -> Binding<String> {
        return Binding<String>(
            get: {
                return self.wrappedValue ?? ""
            },
            set: {
                self.wrappedValue = $0
            }
        )
        
    }
}

