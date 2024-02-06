//
//  SignupLogin.swift
//  LeSchnoz
//
//  Created by Spencer Belton on 3/30/23.
//

import SwiftUI


struct SignupLogin: View {
    
    let oceanBlue = K.Colors.OceanBlue.self
    
    @State var selectedAuthType: AuthType = .login
    @State var firebaseErrorMessage = ""
    @State var showingAlertForFirebaseError = false
        
    @ObservedObject var errorManager = ErrorManager.instance
    @ObservedObject var loginVM = LoginVM.instance
    @ObservedObject var signUpVM = SignupVM.instance
    
    var body: some View {
        ZStack {
            oceanBlue.blue.ignoresSafeArea()
            VStack {
                logo
                ZStack(alignment: .bottom) {
                    authCard
                    submitButton
                }
                orDivider
                guestButton
            }
        }
        .alert("Firebase Error", isPresented: $showingAlertForFirebaseError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(K.ErrorHelper.Messages.Network.firebaseConnection.rawValue)
        }
    }
    
    var authCard: some View {
        VStack(alignment: .center) {
            HStack(spacing: 110) {
                authTypeButton(.login)
                authTypeButton(.signup)
            }
            switch selectedAuthType {
            case .login:
                NewLogin()
                    .offset(y: -20)
            case .signup:
                NewSignup()
                    .offset(y: -20)
            }
        }
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 40).padding().foregroundColor(oceanBlue.white))
    }
    
    var logo: some View {
        Image("SchnozLogoOutline")
            .resizable()
            .frame(width: 150)
            .aspectRatio(3.3, contentMode: .fit)
            .padding(.bottom)
    }
    
    private var orDivider: some View {
        HStack(spacing: 15) {
            
            Rectangle()
                .fill(oceanBlue.white)
                .frame(height: 1)
            
            Text("OR")
                .foregroundColor(oceanBlue.white)
                .font(.avenirNext(size: 20))
            
            Rectangle()
                .fill(oceanBlue.white)
                .frame(height: 1)
            
        }
        .padding(.horizontal, 30)
        .padding(.top, 55)
    }
    
    
    //MARK: - Buttons
    
    private func authTypeButton(_ authType: AuthType) -> some View {
        Button {
            authTypeTapped(authType)
        } label: {
            VStack(spacing: 40) {
                Text(authType.rawValue.uppercased())
                    .foregroundColor(self.selectedAuthType == authType ?
                                     oceanBlue.blue : oceanBlue.blue.opacity(0.7))
                    .font(.avenirNext(size: 27))
                    .fontWeight(.bold)
                
                Capsule()
                    .fill(self.selectedAuthType == authType ?
                          oceanBlue.blue : Color.clear)
                    .frame(width: 90, height: 4)
                    .offset(y: -35)
            }
        }
    }

        private var guestButton: some View {
            Button(action: continueAsGuestTapped) {
                Text("Continue As Guest")
                    .font(.avenirNext(size: 23))
                    .fontWeight(.light)
                    .italic()
                    .foregroundColor(oceanBlue.yellow)
                    .padding()
            }
        }
    
    private var submitButton: some View {
        Button(action: self.submitTapped) {
            Text(selectedAuthType.rawValue.uppercased())
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
    }
    
    //MARK: - Methods
    
    func authTypeTapped(_ authType: AuthType) {
        self.selectedAuthType = authType
    }
    
    func submitTapped() {
        switch selectedAuthType {
        case .login:
            loginVM.loginTapped(withCompletion: handleSuccess(_:))
        case .signup:
            signUpVM.signupTapped(withCompletion: handleSuccess(_:))
        }
        func handleSuccess(_ success: Bool) {
            if success {
                loginVM.reset()
            }
        }
    }

    
    private func continueAsGuestTapped() {
        
        Authorization.instance.anonymousSignIn { error in
            
            if error == .troubleConnectingToFirebase {
                self.firebaseErrorMessage = error.message()
                self.showingAlertForFirebaseError = true
            }
            
            DispatchQueue.main.async {
                UserStore.instance.isGuest = true
            }
        }

    }

}

struct SignupLogin_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            K.Colors.OceanBlue.blue
                .ignoresSafeArea()
            SignupLogin()
        }
    }
}



