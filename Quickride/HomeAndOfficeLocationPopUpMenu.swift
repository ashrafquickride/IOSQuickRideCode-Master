//
//  HomeAndOfficeLocationPopUpMenu.swift
//  Quickride
//
//  Created by QuickRideMac on 14/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias HomeAndOfficeLocationActionHandler = (_ result : String) -> Void

class HomeAndOfficeLocationAlertController {
    var alertController : UIAlertController?
    var completionHandler : HomeAndOfficeLocationActionHandler?
    var viewController :UIViewController?
    init(viewController :UIViewController,completionHandler : @escaping HomeAndOfficeLocationActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func updateAlertAction(){
      AppDelegate.getAppDelegate().log.debug("updateAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.update, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func deleteAlertAction(){
      AppDelegate.getAppDelegate().log.debug("deleteAlertAction()")
        let editAlertAction = UIAlertAction(title: Strings.delete, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func addRemoveAlertAction(){
      AppDelegate.getAppDelegate().log.debug("addRemoveAlertAction()")
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(removeUIAlertAction)
        
    }
    func showAlertController(){
      AppDelegate.getAppDelegate().log.debug("showAlertController()")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    
}
