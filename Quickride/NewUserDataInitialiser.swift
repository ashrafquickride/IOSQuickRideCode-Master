//
//  NewUserDataInitialisationViewController.swift
//  Quickride
//
//  Created by Admin on 21/12/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class NewUserDataInitialiser: UserSessionInitialiser
{
    
    override func initializeUserSession()
    {
        self.updateAppVersionToServer(userId: StringUtils.getStringFromDouble(decimalNumber : self.userId))
        self.updateUserDeviceIdToServer()
        SharedPreferenceHelper.storeUserObject(userObj: userObj!)
        SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile)
        AppStartUpUtils.checkViewControllerAndNavigate(viewController: self.viewController)
    }
}
