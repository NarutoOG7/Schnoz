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
        NavigationView {
            GeometryReader { geo in
                ZStack {

                    if userStore.isSignedIn {
                        if contentViewVM.showTutorial {
                            SplashScreen(contentViewVM: contentViewVM)
                        } else {

                            TabBarSetup(userStore: userStore,
                                        errorManager: errorManager,
                                        loginVM: loginVM)
                            
                            .task {
                                FirebaseManager.instance.getAnnotations { annotations in
                                    if let annotations = annotations {
                                        UserLocationManager.instance.annotations = annotations
                                    }
                                }
                                
                                ProximityTimerManager.instance.setupNotificationObserver()
                            }
                        
                            .onReceive(ProximityTimerManager.instance.timer) { time in
                                                        
                                GooglePlacesManager.instance.getClosestEstablishment { place, error in
                                    if let place = place {
                                        print(place.primaryText)
                                        ProximityTimerManager.instance.postCustomNotification(place)
                                        ProximityTimerManager.instance.timer.upstream.connect().cancel()
                                    }
                                }
                                //                                FirebaseManager.instance.writeTime(time)
                            }
                        }
                    } else {
                        SignupLogin()
                    }

                    errorBanner
                        .offset(y: geo.size.height / 9)

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
