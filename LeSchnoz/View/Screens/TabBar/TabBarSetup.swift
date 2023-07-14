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
        }
        .alert(isPresented: $isUpdateAvailable) {
            Alert(title: Text("New Update Available"), message: Text("Please update the app to the latest version."), primaryButton: .default(Text("Update"), action: {
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
            
            
            if !userStore.isGuest {
                if !userUpdatedWithReviewDetails {
                    firebaseManager.doesUserExist(id: userStore.user.id) { exists in
                        if !exists {
                            self.updateUserWithReviewDetails()
                        }
                    }
                }
                FirebaseManager.instance.getFirestoreUser { firestoreUser, error in
                    if let firestoreUser = firestoreUser {
                        userStore.firestoreUser = firestoreUser
                    }
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            Task {
                
                if await AppStoreUpdateChecker.isNewVersionAvailable() {
                    print("New version of app is availabe. Showing blocking alert!")
                    self.isUpdateAvailable = true
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
//        .background(Color.clear)
        
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
            MySniffs(firebaseManager: firebaseManager, userStore: userStore, errorManager: errorManager, listResultsVM: listResultsVM)
                .navigationTitle("My Sniffs")
                .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            
            Text("My Sniffs")
            //            Image("MySniffs")
            //            Image("LogoSmall")
            if selection == 1 {
                snifferImage
            } else {
                snifferDarkenedImage
            }
            
        }
        .tag(1)
        
        
    }
    
    
    private var snifferImage: some View {
        Image("smallestSchnoz")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 22, height: 25)
    }
    
    private var snifferDarkenedImage: some View {
        Image("FadedSchnozSVGNew")
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
            TopSniffers()
                .navigationTitle("Top Sniffers")
                .navigationBarColor(backgroundColor: nil, titleColor: oceanBlue.white)
        }
        .tabItem {
            Text("Top Sniffers")
            Image(systemName: "trophy")
            
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

        let tabBarApp = UITabBar.appearance()

//        tabBarApp.unselectedItemTintColor = UIColor(K.Colors.OceanBlue.white.opacity(0.5))
                let appearance = UITabBarAppearance()
                              appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(oceanBlue.white)]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(oceanBlue.white.opacity(0.5))]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(oceanBlue.white)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(oceanBlue.white.opacity(0.5))
        
        appearance.backgroundColor = UIColor(oceanBlue.tabBarColor)
        
        tabBarApp.standardAppearance = appearance
        tabBarApp.scrollEdgeAppearance = appearance
        
        
    }
    
    func navigationAppearance() {
        
        if #available(iOS 15, *) {
            
            let appearance = UINavigationBarAppearance()
            
            appearance.backgroundColor =
            UIColor(oceanBlue.blue)
            
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
        firebaseManager.doesUserExist(id: userStore.user.id) { exists in
            if !exists {
                let firestoreUser = FirestoreUser(id: self.userStore.user.id, username: self.userStore.user.name)
                firebaseManager.addUserToFirestore(firestoreUser)
                DispatchQueue.main.async {
                    userStore.firestoreUser = firestoreUser
                    userOnboarded = true
                }
            }
        }
    }
    
    func updateUserWithReviewDetails() {
        // Create Firestore User if one doesn't exist
        let updatedUser = FirestoreUser(id: userStore.user.id, username: userStore.user.name)
        firebaseManager.getReviewsForUser(userStore.user) { review in
            //            updatedUser.handleAdditionOfReview(review)
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

