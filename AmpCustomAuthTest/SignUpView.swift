//
//  SignUpView.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/14/21.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthService
    
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Email", text: $email)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
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
            
            Button("Sign Up", action: {auth.signUp(username: username, password: password, email: email)})
                .padding()
            
            Spacer()
            
            Button("Switch to Sign In", action: {auth.authStatus = .signIn})
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
