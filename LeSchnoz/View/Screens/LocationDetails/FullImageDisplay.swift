//
//  FullImageDisplay.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/25/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FullImageDisplay: View {
        
    var location: LocationModel
    
    var body: some View {
        imageCollection
    }
    
    private var imageCollection: some View {
        ForEach(location.imageURLs, id: \.self) { url in
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width)
                    .aspectRatio(1, contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

struct FullImageDisplay_Previews: PreviewProvider {
    static var previews: some View {
        FullImageDisplay(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}
