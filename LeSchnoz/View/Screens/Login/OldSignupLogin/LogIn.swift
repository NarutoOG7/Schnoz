//
//  LogIn.swift
//  SpookySpots
//
//  Created by Spencer Belton on 8/25/22.
//

import SwiftUI

struct LogIn: View {
    
    @State var isSecured = true
    
    @Binding var index: Int
    
    let geo: GeometryProxy
    
    let oceanBlue = K.Colors.OceanBlue.self
    let images = K.Images.Login.self
    
    @FocusState private var focusedField: Field?
    
    @ObservedObject var loginVM: LoginVM
    @ObservedObject var errorManager: ErrorManager
            
    var body: some View {
            
                ZStack(alignment: .bottom) {
                    
                    VStack {
                        
                        HStack {
                            authTypeView(.login)
//                            authTypeView(.signup)
                        }
                        email
                        password
                        forgotPasswordButton
                    }
                    .padding()
                    .padding(.bottom, 65)
                    .background(oceanBlue.white)
                    .clipShape(CurvedShapeLeft())
                    .contentShape(CurvedShapeLeft())
//                    .shadow(color: oceanBlue.yellow.opacity(0.3), radius: 5, x: 0, y: -5)
//                    .onTapGesture(perform: authTypeLoginTapped)
                    .cornerRadius(45)
                    .padding(.horizontal, 20)
                    .frame(height: 475)
                    
                    loginButton
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
    
    private func authTypeView(_ authType: AuthType) -> some View {
        Button {
            self.authTypeLoginTapped(authType)
        } label: {
            
            HStack {
                VStack(spacing: 50) {
                    Text(authType.rawValue.uppercased())
                        .foregroundColor(self.index == authType.index ?
                                         oceanBlue.blue : oceanBlue.blue.opacity(0.7))
                        .font(.avenirNext(size: 27))
                        .fontWeight(.bold)
                    
                    Capsule()
                        .fill(self.index == 0 ?
                              oceanBlue.blue : Color.clear)
                        .frame(width: 90, height: 4)
                        .offset(y: -35)
                    
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 30)
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
    
    private var loginButton: some View {
        Button(action: self.loginTapped) {
            Text("LOGIN")
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
        .opacity(self.index == 0 ? 1 : 0)
    }
    
    
    //MARK: - Methods
    
    private func authTypeLoginTapped(_ authType: AuthType) {
        self.index = authType.index
    }
    
    private func loginTapped() {
        loginVM.loginTapped()
    }


    //MARK: - Field
    enum Field {
        case email, password
    }
}

//MARK: - Previews
struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            LogIn(index: .constant(0),
                  geo: geo,
                  loginVM: LoginVM(),
                  errorManager: ErrorManager())
            .background(.yellow)
        }
    }
}

//MARK: - Shape Helper
struct CurvedShapeLeft : Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: 125))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct CurvedRectnagle: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}
