//
//  FavoritesCell.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/16/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoritesCell: View {
    
    var location: LocationModel
    
    let weenyWitch = K.Colors.WeenyWitch.self
    
    @State private var imageURL = URL(string: "")
    
    var body: some View {
        
        let screenSize = UIScreen.main.bounds.size
        
        ZStack {
            image
            title
        }
        .frame(width: screenSize.width - 20, height: screenSize.height / 3)
        
        .onAppear {
            loadImageFromFirebase()
        }
        
    }
    
    private var image: some View {
        WebImage(url: imageURL)
                .resizable()
                .cornerRadius(15)
                .shadow(color: .black, radius: 3, x: 0, y: 1.5)
        
    }
    
    private var title: some View {
        VStack {
            Spacer()
            Text(location.location.name)
                .font(.avenirNext(size: 27))
                .fontWeight(.heavy)
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

struct FavoritesCell_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesCell(location: LocationModel.example)
    }
}
