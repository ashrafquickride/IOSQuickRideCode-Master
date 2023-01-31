//
//  LiveRideMenuActions.swift
//  Quickride
//
//  Created by Quick Ride on 3/28/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit


class LiveRideMenuActions {

    var alertController : UIAlertController
    var ride : Ride?
    var rideUpdateListener : RideObjectUdpateListener?
    var rideActionDelegate : RideActionDelegate?
    var isFromRideView = false
    var riderRide : RiderRide?
    init(ride :Ride){
        self.ride = ride
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    }

    func addFreezeAction(  _ handler: @escaping(_ freeze: Bool)-> Void){

        guard let riderRide = self.ride as? RiderRide else {
            return
        }
        if  riderRide.freezeRide {
            let freezeItem = UIAlertAction(title: Strings.unFreeze_ride, style: .default, handler: { action in
                self.alertController.dismiss(animated: false, completion: nil)
                handler(false)
            })
            alertController.addAction(freezeItem)
        }else{
            let freezeItem = UIAlertAction(title: Strings.freeze_ride,style: .default, handler: {  action in
                self.alertController.dismiss(animated: false, completion: nil)
                handler(true)
            })
            alertController.addAction(freezeItem)
        }
    
        
    }
    func addChangeRoleAction( _ handler : @escaping() -> Void)  {
        if let riderRide = ride as? RiderRide, riderRide.noOfPassengers < 1 {
            let changeRole = UIAlertAction(title: Strings.change_role, style: .default) { action in
                self.alertController.dismiss(animated: false, completion: nil)
                handler()
            }
            alertController.addAction(changeRole)
            
        }else if let passengerRide = ride as? PassengerRide, passengerRide.status == Ride.RIDE_STATUS_REQUESTED{
            let changeRole = UIAlertAction(title: Strings.change_role, style: .default) { action in
                self.alertController.dismiss(animated: false, completion: nil)
                handler()
            }
            alertController.addAction(changeRole)
        }
    }
    
    func addRideCancelAlertAction(_ handler: @escaping() -> Void) {
        AppDelegate.getAppDelegate().log.debug("createRideCancellationUIAlertAction()")
        let cancelRide = UIAlertAction(title: Strings.cancel_ride, style: .destructive) { action in
            self.alertController.dismiss(animated: false, completion: nil)
            handler()
        }

        alertController.addAction(cancelRide)
    }
    
    func showAlertController(viewController : UIViewController){
        alertController.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: { action in
            self.alertController.dismiss(animated: false, completion: nil)
        }))
        viewController.present(alertController, animated: true, completion: {
        })
    }
}

