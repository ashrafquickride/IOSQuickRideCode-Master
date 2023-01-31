//
//  FindMatchingRegularRiders.swift
//  Quickride
//
//  Created by QuickRideMac on 20/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FindMatchingRegularRiders :FindMatchingRegularUsers {
    
    override init(rideId: Double, viewController: UIViewController, delegate: MatchingRegularRideOptionsDelegate) {
        super.init(rideId: rideId, viewController: viewController, delegate: delegate)
    }
    func getMatchingRegularRiders(){
      AppDelegate.getAppDelegate().log.debug("getMatchingRegularRiders()")
        RegularRideMatcherServiceClient.getMatchingRegularRiderRides(rideId: rideId, viewController: viewController) { (responseObject, error) -> Void in
            self.handleResponse(responseObject: responseObject, error: error)
        }
    }
    override func processMatchedUsers(response: AnyObject?) {
      AppDelegate.getAppDelegate().log.debug("processMatchedUsers()")
        var matchingRiders = [MatchedRegularRider]()
        if response != nil{
            matchingRiders = Mapper<MatchedRegularRider>().mapArray(JSONObject: response)!
        }
        delegate.receiveMatchingRegularRiders(matchedRegularRiders: matchingRiders)
    }
}
