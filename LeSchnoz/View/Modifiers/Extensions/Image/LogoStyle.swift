//
//  LogoStyle.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

extension Image {
    func logoStyle() -> some View {
        return self
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: 75, height: 75)
            .clipShape(Circle())
    }
}
