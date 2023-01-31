//
//  MatchedUserRetrievalTask.swift
//  Quickride
//
//  Created by QuickRideMac on 13/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

class MatchedUserRetrievalTask {
    
    var rideType : String
    var rideId : Double
    var userId :Double
    var rideInvitation : RideInvitation
    var handler : (_ matchedUser: MatchedUser?, _ rideInvitation: RideInvitation, _ responseError :ResponseError?,_ error : NSError?) -> Void
    
    init(userId :Double,rideId :Double,rideType : String,rideInvitation : RideInvitation,handler : @escaping(_ matchedUser: MatchedUser?, _ rideInvitation: RideInvitation, _ responseError :ResponseError?,_ error : NSError?) -> Void){
        self.rideId = rideId
        self.userId = userId
        self.rideType = rideType
        self.rideInvitation = rideInvitation
        self.handler = handler
    }
    public func getMatchedUser(){
        switch (rideType) {
        case Ride.RIDER_RIDE:
            RouteMatcherServiceClient.getMatchingRider(riderRideId: rideId, passengerRideId: self.rideInvitation.passenegerRideId, targetViewController: nil,complitionHandler: { (responseObject, error) -> Void in
                self.processResponse(responseObject: responseObject,error : error)
            })
            break
        case Ride.PASSENGER_RIDE:
            RouteMatcherServiceClient.getMatchingPassenger(passengerRideId: rideId, riderRideId: self.rideInvitation.rideId, targetViewController: nil, complitionHandler: { (responseObject, error) -> Void in
                self.processResponse(responseObject: responseObject,error : error)
            })
            break
        case Ride.REGULAR_PASSENGER_RIDE:
            RegularRideMatcherServiceClient.getMatchingRegularPassenger(rideId: rideId, riderRideId: self.rideInvitation.rideId, viewController: nil, completionHandler: { (responseObject, error) -> Void in
                self.processResponse(responseObject: responseObject, error: error)
                
            })
        case Ride.REGULAR_RIDER_RIDE:
            RegularRideMatcherServiceClient.getMathchingRegularRider(rideId: rideId, passengerRideId: self.rideInvitation.passenegerRideId, viewController: nil, completionHandler: { (responseObject, error) -> Void in
                self.processResponse(responseObject: responseObject, error: error)
            })
        case TaxiPoolConstants.Taxi:
            TaxiSharingRestClient.getTaxiPassenger(taxiRidePassengerId: rideInvitation.passenegerRideId, passengerUserId: rideInvitation.passengerId , riderRideId: rideInvitation.rideId ) { (responseObject, error) -> Void in
                self.self.processResponse(responseObject: responseObject, error: error)
            }
        default:
            AppDelegate.getAppDelegate().log.debug("Ride type is not set appropriately in ride invitation : \(self.rideType)")
            processResponse(responseObject: nil,error: nil)
            break
            
        }
    }
    func processResponse(responseObject : NSDictionary?, error : NSError?){
        if let responseObject = responseObject, responseObject["result"] as? String == "SUCCESS", let resultData = responseObject["resultData"] {
            switch (rideType) {
            case Ride.RIDER_RIDE:
                handler(fillInvitaionDetails(matchedUser: Mapper<MatchedRider>().map(JSONObject: resultData)!), rideInvitation, nil, nil)
                break
            case Ride.PASSENGER_RIDE:
                handler(fillInvitaionDetails(matchedUser: Mapper<MatchedPassenger>().map(JSONObject: resultData)!), rideInvitation, nil, nil)
                break
            case Ride.REGULAR_RIDER_RIDE:
                handler(fillInvitaionDetails(matchedUser: Mapper<MatchedRegularRider>().map(JSONObject: resultData)!), rideInvitation, nil, nil)
                break
            case Ride.REGULAR_PASSENGER_RIDE:
                handler(fillInvitaionDetails(matchedUser: Mapper<MatchedRegularPassenger>().map(JSONObject: resultData)!), rideInvitation, nil, nil)
                break
            case TaxiPoolConstants.Taxi:
                handler(Mapper<MatchedPassenger>().map(JSONObject: resultData)!,rideInvitation,nil,nil)
                break
            default:
                break
            }
        }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
            let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
            handler(nil, rideInvitation, responseError,  nil)
        }else{
            handler(nil, rideInvitation, nil, error)
        }
    }
    
    func fillInvitaionDetails( matchedUser :MatchedUser) -> MatchedUser{
        matchedUser.userid = userId
        matchedUser.rideid = rideId
        matchedUser.pickupLocationLatitude = rideInvitation.pickupLatitude
        matchedUser.pickupLocationLongitude = rideInvitation.pickupLongitude
        if let pickupAddress = rideInvitation.pickupAddress{
            matchedUser.pickupLocationAddress = pickupAddress
        }
        matchedUser.dropLocationLatitude = rideInvitation.dropLatitude
        matchedUser.dropLocationLongitude = rideInvitation.dropLongitude
        if let dropAddress = rideInvitation.dropAddress{
            matchedUser.dropLocationAddress = dropAddress
        }
        if  rideInvitation.pickupTime != 0 {
            matchedUser.pickupTime = rideInvitation.pickupTime
        }else {
            matchedUser.pickupTime = NSDate().getTimeStamp()
        }
        
        if rideInvitation.dropTime != 0{
            matchedUser.dropTime = rideInvitation.dropTime
        }else {
            matchedUser.dropTime = NSDate().getTimeStamp()
        }
        matchedUser.distance = rideInvitation.matchedDistance
        if rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{
            matchedUser.points = rideInvitation.riderPoints
            matchedUser.newFare = rideInvitation.newRiderFare
        }else{
            matchedUser.points = rideInvitation.points
            matchedUser.newFare = rideInvitation.newFare
        }
        return matchedUser
    }
}
