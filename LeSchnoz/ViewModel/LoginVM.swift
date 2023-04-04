//
//  LoginVM.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/15/22.
//

import SwiftUI

class LoginVM: ObservableObject {
    
    static let instance = LoginVM()
    
    @Published var emailInput = ""
    @Published var passwordInput = ""
    
    @Published var showingAlertPasswordReset = false
    
    //MARK: - Error Message Helpers
    @Published var shouldShowEmailErrorMessage = false
    @Published var shouldShowPasswordErrorMessage = false

    @Published var emailErrorMessage = ""
    @Published var passwordErrorMessage = ""
    
    @ObservedObject var network = NetworkManager.instance
    @ObservedObject var errorManager = ErrorManager.instance

    var auth = Authorization()
    
    func reset() {
        emailInput = ""
        passwordInput = ""
    }


    func loginTapped(withCompletion completion: @escaping(Bool) -> Void = {_ in}) {
        
        guard isConnectedToNetwork() else {
            setErrorMessage(.firebase, message: "Please check your network connection and try again.")
            return
        }
        
        checkForErrorAndSendAppropriateErrorMessage()
        
        if fieldsAreFilled() {
            
            auth.signIn(email: emailInput, password: passwordInput) { success in
                if success {
                    completion(true)
                }
            } error: { error in
                self.handleError(error)
            }

        }
    }
    
    private func fieldsAreFilled() -> Bool {
        emailInput != "" && passwordInput != ""
    }
    
    func forgotPasswordTapped() {
        
        auth.passwordReset(email: emailInput) { result in
            
            if result == true {
                
                self.showingAlertPasswordReset = true
            }
        } error: { error in
            
            if error == .firebaseTrouble {
                
                self.errorManager.shouldDisplay = true
                
            }
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        network.connected
    }
    
    
    //MARK: - Errors
    
    private func handleError(_ error: K.ErrorHelper.Errors) {
        switch error {
            
        case .incorrectEmail,
                .unrecognizedEmail,
                .emailIsBadlyFormatted,
                .emailInUse:
            self.setErrorMessage(.email, message: error.message())
             
        case .incorrectPassword,
                .insufficientPassword:
            self.setErrorMessage(.password, message: error.message())
            
        case .passwordsDontMatch:
            self.setErrorMessage(.confirmPassword, message: error.message())
            
        case .failedToSaveUser,
                .troubleConnectingToFirebase,
                .firebaseTrouble:
            self.setErrorMessage(.firebase, message: error.message())

        }
    }
    
    private func setErrorMessage(_ type: K.ErrorHelper.ErrorType, message: String) {
        
        switch type {
        
        case .email:
            self.emailErrorMessage = message
            self.shouldShowEmailErrorMessage = true
            
        case .password:
            self.passwordErrorMessage = message
            self.shouldShowPasswordErrorMessage = true
            
        default:
            errorManager.message = message
            errorManager.shouldDisplay = true
            
        }
    }
    
    private func checkForErrorAndSendAppropriateErrorMessage() {
        
        if emailInput == "" {
            setErrorMessage(.email, message: "Please provide an email address.")
        } else {
            self.shouldShowEmailErrorMessage = false
        }
        
        if passwordInput == "" {
            setErrorMessage(.password, message: "Please provide a password.")
        } else {
            self.shouldShowPasswordErrorMessage = false
        }
    }
    
}
