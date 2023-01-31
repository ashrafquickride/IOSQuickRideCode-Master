//
//  RidePartnerContactAlertController.swift
//  Quickride
//
//  Created by Vinutha on 8/18/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias RidePartnerContactAlertControllerActionHandler = (_ result : String) -> Void

class RidePartnerContactAlertController{
    
    var alertController : UIAlertController?
    var completionHandler : RidePartnerContactAlertControllerActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping RidePartnerContactAlertControllerActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func showAlertController(){
        AppDelegate.getAppDelegate().log.debug("showAlertController()")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    
    func removeAlertAction(){
        AppDelegate.getAppDelegate().log.debug("removeAlertAction()")
        let removeAlertAction = UIAlertAction(title: Strings.remove, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(removeAlertAction)
    }
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("cancelAlertAction()")
        let cancelAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(cancelAlertAction)
    }
    func contactAlertAction(){
        AppDelegate.getAppDelegate().log.debug("contactAlertAction()")
        let contactAlertAction = UIAlertAction(title: Strings.call, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController!.addAction(contactAlertAction)
    }
}
