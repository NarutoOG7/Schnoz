//
//  SearchControllerBridge.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/20/23.
//

import SwiftUI

struct SearchControllerBridge: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SearchViewController {
            let vc = SearchViewController()
            return vc
    }
    
    func updateUIViewController(_ uiViewController: SearchViewController, context: Context) {
        
    }
}
