//
//  SettingsVM.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/27/23.
//

import Foundation

class SettingsVM: ObservableObject {
    static let instance = SettingsVM()
    
    @Published var showsTutorial = false

}
