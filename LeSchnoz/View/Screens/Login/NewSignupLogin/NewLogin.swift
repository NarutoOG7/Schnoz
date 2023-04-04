//
//  NewLogin.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import SwiftUI

struct NewLogin: View {
    
    let oceanBlue = K.Colors.OceanBlue.self
    let images = K.Images.Login.self
    
    @State var isSecured = true
    
    @FocusState private var focusedField: Field?
    
    @ObservedObject var loginVM = LoginVM.instance

    var body: some View {
        VStack {
            email
            password
            forgotPasswordButton
        }
        .alert("Email Sent", isPresented: $loginVM.showingAlertPasswordReset) {
            Button("OK", role: .cancel) { }
        }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                loginVM.loginTapped()
            default: break
            }
        }
    }
    
    
    private var email: some View {
        UserInputCellWithIcon(
            input: $loginVM.emailInput,
            shouldShowErrorMessage: $loginVM.shouldShowEmailErrorMessage,
            isSecured: .constant(false),
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: images.email,
            placeholderText: "Email Address",
            errorMessage: loginVM.emailErrorMessage)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }
    
    
    private var password: some View {
        UserInputCellWithIcon(
            input: $loginVM.passwordInput,
            shouldShowErrorMessage: $loginVM.shouldShowPasswordErrorMessage,
            isSecured: $isSecured,
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: isSecured ? images.eyeWithSlash : images.eye,
            placeholderText: "Password",
            errorMessage: loginVM.passwordErrorMessage,
            canSecure: true)
        .focused($focusedField, equals: .password)
        .submitLabel(.done)
    }
    
    //MARK: - Buttons
    
    private var forgotPasswordButton: some View {
        HStack {
            Spacer(minLength: 0)
            
            Button(action: loginVM.forgotPasswordTapped) {
                Text("Forgot Password?")
                    .font(.avenirNext(size: 18))
                    .foregroundColor(oceanBlue.lightBlue)
            }
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    enum Field {
        case email, password
    }
}


struct NewLogin_Previews: PreviewProvider {
    static var previews: some View {
        NewLogin()
    }
}
