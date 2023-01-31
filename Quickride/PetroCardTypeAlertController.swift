//
//  PetroCardTypeAlertController.swift
//  Quickride
//
//  Created by KNM Rao on 25/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
typealias selectedPetroCardTypeCompletionHandler = (_ petrolCard: String) -> Void

class PetroCardTypeAlertController {
    var viewController :UIViewController?
    var availablePetrolCards : [String]?
  init(viewController :UIViewController, availablePetrolCards : [String]){
    self.viewController = viewController
    self.availablePetrolCards = availablePetrolCards
  }
  
  func displayPetroCardTypeAlertController(handler : @escaping selectedPetroCardTypeCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("displayPetroCardTypeAlertController()")
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    for card in availablePetrolCards!{
      let action = UIAlertAction(title: card, style: .default, handler: {
        (alert: UIAlertAction!) -> Void in
        handler(card)
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
