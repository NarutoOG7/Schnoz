//
//  SettingsPage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct SettingsPage: View {
    
    @State var passwordResetAlertShown = false
    @State var firebaseErrorAlertShown = false
    @State var failSignOutAlertShown = false
    @State var confirmSignOutAlertShown = false
    
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var locationStore: LocationStore
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var loginVM: LoginVM
    
    var auth = Authorization.instance
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                    Account(userStore: userStore,
                            firebaseManager: firebaseManager,
                            locationStore: locationStore,
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

//MARK: - Preview
struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsPage(userStore: UserStore(),
                         locationStore: LocationStore(),
                         firebaseManager: FirebaseManager(),
                         errorManager: ErrorManager(),
                         loginVM: LoginVM())
        }
    }
}
