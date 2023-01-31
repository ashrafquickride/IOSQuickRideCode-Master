//
//  FindMatchingRegularUsers.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol MatchingRegularRideOptionsDelegate{
    func onFailed()
    func receiveMatchingRegularRiders(matchedRegularRiders : [MatchedRegularRider])
    func receiveMatchingRegularPassengers(matchedRegularPassengers : [MatchedRegularPassenger])
}
class FindMatchingRegularUsers{
    
    var rideId: Double = 0
    var viewController : UIViewController
    var delegate : MatchingRegularRideOptionsDelegate
    
    init(rideId :Double,viewController :UIViewController,delegate :MatchingRegularRideOptionsDelegate){
        self.rideId = rideId
        self.viewController = viewController
        self.delegate = delegate
        
    }
    func handleResponse(responseObject: NSDictionary?,error :NSError?){
      AppDelegate.getAppDelegate().log.error("handleResponse() \(String(describing: error))")
        if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
            ErrorProcessUtils.handleError(responseObject: responseObject,error: error,  viewController :viewController, handler: nil)
            delegate.onFailed()
            return
        }
        if responseObject!["result"] as! String == "SUCCESS"{
           //Todo Migration
           processMatchedUsers(response: responseObject?.value(forKey: "resultData") as AnyObject)
            
        }
    }
    func processMatchedUsers(response : AnyObject?){
        
    }
}
