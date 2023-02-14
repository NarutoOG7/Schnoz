//
//  Favorites.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct Favorites: View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var shouldShowList = false
    
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
        
    let weenyWitch = K.Colors.OceanBlue.self
    let images = K.Images.Favorites.self
    
    var body: some View {
        ZStack {
            K.Colors.OceanBlue.black
            
            VStack {
                displayOptionButton
            if userStore.isGuest {
                guestView
            } else if locationStore.favoriteLocations.count == 0 {
                emptyLocationsView
            }
                    if shouldShowList {
                        locations(asList: true)
                    } else {
                        locations(asList: false)
                    }
                
            }
            
            // Find spot for list and image displya ubtoon
        }
        .navigationBarTitleDisplayMode(.inline)

    }
    
    var guestView: some View {
        Text("Please create an account to add locations to your favorites list.")
            .foregroundColor(weenyWitch.yellow)
            .font(.avenirNext(size: 22))
            .multilineTextAlignment(.center)
    }
    
    var emptyLocationsView: some View {
        Text("Start exploring and track your favorites here!")
            .foregroundColor(weenyWitch.yellow)
            .font(.avenirNext(size: 22))
            .multilineTextAlignment(.center)

    }
    
    var locationsAsImageCollection: some View {
        
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(0..<locationStore.favoriteLocations.count, id: \.self) { index in
                    
                    NavigationLink {
                        LD(location: $locationStore.favoriteLocations[index],
                           userStore: userStore,
                           firebaseManager: firebaseManager,
                           errorManager: errorManager)
                    } label: {
                        FavoritesCell(location: locationStore.favoriteLocations[index])
                    }.padding(.top, 8)
                }
                
            }
        }
    }
    
    private func locations(asList: Bool) -> some View {
        VStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(0..<locationStore.favoriteLocations.count, id: \.self) { index in
                    
                    NavigationLink {
                        
                        LD(location: $locationStore.favoriteLocations[index],
                           userStore: userStore,
                           firebaseManager: firebaseManager,
                           errorManager: errorManager)
                    } label: {
                        if asList {
                            let location = locationStore.favoriteLocations[index].location
                            HStack {
                                Text("\(location.name)")
                                    .foregroundColor(weenyWitch.lightBlue)
                                    .font(.avenirNext(size: 20))
                                    .fontWeight(.bold)
                                    .padding(.leading)
                                Spacer()
                            }
                        } else {
                            FavoritesCell(location: locationStore.favoriteLocations[index])
                        }
                    }.padding(.top, 8)
                }
                
            }
        }
    }
    
    private var displayOptionButton: some View {
        HStack {
            Spacer()
            
            Button(action: displayOptionButtonTapped) {
                if shouldShowList {
                    images.imageDisplayOption
                        .resizable()
                        .frame(width: 35, height: 35)
                } else {
                    images.list
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }
            .foregroundColor(.orange)
            .padding()
        }
    }
    
    private func displayOptionButtonTapped() {
        self.shouldShowList.toggle()
    }
}

struct Favorites_Previews: PreviewProvider {
    static var previews: some View {
        Favorites(locationStore: LocationStore(),
                  userStore: UserStore(),
                  firebaseManager: FirebaseManager(),
                  errorManager: ErrorManager())
    }
}
