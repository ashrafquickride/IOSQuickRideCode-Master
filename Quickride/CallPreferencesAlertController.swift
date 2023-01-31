//
//  CallPreferencesAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 09/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


typealias selectCallPreferencesCompletionHandler = (_ selectedCallPreference: (String,String)) -> Void
class CallPreferencesAlertController {
    
    var viewController :UIViewController?
    
    init(viewController :UIViewController){
        self.viewController = viewController
    }
    
    func displayCallPreferencesAlertController(handler : @escaping selectCallPreferencesCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("displayCallPreferencesAlertController()")
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for callPreference in UserProfile.callPreferences{
        let action = UIAlertAction(title: callPreference, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                for selectedOption in UserProfile.supportCallValues{
                    if selectedOption.0 == callPreference{
                         handler(selectedOption)
                    }
                }
               
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
