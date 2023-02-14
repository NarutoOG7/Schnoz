//
//  ShareActivitySheet.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

struct ShareActivitySheet: UIViewControllerRepresentable {
    
    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareActivitySheet>) -> UIActivityViewController {
        
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareActivitySheet>) { }
}
