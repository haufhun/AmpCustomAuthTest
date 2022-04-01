//
//  AmpCustomAuthTestApp.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/12/21.
//

import Amplify
import AmplifyPlugins
import SwiftUI

@main
struct AmpCustomAuthTestApp: App {
    @ObservedObject private var auth = AuthService()
        
    init() {
        configureAmplify()
        
        auth.fetchCurrentAuthSession()
        auth.observeAuthEvents()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.authStatus {
                case .signUp:
                    SignUpView()
                    
                case .confirmSignUp:
                    ConfirmSignUp()
                    
                case .confirmResetPasssword:
                    ConfirmResetPassword()
                    
                case .signIn:
                    SignInView()
                    
                case .session:
                    SessionView()
                }
            }.environmentObject(auth)
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
    }
}
