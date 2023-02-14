//
//  ProfilePage.swift
//  SpookySpots
//
//  Created by Spencer Belton on 4/15/22.
//

import SwiftUI

struct ProfilePage: View {
    
    @ObservedObject var userStore: UserStore
    @ObservedObject var errorManager: ErrorManager
    @ObservedObject var loginVM: LoginVM
    
    var auth = Authorization.instance
    
    @State var wasEdited = false
    
    @State var displayNameInput = ""
    @State var emailInput = ""
    
    @State var confirmDeletePasswordInput = ""
    
    @State var confirmDeleteAlertShouldShow = false
    
    @Environment(\.dismiss) var dismiss
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                displayName
                emailView
                Spacer()
                saveButton
                Spacer()
                deleteAcctButton
                Spacer()
            }
            .background(oceanBlue.blue)
            
            if confirmDeleteAlertShouldShow {
                ConfirmDeleteView(shouldShow: $confirmDeleteAlertShouldShow,
                                  loginVM: loginVM,
                                  errorManager: errorManager)
            }
            
                
            
        }
        .navigationTitle("Profile")
    }
    
    private var displayName: some View {
        HStack(alignment: .center, spacing: 24) {
            Text("Name:")
                .foregroundColor(oceanBlue.white)
                .font(.avenirNext(size: 18))

                
                TextField("", text: $displayNameInput)
                    .placeholder(when: displayNameInput.isEmpty) {
                        Text(userStore.user.name)
                            .foregroundColor(oceanBlue.white)
                            .font(.avenirNext(size: 24))

                    }
                    .tint(oceanBlue.white)
                    .foregroundColor(oceanBlue.white)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.avenirNext(size: 24))
                    .onChange(of: displayNameInput) { _ in
                        wasEdited = true
                    }
            
            }.padding()
    }
    
    private var emailView: some View {
        HStack(alignment: .center, spacing: 24) {
            Text("Email:")
                .foregroundColor(oceanBlue.white)
                .font(.avenirNext(size: 18))
            
                TextField("", text: $emailInput)
                    .placeholder(when: emailInput.isEmpty) {
                        Text(userStore.user.email)
                            .foregroundColor(oceanBlue.white)
                            .font(.avenirNext(size: 24))
                    }
                    .tint(oceanBlue.yellow)
                    .foregroundColor(oceanBlue.white)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.avenirNext(size: 24))
                    .onChange(of: emailInput) { _ in
                        wasEdited = true
                    }
            
        }.padding()
    }
    
    //MARK: - Buttons
    
    private var saveButton: some View {
        Button(action: saveTapped) {
            Text("SAVE")
                .foregroundColor(oceanBlue.yellow)
                .font(.avenirNext(size: 24))
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(oceanBlue.yellow))
        }.disabled(!wasEdited)
            .padding()
        
    }
    
    private var deleteAcctButton: some View {
        HStack {
            Spacer()
            Spacer()
        Button(action: deleteAcctTapped) {
            Text("Delete Account")
                .font(.avenirNext(size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.red)
        }.padding(.horizontal)
        }
    }
    
    //MARK: - Methods
    
    private func saveTapped() {
        
        auth.setCurrentUsersName(displayNameInput) { error in
            
            errorManager.shouldDisplay = true
            
            errorManager.message = error.message()
    
        }
        self.dismiss.callAsFunction()
    }
    
    
    private func deleteAcctTapped() {
        self.confirmDeleteAlertShouldShow = true
    }
    

    
}

//MARK: - Preview
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage(userStore: UserStore(),
                    errorManager: ErrorManager(),
                    loginVM: LoginVM())
    }
}

