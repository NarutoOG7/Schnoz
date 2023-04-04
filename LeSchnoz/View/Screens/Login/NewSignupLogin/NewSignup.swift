//
//  NewSignup.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/31/23.
//

import SwiftUI


struct NewSignup: View {
    
    let oceanBlue = K.Colors.OceanBlue.self
    let images = K.Images.Login.self
    
    @State var passwordIsSecured = true
    @State var confirmPasswordIsSecured = true
    
    @FocusState private var focusedField: Field?
    
    @ObservedObject var signupVM = SignupVM.instance
    
    var body: some View {
            VStack(spacing: -18) {
                userNameField
                email
                password
                confirmPassword
            }
            .padding(.top, -40)

    }
    
    private var userNameField: some View {
        UserInputCellWithIcon(
            input: $signupVM.usernameInput,
            shouldShowErrorMessage: $signupVM.shouldShowUserNameErrorMessage,
            isSecured: .constant(false),
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: Image(systemName: "person.fill"),
            placeholderText: "Your Name",
            errorMessage: "Please provide a name.")
        .focused($focusedField, equals: .username)
        .submitLabel(.next)
    }
    

    
    private var email: some View {
        UserInputCellWithIcon(
            input: $signupVM.emailInput,
            shouldShowErrorMessage: $signupVM.shouldShowEmailErrorMessage,
            isSecured: .constant(false),
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: images.email,
            placeholderText: "Email Address",
            errorMessage: signupVM.emailErrorMessage)
        .focused($focusedField, equals: .email)
        .submitLabel(.next)
    }

    private var password: some View {
        UserInputCellWithIcon(
            input: $signupVM.passwordInput,
            shouldShowErrorMessage: $signupVM.shouldShowPasswordErrorMessage,
            isSecured: $passwordIsSecured,
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: passwordIsSecured ? images.eyeWithSlash : images.eye,
            placeholderText: "Password",
            errorMessage: signupVM.passwordErrorMessage,
            canSecure: true)
        .focused($focusedField, equals: .password)
        .submitLabel(.next)
    }
    
    private var confirmPassword: some View {
        UserInputCellWithIcon(
            input: $signupVM.confirmPasswordInput,
            shouldShowErrorMessage: $signupVM.shouldShowConfirmPasswordError,
            isSecured: $confirmPasswordIsSecured,
            primaryColor: oceanBlue.blue,
            accentColor: oceanBlue.lightBlue,
            icon: confirmPasswordIsSecured ? images.eyeWithSlash : images.eye,
            placeholderText: "Confirm Password",
            errorMessage: K.ErrorHelper.Messages.Auth.passwordsDontMatch.rawValue,
            canSecure: true)
        .focused($focusedField, equals: .confirmPassword)
        .submitLabel(.done)
    }
    
    enum Field {
        case username, email, password, confirmPassword
    }
}


struct NewSignup_Previews: PreviewProvider {
    static var previews: some View {
        NewSignup()
    }
}
