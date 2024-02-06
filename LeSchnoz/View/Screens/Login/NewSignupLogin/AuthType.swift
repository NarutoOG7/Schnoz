//
//  AuthType.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import Foundation

enum AuthType: String {
    case login, signup
    
    var index: Int {
        switch self {
        case .login:
            return 0
        case .signup:
            return 1
        }
    }
}
