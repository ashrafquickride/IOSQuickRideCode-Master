//
//  PreferredVehicleAlertController.swift
//  Quickride
//
//  Created by KNM Rao on 10/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
typealias selectPreferredVehicleAsPassengerCompletionHandler = (_ preferredVehicle: String) -> Void
class PreferredVehicleAlertController {
  
    var viewController :UIViewController?
    
    init(viewController :UIViewController){
      self.viewController = viewController
    }
    
    func displayPreferredVehicleController(handler : @escaping selectPreferredVehicleAsPassengerCompletionHandler){
      AppDelegate.getAppDelegate().log.debug("displayPreferredVehicleController()")
      let optionMenu = UIAlertController(title: "Preferred Vehicle", message: nil, preferredStyle: .actionSheet)
      for preferredRole in Strings.preferredVehicleOptions{
        
        let action = UIAlertAction(title: preferredRole, style: .default, handler: {
          (alert: UIAlertAction!) -> Void in
          for selectedOption in Strings.preferredVehicleOptions{
            if selectedOption == preferredRole{
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
