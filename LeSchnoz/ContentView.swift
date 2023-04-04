//
//  ContentView.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 2/13/23.
//

import SwiftUI

struct ContentView: View {

    @State var showSplash = true
        
    @StateObject var userStore = UserStore.instance
    @StateObject var errorManager = ErrorManager.instance
    @StateObject var loginVM = LoginVM.instance
    
    @ObservedObject var contentViewVM = ContentViewVM.instance
    
    var body: some View {

                GeometryReader { geo in
            ZStack {

                                if userStore.isSignedIn {
                    if contentViewVM.showTutorial {
                        SplashScreen(contentViewVM: contentViewVM)
                    } else {
                        TabBarSetup(userStore: userStore,
                                    errorManager: errorManager,
                                    loginVM: loginVM)
                    }
                } else {
                    SignupLogin()
//                    CreativeSignInUp(loginVM: loginVM,
//                                     userStore: userStore,
//                                     errorManager: errorManager)
                }

                errorBanner
                    .offset(y: geo.size.height / 9)

            }
        }
        
    }
    
    private var errorBanner: some View {
         NotificationBanner(message: $errorManager.message,
                                  isVisible: $errorManager.shouldDisplay,
                                  errorManager: errorManager)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ContentViewVM: ObservableObject {
    
    static let instance = ContentViewVM()
    
    @Published var showTutorial = false
    
    init() {
        if !UserDefaults.standard.bool(forKey: K.UserDefaults.showTutorial) {
            UserDefaults.standard.set(true, forKey: K.UserDefaults.showTutorial)
            self.showTutorial = true
        } else {
            self.showTutorial = false
        }
    }
}
