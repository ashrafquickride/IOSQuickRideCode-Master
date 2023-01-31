//
//  FavoriteLocationAlertController.swift
//  Quickride
//
//  Created by Vinutha on 4/18/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias FavoriteLocationAlertControllerActionHandler = (_ result : String) -> Void

class FavoriteLocationAlertController{
    
    var alertController : UIAlertController?
    var completionHandler : FavoriteLocationAlertControllerActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping FavoriteLocationAlertControllerActionHandler){
        self.viewController = viewController
        self.completionHandler = completionHandler
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController?.view.tintColor = Colors.alertViewTintColor
    }
    func showAlertController(){
        AppDelegate.getAppDelegate().log.debug("")
        viewController!.present(alertController!, animated: false, completion: {
            self.alertController!.view.tintColor = Colors.alertViewTintColor
        })
    }
    func editAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let editAlertAction = UIAlertAction(title: Strings.edit, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(editAlertAction)
    }
    func removeAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let removeAlertAction = UIAlertAction(title: Strings.remove, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(removeAlertAction)
    }
    func cancelAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let cancelUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        alertController!.addAction(cancelUIAlertAction)
    }
    
}
