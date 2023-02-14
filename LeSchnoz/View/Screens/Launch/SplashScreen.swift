//
//  SplashScreen.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/13/22.
//

import SwiftUI

struct SplashScreen: View {
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                K.Colors.OceanBlue.black
                    .edgesIgnoringSafeArea(.all)
                K.Images.logo
                    .frame(height: 313)
                    .padding(.bottom, (geo.size.height / 2) - 250)
                
            }
        }
    }

}




//MARK: - Preview
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .previewInterfaceOrientation(.portrait)
    }
}


