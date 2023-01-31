//
//  VehicleSelectionAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 9/5/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias VehicleSelectionAlertControllerActionHandler = (_ result : Vehicle?) -> Void

class VehicleSelectionAlertController {
    
    var viewController :UIViewController?
    var vehicleList : [Vehicle]?
    
    init(viewController :UIViewController){
        self.viewController = viewController
        self.vehicleList = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
    }
        func displayVehicleListAlertController(handler : @escaping VehicleSelectionAlertControllerActionHandler){
            AppDelegate.getAppDelegate().log.debug("")
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if vehicleList != nil && vehicleList!.count > 0
            {
                for vehicle in vehicleList!{
                    let action = UIAlertAction(title: vehicle.vehicleType!+"-"+vehicle.vehicleModel+"-"+vehicle.registrationNumber, style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        handler(vehicle)
                    })
                    optionMenu.addAction(action)
                }
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
