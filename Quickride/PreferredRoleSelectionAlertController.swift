//
//  PreferredRoleSelectionAlertController.swift
//  Quickride
//
//  Created by KNM Rao on 10/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias selectPreferredRoleCompletionHandler = (_ preferredRole: String) -> Void

class PreferredRoleSelectionAlertController {

var viewController :UIViewController?

init(viewController :UIViewController){
  self.viewController = viewController
}

func displayPreferredRoleController(handler : @escaping selectPreferredRoleCompletionHandler){
  AppDelegate.getAppDelegate().log.debug("displayCallPreferencesAlertController()")
  let optionMenu = UIAlertController(title: "Preferred Role", message: nil, preferredStyle: .actionSheet)
  for preferredRole in Strings.preferredRoleOptions{
    
    let action = UIAlertAction(title: preferredRole, style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      for selectedOption in Strings.preferredRoleOptions{
        if selectedOption == preferredRole{
          if (selectedOption == Strings.find_and_offer_ride){
            handler("Both")
          }else{
            handler(selectedOption)
          }
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
