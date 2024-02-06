//
//  SignUp.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct SignUp: View {
     
    @State var passwordIsSecured = true
    @State var confirmPasswordIsSecured = true
    
    @Binding var index: Int
    
    let geo: GeometryProxy
    
    var auth = Authorization()
    
    let oceanBlue = K.Colors.OceanBlue.self
    let images = K.Images.Login.self
    
    //MARK: - TextField Focus State
    @FocusState private var focusedField: Field?
    
    @ObservedObject var signupVM: SignupVM
    @ObservedObject var errorManager: ErrorManager
        
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack {
                authTypeView
                    .padding(.top, -7)
                VStack(spacing: -18) {
                    userNameField
                    email
                    password
                    confirmPassword
                }
                .padding(.top, -40)
            }
            .padding()
            .padding(.bottom, 45)
            .background(oceanBlue.white)
            .clipShape(CurvedShapeRight())
            .contentShape(CurvedShapeRight())
//            .shadow(color: oceanBlue.yellow.opacity(0.3), radius: 5, x: 0, y: -5)
            .onTapGesture(perform: authTypeSignUpTapped)
            .cornerRadius(45)
            .padding(.horizontal, 20)
            .frame(height: 475)
            signUpButton
        }
        
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .email
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                signupVM.signupTapped()
            default: break
            }
        }
    }
    private var authTypeView: some View {
        HStack {
            Spacer(minLength: 0)
            
            VStack(spacing: 50) {
                Text("Sign Up")
                    .foregroundColor(self.index == 1 ?
                                     oceanBlue.blue : oceanBlue.blue.opacity(0.7))
                    .font(.avenirNext(size: 27))
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.index == 1 ?
                          oceanBlue.blue : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
                
            }
        }
        .padding(.top, 30)
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
    
    //MARK: - Buttons
    
    private var signUpButton: some View {
        Button(action: self.signupTapped) {
            Text("SIGNUP")
                .foregroundColor(oceanBlue.blue)
                .font(.avenirNext(size: 20))
                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(oceanBlue.yellow)
                .clipShape(Capsule())
                .shadow(color: oceanBlue.lightBlue.opacity(0.1),
                        radius: 5, x: 0, y: 5)
        }
        .offset(y: 25)
        .opacity(self.index == 1 ? 1 : 0)
    }

    
    //MARK: - Methods
    
    private func authTypeSignUpTapped() {
        self.index = 1
    }
    
    private func signupTapped() {
        signupVM.signupTapped { success in
            if success {
                //this file is deprecated
            }
        }
    }
      
    //MARK: - Field
    enum Field {
        case username, email, password, confirmPassword
    }
}


//MARK: - Previews
struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SignUp(index: .constant(0),
                   geo: geo,
                   signupVM: SignupVM(),
                   errorManager: ErrorManager())
        }
    }
}

//MARK: - Shape Helper
struct CurvedShapeRight : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 115))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}