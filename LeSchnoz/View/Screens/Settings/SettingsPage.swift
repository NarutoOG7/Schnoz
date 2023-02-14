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
    
    let weenyWitch = K.Colors.OceanBlue.self
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 50) {
                    Account(userStore: userStore,
                            firebaseManager: firebaseManager,
                            locationStore: locationStore,
                            errorManager: errorManager,
                            loginVM: loginVM)
                    About()
                    Admin(userStore: userStore,
                          locationStore: locationStore)
                    addLocationView
                        .padding(.top, -15)
                }
            .padding(.vertical, 30)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
        }
            .background(weenyWitch.black)
    }
      
    //MARK: - Add Location
    private var addLocationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Know of any spooky locations that you would like to share?")
                .foregroundColor(weenyWitch.white)
                .font(.avenirNextRegular(size: 18))
                .italic()
            NavigationLink {
                AddLocationView()
            } label: {
                Text("Submit basic information")
                    .foregroundColor(weenyWitch.yellow)
                    .font(.avenirNextRegular(size: 18))
                    .underline()
            }

        }
        .padding(.horizontal)
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
