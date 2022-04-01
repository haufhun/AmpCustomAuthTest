//
//  AuthService.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/12/21.
//

import Amplify
import Foundation
import AWSPluginsCore

enum AuthStatus {
    case signUp
    case confirmSignUp
    case confirmResetPasssword
    case signIn
    case session
}

class AuthService: ObservableObject {
    @Published var authStatus = AuthStatus.signIn
    
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession { [weak self] result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                DispatchQueue.main.async {
                    self?.authStatus = session.isSignedIn ? .session : .signIn
                }
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }
    
    func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
            print("Found \(result.eventName) event")
            
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async {
                    self?.authStatus = .session
                }
                
            case HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.sessionExpired:
                DispatchQueue.main.async {
                    self?.authStatus = .signIn
                }
                
            default:
                break
            }
        }
    }
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                print("Sign in succeeded")
                self?.setAuthSessionDetails()
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    
    func setAuthSessionDetails() {
        
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let str = df.string(from: Date())
        UserDefaults.standard.set(str, forKey: "lastSignIn")
        
        _ = Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()

                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
                    print("User sub - \(usersub) and identity id \(identityId)")
                    
                    UserDefaults.standard.set(usersub, forKey: "userSub")
                    UserDefaults.standard.set(identityId, forKey: "identityId")
                }

                // Get aws credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                    print("Access key - \(credentials.accessKey) ")
                    
                    UserDefaults.standard.set(credentials.accessKey, forKey: "accessKey")
                }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    print("Id token - \(tokens.idToken) ")
                    print("Refresh token - \(tokens.refreshToken)")
                    
                    UserDefaults.standard.set(tokens.accessToken.suffix(8), forKey: "accessToken")
                    UserDefaults.standard.set(tokens.idToken.suffix(8), forKey: "idToken")
                    UserDefaults.standard.set(tokens.refreshToken.suffix(8), forKey: "refreshToken")
                }

            } catch {
                print("Fetch auth session failed with error - \(error)")
            }
        }
    }
    
    func updateAuthSessionDetails(updateUI: @escaping (UserInfo) -> Void) {
        
        _ = Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()
                var userInfo = UserInfo()

                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
                    
                    userInfo.currentUserSub = usersub
                    userInfo.currentIdentityId = identityId
                }

                // Get aws credentials
                if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                    let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                    
                    userInfo.currentAccessKey = credentials.accessKey
                }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()

                    userInfo.currentAccessToken = "\(tokens.accessToken.suffix(8))"
                    userInfo.currentIdToken = "\(tokens.idToken.suffix(8))"
                    userInfo.currentRefreshToken = "\(tokens.refreshToken.suffix(8))"
                }
                
                updateUI(userInfo)

            } catch {
                print("Fetch auth session failed with error - \(error)")
            }
        }
    }
    
    func signOut() {
        _ = Amplify.Auth.signOut { result in
            switch result {
            case .success:
                print("Signed out")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func signOutGlobally() {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) { result in
            switch result {
            case .success:
                print("Successfully signed out globally")
            case .failure(let error):
                print("Global Sign out failed with error \(error)")
            }
        }
    }
    
    
    // MARK: Other methods
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        Amplify.Auth.signUp(username: username, password: password, options: options) { [weak self] result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    DispatchQueue.main.async {
                        self?.authStatus = .confirmSignUp
                    }
                } else {
                    print("SignUp Complete")
                    DispatchQueue.main.async {
                        self?.authStatus = .signIn
                    }
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                self.authStatus = .signIn
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    func resetPassword(username: String) {
        Amplify.Auth.resetPassword(for: username) { [weak self] result in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                    self?.authStatus = .confirmResetPasssword
                case .done:
                    print("Reset completed")
                    self?.authStatus = .signIn
                }
            } catch {
                print("Reset password failed with error \(error)")
            }
        }
    }
    
    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) {
        Amplify.Auth.confirmResetPassword(for: username, with: newPassword, confirmationCode: confirmationCode) { [weak self] result in
            switch result {
            case .success:
                print("Password reset confirmed")
                self?.authStatus = .signIn
            case .failure(let error):
                print("Reset password failed with error \(error)")
            }
        }
    }
    
}
