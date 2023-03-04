//
//  TapGesture.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/3/23.
//

import SwiftUI


extension UIApplication: UIGestureRecognizerDelegate {
    
    func addTapGestureRecognizer() {
        guard let window = connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - UIGestureRecognizer Delegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
