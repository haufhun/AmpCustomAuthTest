//
//  SessionView.swift
//  AmpCustomAuthTest
//
//  Created by Hunter Haufler on 2/14/21.
//

import SwiftUI

struct UserInfo {
    var lastUpdated = Date()
    
    var currentUserSub = ""
    var currentIdentityId = ""
    var currentAccessKey = ""
    
    var currentAccessToken = ""
    var currentIdToken = ""
    var currentRefreshToken = ""
}

struct SessionView: View {
    @EnvironmentObject var auth: AuthService
    
    @AppStorage("lastSignIn") var lastSignIn = ""
    
    @AppStorage("userSub") var userSub = ""
    @AppStorage("identityId") var identityId = ""
    @AppStorage("accessKey") var accessKey = ""
    
    @AppStorage("accessToken") var accessToken = ""
    @AppStorage("idToken") var idToken = ""
    @AppStorage("refreshToken") var refreshToken = ""
    
    @State private var userInfo = UserInfo()
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            
            Group {
                Text("At Sign In")
                    .font(.title)
                
                Text("Last sign in time: \(lastSignIn)")
                
                Text("\(userSub)")
                Text("\(identityId)")
                Text("Access Key - \(accessKey)")
                
                Text("Access Token - \(accessToken)")
                Text("Id Token - \(idToken)")
                Text("Refresh Token - \(refreshToken)")
            }
            
            Spacer()
            
            Group {
                Text("Current...")
                    .font(.title)
                
                Text("Last updated - \(userInfo.lastUpdated)")
                
                Text("\(userInfo.currentUserSub)")
                Text("\(userInfo.currentIdentityId)")
                Text("Access Key - \(userInfo.currentAccessKey)")
                
                Text("Access Token - \(userInfo.currentAccessToken)")
                Text("Id Token - \(userInfo.currentIdToken)")
                Text("Refresh Token - \(userInfo.currentRefreshToken)")
            }
            
            Button("Update auth session details", action: updateAuthSessionDetails)
            
            Spacer()
            Spacer()
            
            Button("Sign Out", action: auth.signOut)
            Button("Global Sign Out", action: auth.signOutGlobally)
                .padding(.top)
        }
        .onAppear(perform: updateAuthSessionDetails)
    }
    
    func updateAuthSessionDetails() {
        auth.updateAuthSessionDetails(updateUI: { newUserInfo in
            userInfo = newUserInfo
        })
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
