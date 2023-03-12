//
//  TabBarSetup.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI

struct TabBarSetup: View {
    
    @Namespace var namespace
    
    @State private var selection = 0
    
    @StateObject var locationStore = LocationStore.instance
    @StateObject var exploreVM = ExploreViewModel.instance
    @StateObject var firebaseManager = FirebaseManager.instance
        
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var userStore: UserStore
    @ObservedObject var loginVM: LoginVM
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    init(userStore: UserStore,
         errorManager: ErrorManager,
         loginVM: LoginVM) {
        
        self.userStore = userStore
        self.errorManager = errorManager
        self.loginVM = loginVM
        
        handleHiddenKeys()
        
        tabBarAppearance()
//        navigationAppearance()
        tableViewAppearance()
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                exploreTab
                settingsTab
            }
            
        }
        .accentColor(oceanBlue.white)
        
        
    }
    
    private var exploreTab: some View {
        
        NavigationView {
            
            if exploreVM.showSearchTableView {
                
//                SearchControllerBridge()
                ListResultsView()
                    .matchedGeometryEffect(id: "search", in: namespace)
                
            } else {
                
                ExploreByList(user: $userStore.user,
                              exploreVM: exploreVM,
                              locationStore: locationStore,
                              userStore: userStore,
                              firebaseManager: firebaseManager,
                              errorManager: errorManager)
                .matchedGeometryEffect(id: "search", in: namespace)
                .navigationTitle("Explore")
                .navigationBarHidden(true)
            }
        }
        .background(Color.clear)
        
        .tabItem {
            Text("Explore")
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .tag(0)
        
    }

    private var settingsTab: some View {
        
        NavigationView {
            
            SettingsPage(userStore: userStore,
                         locationStore: locationStore,
                         firebaseManager: firebaseManager,
                         errorManager: errorManager,
                         loginVM: loginVM)
            .navigationTitle("Settings")
            .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            Text("Settings")
            Image(systemName: "gear")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .tag(3)

    }
    
    
    //MARK: - Appearance Helpers
    
    func tabBarAppearance() {
        
        let tabBarAppearance =  UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(K.Colors.OceanBlue.blue)
        tabBarAppearance.unselectedItemTintColor = UIColor(K.Colors.OceanBlue.white.opacity(0.5))
        tabBarAppearance.tintColor = UIColor(K.Colors.OceanBlue.white)
        
        ///This background color is to maintain the same color on scrolling.
        tabBarAppearance.backgroundColor = UIColor(K.Colors.OceanBlue.blue).withAlphaComponent(0.92)
        
    }
    
    func navigationAppearance() {
        
        if #available(iOS 15, *) {
            
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor =
            UIColor( oceanBlue.blue)
            
            appearance.titleTextAttributes =
            [.foregroundColor : UIColor(oceanBlue.white)]
            
            appearance.largeTitleTextAttributes =
            [.foregroundColor : UIColor(oceanBlue.white)]
            
            appearance.shadowColor = .clear
            appearance.backButtonAppearance.normal.titleTextAttributes =
            [.foregroundColor : UIColor(oceanBlue.white)]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
        }
    }
    
    func textViewAppearance() {
        
        let textViewAppearance = UITextField.appearance()
        textViewAppearance.backgroundColor = .clear
        textViewAppearance.tintColor = UIColor(oceanBlue.yellow)
        
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
