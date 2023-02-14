//
//  MainLocCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/16/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainLocCell: View {
    
    var location: LocationModel
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        ZStack {
            image
            title
        }
        .frame(width: 240, height: 270)
            .onAppear {
                loadImageFromFirebase()
            }
        
        
    }
    
    private var image: some View {
        WebImage(url: imageURL)
        .resizable()
        .aspectRatio(0.9, contentMode: .fill)
        .frame(width: 240, height: 270)
        .cornerRadius(15)
        .shadow(color: weenyWitch.black, radius: 3, x: 0, y: 1.5)
    }
    
    private var title: some View {
        VStack {
            Spacer()
            Text(location.location.name)
                .fontWeight(.heavy)
                .font(.avenirNext(size: 27))
                .foregroundColor(weenyWitch.lightest)
                .shadow(color: .black, radius: 1, x: 0, y: 2)
                .padding(10)
        }
    }
    
    private func loadImageFromFirebase()  {
        
        if let imageString = location.location.imageName {
            
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                
                self.imageURL = url
            }
        }
    }
}

struct MainLocCell_Previews: PreviewProvider {
    static var previews: some View {
        MainLocCell(location: LocationModel(location: .example,
                                            imageURLs: [URL(string: "bannack.jpg")!,
                                                        URL(string: "anchorage.jpg")!],
                                            reviews: []))
    }
}
