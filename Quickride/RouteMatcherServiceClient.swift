
//
//  RouteMatcherServiceClient.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 03/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import GoogleMaps

@objc protocol MatchingRideOptionsDelegate{
    @objc optional func onFailed(responseObject: NSDictionary?,error : NSError?)
    @objc optional func receiveMatchingRiders(matchedRiders : [MatchedRider])
    @objc optional func receiveMatchingPassengers(matchedPassengers : [MatchedPassenger])
    @objc optional func receiveMatchingRidersAroundLocation(rideType : String,latitude : Double, longitude: Double,queryTime :NSDate,riders : [NearByRideOption])
    @objc optional func receiveMatchingPassengersAroundLocation(rideType : String,latitude : Double, longitude: Double,queryTime :NSDate,passengers : [NearByRideOption])
}

class RouteMatcherServiceClient {
    
    
    static let rideMatcherServiceRiderRidesPath = "QRRoutematcher/ridesWithOldMatches/utc/buckets"
    static let rideMatcherServiceRiderRidesPathForNextBucket = "QRRoutematcher/ridesWithOldMatches/utc/nextbucket"
    static let  rideMatcherServiceRiderRidesPathLocation = "QRRoutematcher/rides/location/utc"
    static let  rideMatcherServicePassengerRidesPath = "QRRoutematcher/passengersWithOldMatches/buckets"
    static let  rideMatcherServicePassengerRidesNextBucketPath = "QRRoutematcher/passengersWithOldMatches/nextbucket"
    static let  rideMatcherServicePassengerRidesPathLocation = "QRRoutematcher/passengers/location/utc"
    static let  rideMatcherServiceRiderRidesPathAroundLocation = "QRRoutematcher/rides/nearOptions/utc"
    static let  rideMatcherServicePassengerRidesPathAroundLocation = "QRRoutematcher/passengers/nearOptions/utc"
    static let VALIDATE_INVITE_BY_CONTACT_FROM_PASSENGER = "/QRRideconn/invite/contact/validatefrompassenger"
    static let VALIDATE_INVITE_BY_CONTACT_FROM_RIDER = "/QRRideconn/invite/contact/validatefromrider"
    static let RIDE_MATCHER_SERVICE_MATCHED_RIDER_SERVICE_PATH = "/QRRoutematcher/matchedrider/withPickupDrop"
    static let RIDE_MATCHER_SERVICE_MATCHED_PASSENGER_SERVICE_PATH = "/QRRoutematcher/matchedpassenger/withPickupDrop"
    static let INACTIVE_RIDE_MATCHER_SERVICE_PASSENGERRIDES_PATH = "/QRRoutematcher/inactive/matchedPassenger"
    static let INACTIVE_RIDE_MATCHER_SERVICE_RIDERRIDES_PATH = "/QRRoutematcher/inactive/matchedRider"
    
    static let FIND_FAVOURITE_PASSENGER_RIDES_PATH = "QRRoutematcher/favourite/passenger/rides"
    static let FIND_FAVOURITE_RIDER_RIDES_PATH = "QRRoutematcher/favourite/rider/rides"
    static let GET_RELAY_RIDES = "/QRRoutematcher/relayRide/passenger"
    static let GET_NUMBER_OF_USERS_AT_LOCATION = "/QRRoutematcher/favouriteUsers/count"

    
    
    typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    static func getMatchingRiderRides(ride:Ride,rideRoute : RideRoute?,noOfSeats : Int, uiViewController: UIViewController?, delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("getMatchingRiderRides()")
        if ride.endLatitude != nil && ride.endLatitude != 0 && ride.endLongitude != nil && ride.endLongitude != 0{
            getMatchingRidersForRoute(ride: ride,rideRoute:rideRoute,noOfSeats :noOfSeats, uiViewController: uiViewController, minMatchingPercent: nil, completionHandler: { (responseObject, error) -> Void in
                processMatchingRiders(responseObject: responseObject, error: error, viewController: uiViewController, delegate: delegate)
            })
        }else{
            getRiderRidesGoingThroughLocation(ride: ride,uiViewController: uiViewController,completionHandler :{ (responseObject, error) -> Void in
                processMatchingRiders(responseObject: responseObject, error: error, viewController: uiViewController, delegate: delegate)
            })
        }
    }
    
    static func getMatchingPassengerRides(ride:Ride,rideRoute : RideRoute?, rideFare : String?,noOfSeats : String?,uiViewController: UIViewController?, delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengerRides()")
        if ride.endLatitude != nil && ride.endLatitude != 0 && ride.endLongitude != nil && ride.endLongitude != 0{
            getMatchingPassengersForRoute(ride: ride,rideRoute: rideRoute,rideFare: rideFare,noOfSeats: noOfSeats, viewController: uiViewController, completionhandler: { (responseObject, error) -> Void in
                processMatchingPassengers(responseObject: responseObject, error: error, viewController: uiViewController, delegate: delegate)
            })
        }else{
            getMatchingPassengerGoingThroughLocation(ride: ride,rideFare: rideFare,noOfSeats: noOfSeats, viewController: uiViewController, completionHandler: { (responseObject, error) -> Void in
                processMatchingPassengers(responseObject: responseObject, error: error, viewController: uiViewController, delegate: delegate)
            })
        }
    }
    
    static func getMatchingPassengerRidesAroundLocation(latitude:Double, longitude: Double,startTime : Double,noOfSeats : Int, delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengerRidesAroundLocation()  \(latitude) \(longitude) \(startTime)")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServicePassengerRidesPathAroundLocation
        
        var params : [String : String] = [String : String]()
        params[Ride.FLD_STARTLATITUDE] = String(latitude)
        params[Ride.FLD_STARTLONGITUDE] = String(longitude)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        params[Ride.FLD_USERID] = (QRSessionManager.sharedInstance?.getUserId().components(separatedBy: ".")[0])!
        
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil,params: params) { (responseObject, error) -> Void in
            if responseObject == nil {
                return
            }
            if responseObject!["result"] as! String == "SUCCESS"{
                
                let matchingPassengers = Mapper<NearByRideOption>().mapArray(JSONObject: responseObject!["resultData"])!
                delegate.receiveMatchingPassengersAroundLocation?(rideType: Ride.RIDER_RIDE, latitude: latitude, longitude: longitude, queryTime: NSDate(timeIntervalSince1970: startTime/1000), passengers: matchingPassengers)
                
            }
            
        }
    }
    static func getMatchingRiderRidesAroundLocation(latitude:Double, longitude: Double, startTime : Double,delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("getMatchingRiderRidesAroundLocation() \(latitude) \(longitude) \(startTime)")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServiceRiderRidesPathAroundLocation
        var params : [String : String] = [String : String]()
        params[Ride.FLD_STARTLATITUDE] = String(latitude)
        params[Ride.FLD_STARTLONGITUDE] = String(longitude)
        params[Ride.FLD_USERID] = (QRSessionManager.sharedInstance?.getUserId().components(separatedBy: ".")[0])!
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: startTime))
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil,params: params) { (responseObject, error) -> Void in
            if responseObject == nil {
                return
            }
            if responseObject!["result"] as! String == "SUCCESS"{
                
                let matchingRiders = Mapper<NearByRideOption>().mapArray(JSONObject: responseObject!["resultData"])!
                delegate.receiveMatchingRidersAroundLocation?(rideType: Ride.PASSENGER_RIDE, latitude: latitude, longitude: longitude, queryTime: NSDate(timeIntervalSince1970: startTime/1000), riders: matchingRiders)
            }
        }
    }
    
    static func processMatchingPassengers(responseObject: NSDictionary?, error: NSError?,viewController : UIViewController?,delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("processMatchingPassengers()")
        if(responseObject == nil || responseObject!["result"] as! String == "FAILURE"){
            
            delegate.onFailed?(responseObject: responseObject,error: error)
            
        }else if responseObject!["result"] as! String == "SUCCESS"{
            let matchingPassengers = Mapper<MatchedPassenger>().mapArray(JSONObject: responseObject!["resultData"])!
            
            delegate.receiveMatchingPassengers?(matchedPassengers: matchingPassengers)
            
        }
    }
    
    static func processMatchingRiders(responseObject: NSDictionary?, error: NSError?,viewController : UIViewController?,delegate: MatchingRideOptionsDelegate){
        AppDelegate.getAppDelegate().log.debug("processMatchingRiders()")
        if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
            
            delegate.onFailed?(responseObject: responseObject,error: error)
        }else if responseObject!["result"] as! String == "SUCCESS"{
            let matchingRiders = Mapper<MatchedRider>().mapArray(JSONObject: responseObject!["resultData"])!
            delegate.receiveMatchingRiders?(matchedRiders: matchingRiders)
        }
    }
    
    
    static func getRiderRidesGoingThroughLocation(ride:Ride, uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        
        AppDelegate.getAppDelegate().log.debug("getRiderRidesGoingThroughLocation()")
        
        let getRiderRidesStartingAroundLocationUrl = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath + rideMatcherServiceRiderRidesPathLocation
        var params : [String : String] = [String :String]()
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: ride.userId)
        HttpUtils.getJSONRequestWithBody(url: getRiderRidesStartingAroundLocationUrl, targetViewController: uiViewController,params: params, handler: completionHandler)
    }
    
    static func getMatchingPassengerGoingThroughLocation(ride : Ride,rideFare : String?,noOfSeats: String?,viewController :UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengerGoingThroughLocation()")
        
        let getRiderRidesStartingAroundLocationUrl = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath + rideMatcherServicePassengerRidesPathLocation
        var params : [String : String] = [String : String]()
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: ride.userId)
        params[Ride.FLD_FARE_KM] = rideFare
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        
        HttpUtils.getJSONRequestWithBody(url: getRiderRidesStartingAroundLocationUrl, targetViewController: viewController,params: params, handler: completionHandler)
    }
    
    static func  getMatchingRidersForRoute(ride:Ride,rideRoute : RideRoute?,noOfSeats: Int, uiViewController: UIViewController?,minMatchingPercent: Int?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getMatchingRidersForRoute()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServiceRiderRidesPath
        
        var params :[String:String] = [String : String]()
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        if let percentage = minMatchingPercent{
            params[Ride.matchPercentThreshold] = String(percentage)
        }else{
            params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        }
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: uiViewController, handler: completionHandler, body: params)
        
    }
    static func  getMatchingRidersForRouteForNextBucket(ride:Ride,rideRoute : RideRoute?,noOfSeats: Int,currentMatchBucket : Int,uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getMatchingRidersForRoute()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServiceRiderRidesPathForNextBucket
        
        var params :[String:String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        params[MatchedPassengersResultHolder.currentBucket] = String(describing: currentMatchBucket)
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: uiViewController, handler: completionHandler, body: params)
        
    }
    static func  getMatchingPassengersForRouteForNextBucket(ride : Ride,rideRoute : RideRoute?,rideFare : String?,noOfSeats: String?,currentMatchBucket : Int,uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengersForRouteForNextBucket()")
        
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServicePassengerRidesNextBucketPath
        var params :[String:String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        params[Ride.FLD_FARE_KM] = rideFare
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        params[MatchedPassengersResultHolder.currentBucket] = String(describing: currentMatchBucket)
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: uiViewController, handler: completionHandler, body: params)

        
    }
    
    static func getMatchingPassengersForRoute(ride : Ride,rideRoute : RideRoute?,rideFare : String?,noOfSeats: String?,viewController : UIViewController?,completionhandler : @escaping responseJSONCompletionHandler){
        
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengersForRoute()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+rideMatcherServicePassengerRidesPath
        var params :[String:String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        params[Ride.FLD_FARE_KM] = rideFare
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionhandler, body: params)
    }
    
    
    static func validateInviteByContactFromPassengerAndGetMatchedPassenger(
        invitationId : String,  passengerRideId : String,  riderId : String,  passengerUserId : String,
        points : String, viewController : UIViewController?, completionhandler : @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = invitationId
        params[Ride.FLD_PASSENGERRIDEID] =  passengerRideId
        params[User.FLD_PHONE] = riderId
        params[Ride.FLD_PASSENGERID] = passengerUserId
        params[Ride.FLD_POINTS] = points
        
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+VALIDATE_INVITE_BY_CONTACT_FROM_PASSENGER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionhandler, body: params)
        
    }
    
    static func validateInviteByContactFromRiderAndGetMatchedRider(
        invitationId : String, riderRideId : String, riderId : String, passengerUserId : String,
        noOfSeats : String, viewController : UIViewController?, completionhandler : @escaping responseJSONCompletionHandler) {
        
        var params = [String: String]()
        params[RideInvitation.FLD_RIDE_INVITATION_ID] = invitationId
        params[Ride.FLD_RIDER_RIDE_ID] = riderRideId
        params[User.FLD_PHONE] = riderId
        params[Ride.FLD_PASSENGERID] = passengerUserId
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        
        let url = AppConfiguration.rideConnectivityServerUrlIP + AppConfiguration.RC_serverPort + AppConfiguration.rideConnectivityServerPath+VALIDATE_INVITE_BY_CONTACT_FROM_RIDER
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionhandler, body: params)
    }
    static func getMatchingRider(riderRideId: Double, passengerRideId : Double, targetViewController : UIViewController?, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+RIDE_MATCHER_SERVICE_MATCHED_RIDER_SERVICE_PATH
        
        var params = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: targetViewController, params: params, handler: complitionHandler)
    }
    static func getMatchingPassenger(passengerRideId: Double,riderRideId: Double, targetViewController : UIViewController?, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+RIDE_MATCHER_SERVICE_MATCHED_PASSENGER_SERVICE_PATH
        var params = [String : String]()
        params[Ride.FLD_RIDER_RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: targetViewController, params: params, handler: complitionHandler)
    }
    
    static func getInactivePassengersForRoute(ride : Ride,rideRoute : RideRoute?,rideFare : String?,noOfSeats: String?,viewController : UIViewController?,completionhandler : @escaping responseJSONCompletionHandler){
       
        AppDelegate.getAppDelegate().log.debug("getMatchingPassengersForRoute()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+INACTIVE_RIDE_MATCHER_SERVICE_PASSENGERRIDES_PATH
        var params :[String:String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        params[Ride.FLD_FARE_KM] = rideFare
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionhandler, body: params)
        
    }
    
    static func getInactiveRidersForRoute(ride:Ride,rideRoute : RideRoute?,noOfSeats: Int,uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
       
        AppDelegate.getAppDelegate().log.debug("getMatchingRidersForRoute()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+INACTIVE_RIDE_MATCHER_SERVICE_RIDERRIDES_PATH
        
        var params :[String:String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        params[Ride.FLD_STARTLATITUDE] = String(ride.startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(ride.startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(ride.endLatitude!)
        params[Ride.FLD_ENDLONGITUDE] = String(ride.endLongitude!)
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        if rideRoute != nil{
            params[Ride.FLD_ROUTE] = Mapper().toJSONString(rideRoute!)
        }
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: uiViewController, handler: completionHandler, body: params)
    }
    
    static func  getFavouriteUserRiderRides(ride:Ride,noOfSeats: Int, uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getFavouriteUserRiderRides()")
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+FIND_FAVOURITE_RIDER_RIDES_PATH
        
        var params :[String:String] = [String : String]()
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        if ride.expectedEndTime != nil{
            params[Ride.FLD_EXPECTEDENDTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.expectedEndTime!))
        }
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: uiViewController, handler: completionHandler, body: params)
        
    }
    
    static func getFavouriteUserPassengerRides(ride : Ride,rideFare : String?,noOfSeats: String?,viewController : UIViewController?,completionhandler : @escaping responseJSONCompletionHandler){
        
        AppDelegate.getAppDelegate().log.debug("getFavouriteUserPassengerRides()")
        
        let url:String = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+FIND_FAVOURITE_PASSENGER_RIDES_PATH
        var params :[String:String] = [String : String]()
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.startTime))
        if ride.expectedEndTime != nil{
            params[Ride.FLD_EXPECTEDENDTIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: ride.expectedEndTime!))
        }
        params[Ride.FLD_USERID] = String(ride.userId).components(separatedBy: ".")[0]
        params[Ride.FLD_FARE_KM] = rideFare
        params[Ride.FLD_NO_OF_SEATS] = noOfSeats
        params[Ride.FLD_VEHICLE_TYPE] = ride.rideType
        params[Ride.IS_FOR_ANALYTICS] = "false"
        
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionhandler, body: params)
    }
    
    static func getMatchingRelayRides(passengerRideId: Double,userId: Double,complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        let url = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+GET_RELAY_RIDES
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: complitionHandler)
    }
    static func getNumberOfUsersAtLocation(startLatitude: Double?, startLongitude: Double?, endLatitude: Double?,endLongitude: Double?, rideType: String?, complitionHandler: @escaping RiderRideRestClient.responseJSONCompletionHandler) {
        var params = [String : String]()
        params[Ride.FLD_STARTLATITUDE] =  String(startLatitude ?? 0)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude ?? 0)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude ?? 0)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude ?? 0)
        params[Ride.FLD_RIDETYPE ] = rideType
        let url = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath+GET_NUMBER_OF_USERS_AT_LOCATION
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: complitionHandler)
    }
}
