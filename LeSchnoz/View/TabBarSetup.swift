//
//  TabBarSetup.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct TabBarSetup: View {
    
    @State private var selection = 0
    
    @StateObject var favoritesLogic = FavoritesLogic.instance
    @StateObject var locationStore = LocationStore.instance
    @StateObject var exploreVM = ExploreViewModel.instance
    @StateObject var firebaseManager = FirebaseManager.instance
    
    var hotelPriceManager = HotelPriceManager.instance
    
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var loginVM: LoginVM
    
    let weenyWitch = K.Colors.OceanBlue.self
    
    init(userStore: UserStore,
         errorManager: ErrorManager,
         loginVM: LoginVM) {
        
        self.userStore = userStore
        self.errorManager = errorManager
        self.loginVM = loginVM
        
        handleHiddenKeys()
        
        tabBarAppearance()
        navigationAppearance()
        tableViewAppearance()
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                exploreTab
                favoritesTab
                settingsTab
            }
            
        }
        .accentColor(weenyWitch.yellow)
        .environmentObject(favoritesLogic)
        
        
    }
    
    private var exploreTab: some View {
        
        NavigationView {
            
            exploreHelperView
            
                .navigationTitle("Explore")
                .navigationBarHidden(true)
        }
        .background(Color.clear)
        .accentColor(weenyWitch.black)
        
        .tabItem {
            Text("Explore")
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .tag(0)
        
    }
    
    private var favoritesTab: some View {
        
        NavigationView {
            
            Favorites(locationStore: locationStore,
                      userStore: userStore,
                      firebaseManager: firebaseManager,
                      errorManager: errorManager)
            
            .navigationTitle("Favorites")
            
        }
        .accentColor(weenyWitch.black)
        
        .tabItem {
            Text("Favorites")
            Image(systemName: "heart")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .tag(1)
        
    }
    
    private var settingsTab: some View {
        
        NavigationView {
            
            SettingsPage(userStore: userStore,
                         locationStore: locationStore,
                         firebaseManager: firebaseManager,
                         errorManager: errorManager,
                         loginVM: loginVM)
            .navigationTitle("Settings")
        }
        .accentColor(weenyWitch.black)
        
        .tabItem {
            Text("Settings")
            Image(systemName: "gear")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .tag(3)
    }
    
    
    private var exploreHelperView: some View {
        
        let view: AnyView
        
        if exploreVM.isShowingMap {
            
            view = AnyView(ExploreByMap(locationStore: locationStore,
                                        exploreVM: exploreVM,
                                        userStore: userStore,
                                        firebaseManager: firebaseManager,
                                        errorManager: errorManager))
            
        } else {
            
            view = AnyView(ExploreByList(user: $userStore.user,
                                         exploreVM: exploreVM,
                                         locationStore: locationStore,
                                         userStore: userStore,
                                         firebaseManager: firebaseManager,
                                         errorManager: errorManager))
        }
        
        return view
    }
    
    
    //MARK: - Appearance Helpers
    
    func tabBarAppearance() {
        
        let tabBarAppearance =  UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(K.Colors.OceanBlue.black)
        tabBarAppearance.unselectedItemTintColor = UIColor(K.Colors.OceanBlue.white)
        
        ///This background color is to maintain the same color on scrolling.
        tabBarAppearance.backgroundColor = UIColor(K.Colors.OceanBlue.black).withAlphaComponent(0.92)
        tabBarAppearance.tintColor = UIColor(K.Colors.OceanBlue.yellow)
        
    }
    
    func navigationAppearance() {
        
        if #available(iOS 15, *) {
            
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor =
            UIColor( weenyWitch.lightBlue)
            
            appearance.titleTextAttributes =
            [.foregroundColor : UIColor(weenyWitch.blue)]
            
            appearance.largeTitleTextAttributes =
            [.foregroundColor : UIColor(weenyWitch.black)]
            
            appearance.shadowColor = .clear
            appearance.backButtonAppearance.normal.titleTextAttributes =
            [.foregroundColor : UIColor(weenyWitch.blue)]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
        }
    }
    
    func textViewAppearance() {
        
        let textViewAppearance = UITextField.appearance()
        textViewAppearance.backgroundColor = .clear
        textViewAppearance.tintColor = UIColor(weenyWitch.yellow)
        
    }
    
    func tableViewAppearance() {
        let tableViewApp = UITableView.appearance()
        tableViewApp.backgroundColor = .clear
    }
    
    //MARK: - Keys
    
    private func handleHiddenKeys() {
        
        var keys: NSDictionary?

        if let path = Bundle.main.path(forResource: "HiddenKeys", ofType: "plist") {
               keys = NSDictionary(contentsOfFile: path)
           }
           if let dict = keys {
               
               if let adminKey = dict["adminKey"] as? String {
                   
                   userStore.adminKey = adminKey
                   
               }
               if let hotelPriceAPIKey = dict["hotelPriceAPIKey"] as? String {
                   
                   hotelPriceManager.hotelPriceURL = hotelPriceAPIKey
                   
               }

           }
    }
}

//MARK: - Preview

struct TabBarSetup_Previews: PreviewProvider {
    static var previews: some View {
        TabBarSetup(userStore: UserStore(),
                    errorManager: ErrorManager(),
                    loginVM: LoginVM())
    }
}
