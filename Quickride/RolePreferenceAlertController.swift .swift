//
//  RolePreferenceAlertController.swift .swift
//  Quickride
//
//  Created by QuickRideMac on 11/21/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias selectRolePreferencesCompletionHandler = (_ selectedRolePreference: String) -> Void
class RolePreferenceAlertController {
    
    var viewController :UIViewController?
    
    init(viewController :UIViewController){
        self.viewController = viewController
    }
    let RoleTypes = [UserProfile.PREFERRED_ROLE_RIDER,UserProfile.PREFERRED_ROLE_PASSENGER,UserProfile.PREFERRED_ROLE_BOTH]

    func displayRolePreferenceAlertController(handler : @escaping selectRolePreferencesCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("displayRolePreferenceAlertController()")
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for role in RoleTypes{
            let action = UIAlertAction(title: role, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                handler(role)
            })
            optionMenu.addAction(action)
            
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        
        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.viewController!.present(optionMenu, animated: false, completion: {
           optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
    
}
