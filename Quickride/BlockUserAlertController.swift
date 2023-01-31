//
//  BlockUserAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 1/7/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias BlockUserAlertControllerActionHandler = (_ result : String) -> Void

class BlockAlertController {
    
    var alertController : UIAlertController?
    var completionHandler : BlockUserAlertControllerActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping BlockUserAlertControllerActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func profileAlertAction(){
        AppDelegate.getAppDelegate().log.debug("profileAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.profile, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func unblockAlertAction(){
        AppDelegate.getAppDelegate().log.debug("unblockAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.unblock, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func callAlertAction(){
        AppDelegate.getAppDelegate().log.debug("callAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.call, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func showAlertController(){
        AppDelegate.getAppDelegate().log.debug("showAlertController()")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("addRemoveAlertAction()")
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
    }

    func blockAlertAction(){
        AppDelegate.getAppDelegate().log.debug("blockAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.block, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
}
