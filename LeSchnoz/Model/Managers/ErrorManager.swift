//
//  ErrorManager.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/10/22.
//

import SwiftUI

class ErrorManager: ObservableObject {
    
    static let instance = ErrorManager()
    
    @Published var message = "" 
    @Published var shouldDisplay = false
    
}
