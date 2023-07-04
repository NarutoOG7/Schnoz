//
//  SettingsPage.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/26/23.
//

import SwiftUI

struct SettingsPage: View {
    
    @ObservedObject var userStore: UserStore
//    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var loginVM: LoginVM
    @ObservedObject var settingsVM = SettingsVM.instance
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        if settingsVM.showsTutorial {
            SplashScreen(contentViewVM: ContentViewVM.instance)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                    Account(
                        userStore: userStore,
                        firebaseManager: FirebaseManager.instance,
                        errorManager: errorManager,
                        loginVM: loginVM)
                    About()
                    
                }
                .padding(.vertical, 30)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false)
            }
            .background(oceanBlue.blue)
        }
    }
    
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage(
            userStore: UserStore(),
//            firebaseManager: FirebaseManager(),
            errorManager: ErrorManager(), loginVM: LoginVM())
    }
}
