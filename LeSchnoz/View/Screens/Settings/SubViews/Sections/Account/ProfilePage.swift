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
    
    @State var usernameErrorMessage = ""
    @State var emailErrorMessge = ""
    
    @State var shouldShowUsernameErrorMessage = false
    @State var shouldShowEmailErrorMessage = false
    
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
        VStack {
            if self.shouldShowUsernameErrorMessage {
                Text(usernameErrorMessage)
                    .foregroundColor(.orange)
            }
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
                    .onChange(of: displayNameInput, perform: wasEdited(_:))
            }
            .padding()
        }
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
                    .disabled(true)
                    .tint(oceanBlue.yellow)
                    .foregroundColor(oceanBlue.white)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .font(.avenirNext(size: 24))
                    .onChange(of: emailInput, perform: wasEdited(_:))

            
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
                .foregroundColor(.orange)
            
        }.padding(.horizontal)
        }
    }
    
    //MARK: - Methods
    
    private func wasEdited(_ value: String) {
        if value == "" {
            wasEdited = false
        } else {
            wasEdited = true
        }
    }
    
    private func handleUsernameAvailability(withCompletion completion: @escaping(Bool) -> Void) {
        auth.checkUsernameAvailability(username: displayNameInput) { success in
            
            guard success else {
                self.setErrorMessage(.username, Fields.username.errorMessage.1)
                completion(false)
                return
            }
            completion(success)
        }
    }
    
    private func setUserName() {
        auth.setCurrentUsersName(displayNameInput) { error in
            
            errorManager.shouldDisplay = true
            errorManager.message = error.message()
            
        }
    }
    
    private func saveTapped() {
        
        if wasEdited {
            if displayNameInput != "" {
                self.handleUsernameAvailability { success in
                    if success {
                        setUserName()
                        //                    self.dismiss.callAsFunction()
                    }
                }
                
            }

            
        }
    }
    
    
    private func deleteAcctTapped() {
        self.confirmDeleteAlertShouldShow = true
    }
    

        private func fieldsAreFilled() -> Bool {
            self.displayNameInput != "" && self.emailInput != ""
        }
    
    enum Fields {

        case username, email
        
        var errorMessage: (String,String) {
            let messages = K.ErrorHelper.Messages.Auth.self
            switch self {
            case .username:
                return (messages.usernameBlank.rawValue , messages.usernameExists.rawValue)
            case .email:
                return (messages.emailBlank.rawValue , messages.emailInUse.rawValue)
            }
        }
    }
    
    private func setErrorMessage(_ field: Fields, _ message: String) {
        switch field {
        case .username:
            self.usernameErrorMessage = message
            self.shouldShowUsernameErrorMessage = true
        case .email:
            self.emailErrorMessge = message
            self.shouldShowEmailErrorMessage = true
        }
    }
    
    private func checkForErrors() {
        if displayNameInput == "" {
            setErrorMessage(.username, Fields.username.errorMessage.0)
        } else {
            self.shouldShowUsernameErrorMessage = false
        }
        
        if emailInput == "" {
            setErrorMessage(.email, Fields.username.errorMessage.0)
        } else {
            self.shouldShowEmailErrorMessage = false
        }
    }
    
    
}

//MARK: - Preview
struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage(userStore: UserStore(),
                    errorManager: ErrorManager.instance,
                    loginVM: LoginVM())
    }
}

