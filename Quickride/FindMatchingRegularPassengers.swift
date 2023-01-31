//
//  FindMatchingRegularPassengers.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class FindMatchingRegularPassengers : FindMatchingRegularUsers{
    
    override init(rideId :Double, viewController :UIViewController,delegate :MatchingRegularRideOptionsDelegate){
        super.init(rideId: rideId, viewController: viewController, delegate: delegate)
    }
    func getMatchingRegularPassengers(){
      AppDelegate.getAppDelegate().log.debug("getMatchingRegularPassengers()")
        RegularRideMatcherServiceClient.getMatchingRegularPassengerRides(rideId: rideId, viewController: viewController) { (responseObject, error) -> Void in
            self.handleResponse(responseObject: responseObject,error: error)
        }
    }
    override func processMatchedUsers(response: AnyObject?) {
      AppDelegate.getAppDelegate().log.debug("processMatchedUsers()")

        var matchingRegularPassengers = [MatchedRegularPassenger]()
        if response != nil{
            matchingRegularPassengers = Mapper<MatchedRegularPassenger>().mapArray(JSONObject: response)!
        }
        delegate.receiveMatchingRegularPassengers(matchedRegularPassengers: matchingRegularPassengers)
    }
}
