//
//  ConfirmDeleteView.swift
//  SpookySpots
//
//  Created by Spencer Belton on 11/19/22.
//

import SwiftUI

struct ConfirmDeleteView: View {
    
    let weenyWitch = K.Colors.WeenyWitch.self
    let images = K.Images.Login.self
    
    @State var isSecured = true
    
    @State private var shouldShowProgressView = false
    
    @Binding var shouldShow: Bool
    
    @ObservedObject var loginVM: LoginVM
    @ObservedObject var errorManager: ErrorManager
    
    var auth = Authorization.instance

    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                blurredView(geo)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        alertCard(geo)
                        Spacer()
                    }
                    Spacer()
                }
                
                if shouldShowProgressView {
                    ProgressView()
                }
            }
        }
        
    }
    
    //MARK: - Alert View
    
    private func alertCard(_ geo: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            titleView
            subtitleView
            
            emailTextField
            passwordTextField
                .padding(.top, -30)
                .padding(.bottom, 30)
            HStack(spacing: geo.size.width / 7) {
                cancelButton
                deleteButton
            }

        }
        .frame(width: geo.size.width - 60)
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(weenyWitch.black))
    }
    
    
    private var titleView: some View {
        Text("Confirm Delete")
            .font(.avenirNext(size: 22))
            .foregroundColor(weenyWitch.lightest)
            .bold()
    }
    
    private var subtitleView: some View {
        Text("Please enter your credentials to confirm this action.")
            .font(.avenirNext(size: 18))
            .foregroundColor(weenyWitch.lightest)
            .multilineTextAlignment(.center)
    }
    
    private var emailTextField: some View {
        UserInputCellWithIcon(input: $loginVM.emailInput,
                              shouldShowErrorMessage: $loginVM.shouldShowEmailErrorMessage,
                              isSecured: .constant(false),
                              primaryColor: weenyWitch.lightest,
                              accentColor: weenyWitch.orange,
                              icon: images.email,
                              placeholderText: "Email",
                              errorMessage: loginVM.emailErrorMessage)
        
    }
    
    private var passwordTextField: some View {
        UserInputCellWithIcon(input: $loginVM.passwordInput,
                              shouldShowErrorMessage: $loginVM.shouldShowPasswordErrorMessage,
                              isSecured: $isSecured,
                              primaryColor: weenyWitch.lightest,
                              accentColor: weenyWitch.orange,
                              icon: isSecured ? images.eyeWithSlash : images.eye,
                              placeholderText: "Password",
                              errorMessage: loginVM.passwordErrorMessage,
                              canSecure: true)
    }
    
    private var cancelButton: some View {
        Button(action: cancelTapped) {
            Text("Cancel")
                .font(.avenirNext(size: 22))
                .foregroundColor(weenyWitch.lightest)
        }
    }
    
    private var deleteButton: some View {
        Button(action: deleteTapped) {
            Text("DELETE")
                .font(.avenirNext(size: 22))
                .foregroundColor(weenyWitch.orange)
        }
    }
    
    //MARK: - Background
    
    private func blurredView(_ geo: GeometryProxy) -> some View {
        Rectangle()
            .fill(.white.opacity(0.3))
            .frame(width: geo.size.width, height: geo.size.height)
            .blur(radius: 100, opaque: false)
    }
    
    //MARK: - Methods
    
    private func cancelTapped() {
        self.shouldShow = false
    }
    
    private func deleteTapped() {
        loginVM.loginTapped { success in
            if success {
                
                auth.deleteUserAccount { error in
                    
                    errorManager.message = error
                    errorManager.shouldDisplay = true
                    
                } success: { result in
                    
                    if result == true {
                        self.shouldShowProgressView = true
                        self.loginVM.emailInput = ""
                        self.loginVM.passwordInput = ""
                    }
                }
            }
        }
    }
}

struct ConfirmDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmDeleteView(shouldShow: .constant(false),
                          loginVM: LoginVM(),
                          errorManager: ErrorManager())
    }
}
