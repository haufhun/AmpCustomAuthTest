//
//  ResetPasswordView.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/14/21.
//

import SwiftUI

struct ConfirmResetPassword: View {
    @EnvironmentObject var auth: AuthService
    
    @State private var username = ""
    @State private var newPassword = ""
    @State private var confirmationCode = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("New Password", text: $newPassword)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Confirm Code", text: $confirmationCode)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button("Password Reset", action: {auth.confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode)})
                .padding()
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmResetPassword()
    }
}
