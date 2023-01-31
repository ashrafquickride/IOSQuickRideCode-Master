//
//  VehicleSettingAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 9/2/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias VehicleSettingAlertControllerActionHandler = (_ result : String) -> Void

class VehicleSettingAlertController {
    
    var alertController : UIAlertController?
    var completionHandler : VehicleSettingAlertControllerActionHandler?
    var viewController :UIViewController?
    
    init(viewController :UIViewController,completionHandler : @escaping VehicleSettingAlertControllerActionHandler){
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
    
    func vehicleInsuranceAlertAction(){
        AppDelegate.getAppDelegate().log.debug("")
        let vehicleInsuranceAlertAction = UIAlertAction(title: Strings.vehicle_insurance, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.completionHandler!(alert.title!)
        })
        alertController?.addAction(vehicleInsuranceAlertAction)
    }
}


