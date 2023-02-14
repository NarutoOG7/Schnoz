//
//  LargeImageLocationView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/2/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct LargeImageLocationView: View {
    
    var location: LocationModel
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State private var imageURL = URL(string: "")
    
    @EnvironmentObject var favoritesLogic: FavoritesLogic
    
    var body: some View {
        ZStack {
            image
            favoriteButton
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        title
                        address
                    }
                    Spacer()

                }.padding(10).background(background)

            }
            
        }.cornerRadius(25).frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
        
            .onAppear {
                loadImageFromFirebase()
            }
        
    }
    
    //MARK: - SubViews

    private var image: some View {
        WebImage(url: imageURL)
                .resizable()
                .aspectRatio(0.9, contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width-20, height: UIScreen.main.bounds.height/3.2)
                .cornerRadius(15)
                .shadow(color: .black, radius: 3, x: 0, y: 1.5)
    }
    
    
    private var title: some View {
        Text(location.location.name)
            .font(.avenirNext(size: 20))
            .fontWeight(.medium)
            .lineLimit(2)
            .foregroundColor(oceanBlue.white)
            .padding(.horizontal)
    }
    
    private var address: some View {
        Text(location.location.address?.streetCityState() ?? "")
            .font(.avenirNextRegular(size: 17))
            .foregroundColor(oceanBlue.white)
            .lineLimit(1)
            .padding(.horizontal)
    }
    
    private var background: some View {
        Rectangle()
            .fill(oceanBlue.black)
    }
    
    //MARK: - Buttons
    private var favoriteButton: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: favoritesTapped) {
                    Image(systemName: favoritesLogic.contains(location) ? "heart.fill" : "heart")
                        .renderingMode(.none)
                        .resizable()
                        .shadow(color: Color.black, radius: 1.5)
                        .tint(Color.red)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                }
                    Spacer()
            }
        }.padding()
    }
    
    //MARK: - Methods
    
    private func loadImageFromFirebase()  {
        
        if let imageString = location.location.imageName {
            
            FirebaseManager.instance.getImageURLFromFBPath(imageString) { url in
                
                self.imageURL = url
            }
        }
    }
    
    private func favoritesTapped() {
        
        if favoritesLogic.contains(location) {
            
            favoritesLogic.removeHotel(location)
            
        } else {
            
            favoritesLogic.addHotel(location)
        }
    }
}


//MARK: - Preview
struct LargeImageLocationView_Previews: PreviewProvider {
    static var previews: some View {
        LargeImageLocationView(location: LocationModel(location: .example, imageURLs: [], reviews: []))
    }
}
