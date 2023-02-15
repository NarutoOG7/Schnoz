//
//  ExploreByMap.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import CoreLocation

struct ExploreByMap: View {
    
    @State private var swipeDirection: ExploreViewModel.SwipeDirection?
    
    @State private var shouldNavigate = false
    
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var exploreVM: ExploreViewModel
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
    let map = MapViewUI(mapIsForExplore: true)
    
    var body: some View {
        
        ZStack {
            map
                .ignoresSafeArea()
            searchView
            HStack {
                Spacer()
                
                VStack {
                    listButton
                    currentLocationButton
                    Spacer()
                }
                .padding(.top, 2)
                .padding(.horizontal)
            }
            
            locationList
                .padding()
            
        }
        
        .navigationTitle("Map")
        .navigationBarHidden(true)
        
        .fullScreenCover(isPresented: $shouldNavigate) {
            Binding($exploreVM.displayedLocation).map {
                LD(location: $0,
                   userStore: userStore,
                   firebaseManager: firebaseManager,
                   errorManager: errorManager)
            }
        }
    }
    
    
    //MARK: - Subviews
    
    
    private var locationsList: some View {
        
        VStack {
            
            Spacer()
            
            ZStack {
                
                ForEach(locationStore.onMapLocations) { location in
                    
                    if exploreVM.displayedLocation == location {
                        MainLocCell(location: location)
                            .onTapGesture {
                                exploreVM.displayedLocation = location
                                self.shouldNavigate = true
                            }
                    }
                }
            }
        }
    }
    
    private var searchView: some View {
        VStack {
            SearchBar(exploreVM: exploreVM,
                      userStore: userStore,
                      firebaseManager: firebaseManager,
                      errorManager: errorManager)
            .padding(.horizontal)
            .padding(.trailing, 65)
            Spacer()
        }
    }
    
    private var locationList: some View {
        
        let view: AnyView
        
        if exploreVM.showingLocationList {
            
            view = AnyView(locationsList)
            
        } else {
            
            view = AnyView(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 200))
        }
        return view
    }
    
    //MARK: - Buttons
    
    private var listButton: some View {
        CircleButton(size: .small,
                     image: K.Images.Favorites.list,
                     mainColor: K.Colors.OceanBlue.lightBlue,
                     accentColor: K.Colors.OceanBlue.white,
                     clicked: listButtonPressed)
    }
    
    private var currentLocationButton: some View {
        CircleButton(size: .small,
                     image: Image(systemName: "location"),
                     mainColor: K.Colors.OceanBlue.lightBlue,
                     accentColor: K.Colors.OceanBlue.white,
                     clicked: currentLocationPressed)
    }
    
    //MARK: - Methods
    
    func listButtonPressed() {
        exploreVM.isShowingMap = false
    }
    
    func currentLocationPressed() {
        map.setCurrentLocationRegion()
    }
    
}



//MARK: - Preview
struct ExploreByMap_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByMap(locationStore: LocationStore(),
                     exploreVM: ExploreViewModel(),
                     userStore: UserStore(),
                     firebaseManager: FirebaseManager(),
                     errorManager: ErrorManager())
        .previewInterfaceOrientation(.portrait)
    }
}
