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
    
    var body: some View {

        TabBarSetup(userStore: userStore, errorManager: errorManager, loginVM: loginVM)
        //        GeometryReader { geo in
//            ZStack {
//                if userStore.isSignedIn {
//                    TabBarSetup(userStore: userStore,
//                                errorManager: errorManager,
//                                loginVM: loginVM)
//                } else {
//                    CreativeSignInUp(loginVM: loginVM,
//                                     userStore: userStore,
//                                     errorManager: errorManager)
//                }
//
////                splashScreen
//
//                errorBanner
//                    .offset(y: geo.size.height / 9)
//
//            }
//        }
        
    }
    
    private var splashScreen: some View {
        SplashScreen()
          .opacity(showSplash ? 1 : 0)

          .task {
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation() {
                  self.showSplash = false
                }
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
