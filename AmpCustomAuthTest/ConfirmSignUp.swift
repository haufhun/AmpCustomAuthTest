//
//  ConfirmSignUp.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/14/21.
//

import SwiftUI

struct ConfirmSignUp: View {
    @EnvironmentObject var auth: AuthService
    
    @State private var username = ""
    @State private var confirmationCode = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            TextField("Confirm Code", text: $confirmationCode)
                .padding([.leading, .trailing])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button("Confirm Sign Up", action: {auth.confirmSignUp(for: username, with: confirmationCode)})
                .padding()
        }
    }
}

struct ConfirmSignUp_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmSignUp()
    }
}
