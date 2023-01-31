//
//  RideTravelledPathTask.swift
//  Quickride
//
//  Created by QuickRideMac on 28/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol RideTravelledPathReceiver{
    func receiveRideTravelledPath(isFromViewMap: Bool, rideTravelledPath :String?)
}

class RideTravelledPathTask {
    private var rideId : Double
    private var listener : RideTravelledPathReceiver
    private var targetViewController: UIViewController?
    private var isFromViewMap = false
    
    init(rideId : Double,targetViewController: UIViewController, isFromViewMap: Bool, listener : RideTravelledPathReceiver){
        self.rideId = rideId
        self.listener = listener
        self.targetViewController = targetViewController
        self.isFromViewMap = isFromViewMap
    }
    
    func getRideTravelledPath(){
      AppDelegate.getAppDelegate().log.debug("getRideTravelledPath()")
        LocationUpdationServiceClient.getRideTravelledPath(riderRideId: rideId, targetViewController: targetViewController) { (responseObject, error) -> Void in
            if responseObject == nil || responseObject!.value(forKey: "result")! as! String == "FAILURE"{
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self.targetViewController, handler: nil)
            }else{
                let response = responseObject!.value(forKey: "resultData")
                if response == nil{
                    self.listener.receiveRideTravelledPath(isFromViewMap: self.isFromViewMap, rideTravelledPath: nil)
                }else{
                    self.listener.receiveRideTravelledPath(isFromViewMap: self.isFromViewMap, rideTravelledPath: response as? String)
                }
               
            }
        }
    }
}
