//
//  SignInView.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/14/21.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthService
    
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            
            TextField("Username", text: $username)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Password", text: $password)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Sign In", action: {auth.signIn(username: username, password: password)})
                .padding()
            
            Spacer()
            
            Button("Forgot Password", action: { auth.resetPassword(username: username)})
                .disabled(self.username.isEmpty)
            
            Button("Switch to Sign Up", action: {auth.authStatus = .signUp})
                .padding()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
