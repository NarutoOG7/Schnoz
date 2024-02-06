//
//  ClearTextEditor.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/13/22.
//

import SwiftUI

extension TextEditor {
    
    func clearTextEditorBackground() -> some View {
        if #available(iOS 16, *) {
            return self
                .scrollContentBackground(.hidden)
                .background(.clear)
        } else {
            return self
                .onAppear {
                    UITextView.appearance().backgroundColor = .clear
                }
        }
            
     }
}
