//
//  GoogleLogInManager.swift
//  Quickride
//
//  Created by Admin on 15/10/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation
import GoogleSignIn


 //Handling Google Login
class GoogleLoginManager {
    
    class func configureGoogleClientID() {
        GIDSignIn.sharedInstance().clientID = AppConfiguration.GOOGLE_CLIENT_ID
    }
    
    class func setUpDelegate(googleLoginDelegate: GIDSignInDelegate!, viewController: UIViewController) {
        GIDSignIn.sharedInstance()?.delegate = googleLoginDelegate
        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    class func handleGoogleSourceApplicationAnnotation(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    class func handleGoogleApplicationOptions(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    class func getLoginDetail(user: GIDGoogleUser?, error: Error?) -> GoogleSocialUserProfile?{
        if let error = error {
            print(error.localizedDescription)
            return nil
        }
        guard let user = user else {
            return nil
        }
        
        return GoogleSocialUserProfile(userId: user.userID, givenName: user.authentication.idToken, familyName: user.profile.familyName, fullName: user.profile.name, providerId: GoogleSocialUserProfile.socialNetworkTypeGoogle, email: user.profile.email, imageUrl: user.profile.hasImage ? user.profile.imageURL(withDimension: 600)?.absoluteString : nil )
        
    }
}
