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
    
    @Binding var user: User
    
    @ObservedObject var exploreVM: ExploreViewModel
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var userStore: UserStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    
    @Environment(\.managedObjectContext) var moc
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    greeting
                    mapButton
                    divider
                    ScrollView(showsIndicators: false) {
                        locationsCollections
                    }
                }
                searchView
                
            }
        }
        .onAppear {
            exploreVM.supplyLocationLists()
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
        VStack {
            LocationCollection(collectionType: .nearby,
                               userStore: userStore,
                               exploreVM: exploreVM,
                               firebaseManager: firebaseManager,
                               errorManager: errorManager,
                               locationStore: locationStore)
            
            LocationCollection(collectionType: .trending,
                               userStore: userStore,
                               exploreVM: exploreVM,
                               firebaseManager: firebaseManager,
                               errorManager: errorManager,
                               locationStore: locationStore)
            
            LocationCollection(collectionType: .featured,
                               userStore: userStore,
                               exploreVM: exploreVM,
                               firebaseManager: firebaseManager,
                               errorManager: errorManager,
                               locationStore: locationStore)
        }
        .frame(width: UIScreen.main.bounds.width)
        
    }
    
    private var divider: some View {
        Divider()
            .frame(height: 1.5)
            .background(oceanBlue.blue)
            .padding(.top, 12)
            .padding(.bottom, -8)
    }
    
    private var searchView: some View {
        VStack {
            SearchBar(exploreVM: exploreVM,
                      locationStore: locationStore,
                      userStore: userStore,
                      firebaseManager: firebaseManager,
                      errorManager: errorManager)
            .padding(.top, 75)
            .padding(.horizontal)
            .padding(.trailing, 65)
            Spacer()
        }
    }
    
    //MARK: - Buttons
    
    private var mapButton: some View {
        HStack {
            Spacer()
            Spacer()
            CircleButton(size: .small,
                         image: Image(systemName: "map"),
                         mainColor: K.Colors.OceanBlue.lightBlue,
                         accentColor: K.Colors.OceanBlue.white,
                         clicked: isShowingMap)
        }
        .padding(.horizontal)
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

