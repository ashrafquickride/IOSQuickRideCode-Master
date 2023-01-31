//
//  LinkedWalletAlertController.swift
//  Quickride
//
//  Created by iDisha on 19/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias LinkedWalletAlertControllerActionHandler = (_ result : String) -> Void

class LinkedWalletAlertController {
    
    var alertController : UIAlertController?
    var completionHandler : LinkedWalletAlertControllerActionHandler?
    var viewController : UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping LinkedWalletAlertControllerActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func defaultAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let makeDefaultAction = UIAlertAction(title: Strings.make_default, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(makeDefaultAction)
    }
    func removeAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let removeAlertAction = UIAlertAction(title: Strings.remove, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(removeAlertAction)
    }
    func showAlertController(){
        AppDelegate.getAppDelegate().log.debug("")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
    }
    
    func reLinkAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let reLinkAlertAction = UIAlertAction(title: Strings.relink, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(reLinkAlertAction)
    }
}
