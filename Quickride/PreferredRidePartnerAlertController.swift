//
//  PreferredRidePartnerAlertController.swift
//  Quickride
//
//  Created by rakesh on 2/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias PreferredRidePartnerAlertControllerActionHandler = (_ result : String) -> Void

class PreferredRidePartnerAlertController{
    
    var alertController : UIAlertController?
    var completionHandler : PreferredRidePartnerAlertControllerActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping PreferredRidePartnerAlertControllerActionHandler){
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
        AppDelegate.getAppDelegate().log.debug("unblockAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.remove, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("addRemoveAlertAction()")
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
    }
    
}
