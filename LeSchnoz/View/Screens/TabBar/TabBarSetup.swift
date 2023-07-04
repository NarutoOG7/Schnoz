//
//  TabBarSetup.swift
//  SpookySpots
//
//  Created by Spencer Belton on 3/24/22.
//

import SwiftUI
import StoreKit

struct TabBarSetup: View {
    
    @AppStorage("userOnboarded") var userOnboarded: Bool = false
    @AppStorage("userUpdatedWithReviewDetails") var userUpdatedWithReviewDetails: Bool = false

    
    @State private var isUpdateAvailable = false
        
    @State private var selection = 0
    
    @StateObject var firebaseManager = FirebaseManager.instance
    @StateObject var listResultsVM = ListResultsVM.instance
    @StateObject var googlePlacesManager = GooglePlacesManager.instance
    
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
        
//        handleHiddenKeys()
        
        tabBarAppearance()
//        navigationAppearance()
        tableViewAppearance()
        
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                homeTab
                mySniffsTab
                newsFeedTab
                otherSniffers
                settingsTab
            }
            
//            .appStoreOverlay(isPresented: $isUpdateAvailable) {
//                SKOverlay.AppConfiguration(appIdentifier: Bundle.main.bundleIdentifier ?? "", position: .bottom)
//               }
            
            .alert(isPresented: $isUpdateAvailable) {
                      Alert(title: Text("New Update Available"), message: Text("Please update the app to the latest version."), primaryButton: .default(Text("Update"), action: {
                          // Open the App Store to update the app
//                          http://itunes.apple.com/lookup?bundleId=\(bundleID)"
//                          "itms-apps://itunes.apple.com/app/idAPP_ID"
                          if let url = AppStoreUpdateChecker.getNewVersionLink(),
                             UIApplication.shared.canOpenURL(url) {
                              UIApplication.shared.open(url)
                          }
                      }), secondaryButton: .cancel())
                  }
            
            .task {
                
                if !userOnboarded && !userStore.isGuest {
                    self.assignFirestoreUser()
                }
                
                if !userUpdatedWithReviewDetails {
                    self.updateUserWithReviewDetails()
                }
                
                Task {
                    
                    if await AppStoreUpdateChecker.isNewVersionAvailable() {
                        print("New version of app is availabe. Showing blocking alert!")
                        self.isUpdateAvailable = true
                    }
                }


            }
        }
        .accentColor(oceanBlue.white)
        
        
    }
    
    private var homeTab: some View {
        
        NavigationView {
            
            if listResultsVM.showSearchTableView {
                
                ListResultsView(googlePlacesManager: googlePlacesManager,
                                listResultsVM: listResultsVM,
                                userStore: userStore,
                                errorManager: errorManager)
                
            } else {
                HomeDisplayView(
                    userStore: userStore,
                    listResultsVM: listResultsVM)
                .navigationTitle("Home")
                .navigationBarHidden(true)
            }
        }
        .background(Color.clear)
        
        .tabItem {
            Text("Home")
            Image(systemName: "house")
                .resizable()
//                .frame(width: 25, height: 25)
        }
        .tag(0)
        
    }
    
    private var mySniffsTab: some View {
        
        NavigationView {
            ManageReviews(firebaseManager: firebaseManager, userStore: userStore, errorManager: errorManager, listResultsVM: listResultsVM)
            .navigationTitle("My Sniffs")
            .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            
            Text("My Sniffs")
//            Image("MySniffs")
//            Image("LogoSmall")

            image

        }
        .tag(1)


    }
    
    
    private var image: some View {
        Image("smallestSchnoz")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 22, height: 25)
    }
    
    private var newsFeedTab: some View {
        
        NavigationView {
            NewsFeedView()
            .navigationTitle("News Feed")
            .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            Text("News Feed")
            Image(systemName: "newspaper.fill")

        }
        .tag(2)

    }
    

    private var otherSniffers: some View {
        
        NavigationView {
            OtherSniffersView()
            .navigationTitle("Other Sniffers")
            .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            Text("Other Sniffers")
            Image(systemName: "figure.socialdance")

        }
        .tag(3)

    }

    private var settingsTab: some View {
        
        NavigationView {
            SettingsPage(
                userStore: userStore,
//                         firebaseManager: firebaseManager,
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
        .tag(4)

    }
    
    
    //MARK: - Appearance Helpers
    
    func tabBarAppearance() {
        
        let tabBarAppearance =  UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(K.Colors.OceanBlue.blue)
        tabBarAppearance.unselectedItemTintColor = UIColor(K.Colors.OceanBlue.white.opacity(0.5))
        tabBarAppearance.tintColor = UIColor(K.Colors.OceanBlue.white)
//        ///This background color is to maintain the same color on scrolling.
        tabBarAppearance.backgroundColor = UIColor(named: "TabBarColor")

        
//
//        let appearance = UITabBarAppearance()
//                      appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor(K.Colors.OceanBlue.blue)
//                      UITabBar.appearance().standardAppearance = appearance
//                      UITabBar.appearance().scrollEdgeAppearance = appearance


        
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
        
    }
    
    func tableViewAppearance() {
        let tableViewApp = UITableView.appearance()
        tableViewApp.backgroundColor = .clear
    }
    
    //MARK: - Keys
    
    private func handleHiddenKeys() {
        
        var keys: NSDictionary?

        if let path = Bundle.main.path(forResource: K.GhostKeys.file, ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
            if let dict = keys {
                
                if let placesAPI = dict["placesAPIKey"] as? String {
                    
                    NetworkServices.instance.apiKey = placesAPI
                
            }
           }
    }
    
    func assignFirestoreUser() {
        FirebaseManager.instance.doesUserExist(id: userStore.user.id) { exists in
            if !exists {
                let firestoreUser = FirestoreUser(id: self.userStore.user.id, username: self.userStore.user.name)
                FirebaseManager.instance.addUserToFirestore(firestoreUser)
                DispatchQueue.main.async {
                    
                    userOnboarded = true
                }
                
//                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
//                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func updateUserWithReviewDetails() {
        var updatedUser = FirestoreUser(id: userStore.user.id, username: userStore.user.name)
        firebaseManager.getReviewsForUser(userStore.user) { review in
            updatedUser.handleAdditionOfReview(review)
            firebaseManager.updateFirestoreUser(updatedUser)

        }
        userUpdatedWithReviewDetails = true
    }
    
}

//MARK: - Preview

struct TabBarSetup_Previews: PreviewProvider {
    static var previews: some View {
        TabBarSetup(userStore: UserStore.instance,
                    errorManager: ErrorManager.instance,
                    loginVM: LoginVM.instance)
    }
}

