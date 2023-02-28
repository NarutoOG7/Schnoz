//
//  ExploreByList.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI


struct ExploreByList: View {
    
    @State var searchText = ""
    @State var showingSearchResults = false
    
    @State var googleSheetVisible = false
    
    @Binding var user: User
    
    @ObservedObject var exploreVM: ExploreViewModel
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var googlePlacesManager = GooglePlacesManager.instance
    @ObservedObject var searchVM = SearchVM.instance
    
    @Environment(\.managedObjectContext) var moc
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var googleTable = GoogleDataTable()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    greeting
                        searchBar
                    divider
                }
            }
            

        }

        .task {
            googlePlacesManager.getNearbyLocation()
        }
        
        .background(K.Images.paperBackground
            .edgesIgnoringSafeArea(.all))
    }
    
    var greeting: some View {
        let nameSizeIsLarge = user.name.count > 10
        return HStack(spacing: -7) {
            Text("\(exploreVM.greetingLogic()),")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.thin)
                .padding(.horizontal)
                .foregroundColor(oceanBlue.blue)
                .lineLimit(1)
            Text("\(user.name)")
                .font(.avenirNext(size: nameSizeIsLarge ? 20 : 27))
                .fontWeight(.medium)
                .foregroundColor(oceanBlue.blue)
                .lineLimit(1)
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var locationsCollections: some View {
        List(googlePlacesManager.nearbyPlaces, id: \.self) { place in
            Text(place.place.name ?? "no nearby location")
            
        }
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1.5)
            .background(oceanBlue.blue)
            .padding(.top, 12)
            .padding(.bottom, -8)
    }
    
    private var searchBar: some View {
        Button {
            searchVM.shouldShowSearchView = true
        } label: {
            
            RoundedRectangle(cornerRadius: 20)
                .fill(oceanBlue.lightBlue)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(oceanBlue.blue))
        }
        .padding(.horizontal)
        .frame(height: 40)
        .fullScreenCover(isPresented: $searchVM.shouldShowSearchView) {
            SearchControllerBridge()
        }
    }

    
    //MARK: - Methods
    
    func isShowingMap() {
        exploreVM.isShowingMap = true
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreByList(user: .constant(User()),
                      exploreVM: ExploreViewModel(),
                      locationStore: LocationStore(),
                      userStore: UserStore(),
                      firebaseManager: FirebaseManager(),
                      errorManager: ErrorManager())
    }
}

