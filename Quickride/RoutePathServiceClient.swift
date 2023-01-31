//
//  RoutePathServiceClient.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 18/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

class RoutePathServiceClient {
    
    static var GET_ALL_ROUTES_PATH = "/RoutePath/route/all"
    static var GET_FAVOURABLE_ROUTES_PATH = "/RoutePath/route"
    static var GET_RIDE_ROUTE_PATH = "/RoutePath/rideRoute"
    static var GET_RIDE_ROUTE_WITH_TRAFFIC_PATH = "/RoutePath/route/currenttraffic"
    static var GET_ROUTE_PATH = "/RoutePath/route/rideRoute"
    static var GET_RIDE_ROUTE_WITH_CONFIRM_PATH = "/RoutePath/saveCustomizedRoute"

    static var GET_ROUTE_DURATION_TRAFFIC_PATH = "/RoutePath/duration/traffic"
    
    static var RIDE_MATCHER_SERVICE_DISTANCE_GETTING_SERVICE_PATH = "/QRRoutematcher/path/distance"
    static var ROUTE_DEVIATION_UPDATE_SERVICE_PATH = "/QRRideLocation/routedeviation"

    static let SAVE_USER_PREFERRED_ROUTE_PATH = "/QRUserPreferredRoute"
    static let UPDATE_USER_PREFERRED_ROUTE_PATH = "/QRUserPreferredRoute/update/userPreferredRoute"
    
    static let CREATE_USER_FAVOURITE_ROUTES_PATH = "/RoutePath/userFavouriteRoutes"
    static let AUTO_COMPLETE_PLACES_PATH = "/location/autocomplete"
    
    static let LOCATION_INFO_FOR_LATLNG_PATH = "/location/geocode/latlng"
    static let LOCATION_INFO_FOR_ADDRESS_PATH = "/location/geocode/address"

    static let GET_WALK_ROUTE_SERVICE_PATH = "/RoutePath/rideRoute/walk"
    
    static let GET_MULTI_ETA_SERVICE_PATH = "/ETAService/eta/multi"
    static let GET_ETA_SERVICE_PATH = "/ETAService/eta"
    static let UPDATE_PLACE_USAGE_COUNT_PATH = "location/autocomplete/usageCount"

    static func getAllAvailableRoutes(rideId : Double,useCase : String,startLatitude:Double, startLongitude:Double, endLatitude:Double, endLongitude:Double, wayPoints:String?,weightedRoutes: Bool,viewcontroller : UIViewController?,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getAllAvailableRoutes() \(startLatitude) \(startLongitude) \(endLatitude) \(endLongitude)")
        if startLatitude == startLongitude || startLatitude == endLatitude || startLatitude == endLongitude || startLongitude == endLatitude || startLongitude == endLongitude || endLatitude == endLongitude{
            return
        }
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  GET_ALL_ROUTES_PATH
        
        var params : [String: String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber:UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] = useCase
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        params[Ride.FLD_WEIGHTED_ROUTES] = String(weightedRoutes)
        
        
        if wayPoints != nil && wayPoints!.isEmpty == false{
            params[Ride.FLD_WAYPOINTS] = wayPoints!
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewcontroller, params: params, handler: completionhandler)
    }

    static func  getMostFavourableRoute(rideId : Double,useCase : String, startLatitude:Double, startLongitude:Double,  endLatitude:Double,  endLongitude:Double, wayPoints:String?,viewController: UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getMostFavourableRoute() \(startLatitude) \(startLongitude) \(endLatitude) \(endLongitude)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath + GET_FAVOURABLE_ROUTES_PATH
        var params : [String: String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber:UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] = useCase
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        if wayPoints != nil && wayPoints!.isEmpty == false{
            params[Ride.FLD_WAYPOINTS] = wayPoints!
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
 
    static func getRideRouteWithCurrentTrafficInfo(routeId : Double,departureTime : Double?,viewController: UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getRideRouteWithCurrentTrafficInfo() \(routeId)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath + GET_RIDE_ROUTE_WITH_TRAFFIC_PATH
        
        var params : [String: String] = [String : String]()
        params[Ride.FLD_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        params[RideRoute.FLD_DEPARTURE_TIME] = StringUtils.getStringFromDouble(decimalNumber: departureTime)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    static func getRideRoute(routeId : Double,startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, waypoints: String?, overviewPolyline: String?, travelMode: String, useCase: String,viewController: UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getRideRoute() \(routeId)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath + GET_ROUTE_PATH
        
        var params = [String : String]()
        params[Ride.FLD_ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        if let points = waypoints{
           params[Ride.FLD_WAYPOINTS] = points
        }
        if let polyline = overviewPolyline{
           params[Ride.FLD_OVERVIEW_POLYLINE] = polyline
        }
        params[Ride.FLD_TRAVEL_MODE] = travelMode
        params[RouteMetrics.FLD_USE_CASE] = useCase
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    static func confirmCustomizedRouteAndSave(rideId : Double,useCase : String, startLatitude:Double, startLongitude:Double,  endLatitude:Double,  endLongitude:Double, wayPoints:String?,confirmed : Bool,viewController: UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("confirmCustomizedRouteAndSave \(startLatitude) \(startLongitude) \(endLatitude) \(endLongitude)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath + GET_RIDE_ROUTE_WITH_CONFIRM_PATH
        var params : [String: String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber:UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] = useCase
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)
        params[Ride.FLD_WAYPOINTS] = wayPoints
        params[Ride.FLD_CONFIRMED] = String(confirmed)
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    static func getDistance(startLatitude:Double, startLongitude:Double,  endLatitude:Double,  endLongitude:Double, viewController: UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("getDistance \(startLatitude) \(startLongitude) \(endLatitude) \(endLongitude)")
        let url = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath + RIDE_MATCHER_SERVICE_DISTANCE_GETTING_SERVICE_PATH
        
        var params : [String: String] = [String : String]()
        
        params["startLat"] = String(startLatitude)
        params["startLng"] = String(startLongitude)
        params["endLat"] = String(endLatitude)
        params["endLng"] = String(endLongitude)
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: completionHandler)
    }
    static func updateRouteDeviationToRideEngine(passengerRideId:Double, status:String,viewController: UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler)
    {
        AppDelegate.getAppDelegate().log.debug("updateRouteDeviationToRideEngine \(passengerRideId) \(status)")
        let url = AppConfiguration.rideLocationServerUrlIP + AppConfiguration.RL_serverPort + AppConfiguration.rideLocationServerPath + ROUTE_DEVIATION_UPDATE_SERVICE_PATH
        var params : [String: String] = [String : String]()
        
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[RideRoute.FLD_ROUTE_DEVIATION_STATUS] = status
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }

    static func getWalkRoute(rideId: Double,useCase : String, startLatitude:Double, startLongitude:Double, endLatitude:Double, endLongitude:Double,viewController: UIViewController?,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){

        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] = useCase
        params[Ride.FLD_STARTLATITUDE] = String(startLatitude)
        params[Ride.FLD_STARTLONGITUDE] = String(startLongitude)
        params[Ride.FLD_ENDLATITUDE] = String(endLatitude)
        params[Ride.FLD_ENDLONGITUDE] = String(endLongitude)

        let url = AppConfiguration.routeServerUrl + AppConfiguration.ROUTE_MATCH_serverPort + AppConfiguration.routeServerPath + GET_WALK_ROUTE_SERVICE_PATH

        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
    }
    
    static func getDistance(directionRoute : Route) -> Double{
        
        if directionRoute.legs != nil && !directionRoute.legs!.isEmpty && directionRoute.legs![0].distance != nil && directionRoute.legs![0].distance!.value != nil{
           return Double(directionRoute.legs![0].distance!.value!)/1000
        }
      return 0.0
    }
    
    static func getDuration(directionRoute : Route) -> Double{
        if directionRoute.legs != nil && !directionRoute.legs!.isEmpty && directionRoute.legs![0].duration != nil && directionRoute.legs![0].duration!.value != nil{
          return Double(directionRoute.legs![0].duration!.value!)/60
        }
      return 0.0
    }

    static func saveUserPreferredRoute(userPreferredRoute : UserPreferredRoute,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SAVE_USER_PREFERRED_ROUTE_PATH
        var params = [String : String]()
        params[UserPreferredRoute.USER_ID] = StringUtils.getStringFromDouble(decimalNumber:userPreferredRoute.userId)
        params[UserPreferredRoute.ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: userPreferredRoute.routeId)
        params[UserPreferredRoute.FROM_LATITUDE] = String(userPreferredRoute.fromLatitude!)
        params[UserPreferredRoute.FROM_LONGITUDE] = String(userPreferredRoute.fromLongitude!)
        params[UserPreferredRoute.TO_LATITUDE] = String(userPreferredRoute.toLatitude!)
        params[UserPreferredRoute.TO_LONGITUDE] = String(userPreferredRoute.toLongitude!)
        params[UserPreferredRoute.FROM_LOCATION] = userPreferredRoute.fromLocation
        params[UserPreferredRoute.TO_LOCATION] = userPreferredRoute.toLocation
        params[UserPreferredRoute.ROUTE_NAME] = userPreferredRoute.routeName
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }


    static func updateUserPreferredRoute(userPreferredRoute : UserPreferredRoute,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_USER_PREFERRED_ROUTE_PATH
        
        var params = [String : String]()

        params[UserPreferredRoute.ID] = StringUtils.getStringFromDouble(decimalNumber: userPreferredRoute.id)
        params[UserPreferredRoute.USER_ID] = StringUtils.getStringFromDouble(decimalNumber:userPreferredRoute.userId)
        params[UserPreferredRoute.ROUTE_ID] = StringUtils.getStringFromDouble(decimalNumber: userPreferredRoute.routeId)
        params[UserPreferredRoute.FROM_LATITUDE] = String(userPreferredRoute.fromLatitude!)
        params[UserPreferredRoute.FROM_LONGITUDE] = String(userPreferredRoute.fromLongitude!)
        params[UserPreferredRoute.TO_LATITUDE] = String(userPreferredRoute.toLatitude!)
        params[UserPreferredRoute.TO_LONGITUDE] = String(userPreferredRoute.toLongitude!)
        params[UserPreferredRoute.FROM_LOCATION] = userPreferredRoute.fromLocation
        params[UserPreferredRoute.TO_LOCATION] = userPreferredRoute.toLocation
        params[UserPreferredRoute.ROUTE_NAME] = userPreferredRoute.routeName

        HttpUtils.putRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    
    static func deleteUserPreferredRoute(id : Double,userId : Double,viewController: UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SAVE_USER_PREFERRED_ROUTE_PATH
        var params = [String : String]()
        
        params[UserPreferredRoute.ID] = StringUtils.getStringFromDouble(decimalNumber: id)
        params[UserPreferredRoute.USER_ID] = StringUtils.getStringFromDouble(decimalNumber:userId)
        
        HttpUtils.deleteJSONRequest(url: url, params: params, targetViewController: viewController, handler: completionHandler)
    }
    
    static func createUserFavouriteRoute(userFavouriteRoute : UserFavouriteRoute,homeToOfficeStartTime : Double?,officeToHomeStartTime : Double?, homeToOfficeRouteId : Double,officeToHomeRouteId : Double,viewController : UIViewController,completionHandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath + CREATE_USER_FAVOURITE_ROUTES_PATH
        var params = [String : String]()
 
        params[UserFavouriteRoute.FLD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userFavouriteRoute.userId)
        params[UserFavouriteRoute.FLD_USER_NAME] = userFavouriteRoute.userName
        params[UserFavouriteRoute.FLD_STARTLATITUDE] = String(userFavouriteRoute.startLatitude!)
        params[UserFavouriteRoute.FLD_STARTLONGITUDE] = String(userFavouriteRoute.startLongitude!)
        params[UserFavouriteRoute.FLD_STARTADDRESS] = userFavouriteRoute.startAddress
        params[UserFavouriteRoute.FLD_ENDLATITUDE] = String(userFavouriteRoute.endLatitude!)
        params[UserFavouriteRoute.FLD_ENDLONGITUDE] = String(userFavouriteRoute.endLongitude!)
        params[UserFavouriteRoute.FLD_ENDADDRESS] = userFavouriteRoute.endAddress
        params[UserFavouriteRoute.FLD_RIDE_TYPE] = userFavouriteRoute.rideType
        
        if homeToOfficeStartTime != nil{
           params[UserFavouriteRoute.FLD_RIDE_START_TIME] = AppUtil.getTimeFromTimeIntervalInMillisWithFormat(timeFormat: DateUtils.TIME_FORMAT_HHmm, timeInterval: homeToOfficeStartTime!)
        }
        
        if officeToHomeStartTime != nil{
            params[UserFavouriteRoute.FLD_LEAVE_TIME] = AppUtil.getTimeFromTimeIntervalInMillisWithFormat(timeFormat: DateUtils.TIME_FORMAT_HHmm, timeInterval: officeToHomeStartTime!)
        }
        
        if homeToOfficeRouteId != 0.0{
           params[UserFavouriteRoute.FLD_HOME_TO_OFFICE_ROUTEID] = StringUtils.getStringFromDouble(decimalNumber: homeToOfficeRouteId)
        }
        if officeToHomeRouteId != 0.0{
            params[UserFavouriteRoute.FLD_OFFICE_TO_HOME_ROUTEID] = StringUtils.getStringFromDouble(decimalNumber: officeToHomeRouteId)
        }
        params[UserFavouriteRoute.FLD_DISTANCE] = String(userFavouriteRoute.distance!)
        params[UserFavouriteRoute.FLD_STATUS] = userFavouriteRoute.status
        params[UserFavouriteRoute.FLD_USER_CREATED] = String(userFavouriteRoute.isUserCreated)
        params[UserFavouriteRoute.FLD_APP_NAME] = userFavouriteRoute.appName
        params[UserFavouriteRoute.FLD_COUNTRY] = userFavouriteRoute.country
        params[UserFavouriteRoute.FLD_STATE] = userFavouriteRoute.state
        params[UserFavouriteRoute.FLD_CITY] = userFavouriteRoute.city
        params[UserFavouriteRoute.FLD_AREANAME] = userFavouriteRoute.areaName
        params[UserFavouriteRoute.FLD_STREET_NAME] = userFavouriteRoute.streetName
        
       HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
        
      }
    static func getAutoCompletePlaces(useCase : String, forSearchString:String,regionLat : Double,regionLong: Double,readFromGoogle : Bool,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getAutoCompletePlaces() \(forSearchString), \(regionLat), \(regionLong)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  AUTO_COMPLETE_PLACES_PATH
        
        var params = [String : String]()
        params[Location.FLD_CHARSEQUENCE] = forSearchString
        params[Location.FLD_LATITUDE] = String(regionLat)
        params[Location.FLD_LONGITUDE] = String(regionLong)
        params[Location.FLD_READ_FROM_GOOGLE] = String(readFromGoogle)
        params["useCase"] = useCase
        params["userId"] = UserDataCache.getInstance()?.userId ?? ""
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionhandler)
    }
    static func saveAutoCompletePlaces(places : [Location],latitude : Double,longitude : Double,charSequence : String,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  AUTO_COMPLETE_PLACES_PATH
        
        var params = [String : String]()
        params[Location.FLD_AUTO_COMPLETE_DATA] = places.toJSONString()
        params[Location.FLD_LATITUDE] = String(latitude)
        params[Location.FLD_LONGITUDE] = String(longitude)
        params[Location.FLD_CHARSEQUENCE] = charSequence
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil, handler: completionhandler, body: params)
        
    }

    static func getLocationInfoForLatLng(useCase : String,latitude:Double,longitude:Double,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getLocationInfoForLatLng() \(latitude) \(longitude)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  LOCATION_INFO_FOR_LATLNG_PATH
        
        var params = [String : String]()
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] =  useCase
        params[Location.FLD_LATITUDE] = String(latitude)
        params[Location.FLD_LONGITUDE] = String(longitude)
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionhandler)
    }
    static func getLocationInfoForAddress(useCase : String,address:String,placeId : String?,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("getLocationInfoForAddress() \(address)")
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  LOCATION_INFO_FOR_ADDRESS_PATH
        
        var params  = [String : String]()
        params[Location.ADDRESS] = address
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[RouteMetrics.FLD_USE_CASE] =  useCase
        if placeId != nil{
            params[Location.FLD_PLACE_ID] = placeId
        }
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionhandler)
    }
    
    static func getETAForMultiPoint(routeId : Double,startTime: Double,startLatLngList: [LatLng],endLatLngList: [LatLng],vehicleType: String,rideId: Double,useCase: String,snapToRoute: Bool,routeStartLatitude: Double, routeStartLongitude: Double, routeEndLatitude: Double, routeEndLongitude: Double, routeWaypoints: String?, routeOverviewPolyline: String?,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("Get eta for multi point() \(routeId)")
        var params  = [String : String]()
        params[ETAResponse.routeId] = StringUtils.getStringFromDouble(decimalNumber: routeId)
        params[ETAResponse.startTime] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params[ETAResponse.startLatLngListJson] =  startLatLngList.toJSONString()
        params[ETAResponse.endLatLngListJson] = endLatLngList.toJSONString()
        params[ETAResponse.vehicleType] = vehicleType
        params[ETAResponse.userId] = UserDataCache.getInstance()?.userId
        params[ETAResponse.rideId] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[ETAResponse.useCase] = useCase
        params[ETAResponse.snapToRoute] = String(snapToRoute)
        params[RideRoute.ROUTE_START_LAT] = String(routeStartLatitude)
        params[RideRoute.ROUTE_START_LNG] = String(routeStartLongitude)
        params[RideRoute.ROUTE_END_LAT] = String(routeEndLatitude)
        params[RideRoute.ROUTE_END_LNG] = String(routeEndLongitude)
        if let waypoints = routeWaypoints{
            params[RideRoute.ROUTE_WAY_POINTS] = waypoints
        }
        if let overviewPolyline = routeOverviewPolyline{
            params[RideRoute.ROUTE_OVERVIEW_POLYLINE] = overviewPolyline
        }
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  GET_MULTI_ETA_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionhandler)
    }
    static func getETABetweenTwoPoints(routeId: String,startTime: Double,startLatitude: Double,startLongitude: Double,endLatitude: Double,endLangitude: Double,vehicleType: String,rideId: Double,useCase: String,snapToRoute: Bool,routeStartLatitude: Double, routeStartLongitude: Double, routeEndLatitude: Double, routeEndLongitude: Double, routeWaypoints: String?, routeOverviewPolyline: String?,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("Get eta for route \(routeId)")
        var params  = [String : String]()
        params[ETAResponse.routeId] = routeId
        params[ETAResponse.startTime] = StringUtils.getStringFromDouble(decimalNumber: startTime)
        params[ETAResponse.startLatitude] =  String(startLatitude)
        params[ETAResponse.startLongitude] = String(startLongitude)
        params[ETAResponse.endLatitude] =  String(endLatitude)
        params[ETAResponse.endLangitude] = String(endLangitude)
        params[ETAResponse.vehicleType] = vehicleType
        params[ETAResponse.userId] = UserDataCache.getInstance()?.userId
        params[ETAResponse.rideId] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        params[ETAResponse.useCase] = useCase
        params[ETAResponse.snapToRoute] = String(snapToRoute)
        params[RideRoute.ROUTE_START_LAT] = String(routeStartLatitude)
        params[RideRoute.ROUTE_START_LNG] = String(routeStartLongitude)
        params[RideRoute.ROUTE_END_LAT] = String(routeEndLatitude)
        params[RideRoute.ROUTE_END_LNG] = String(routeEndLongitude)
        if let waypoints = routeWaypoints{
            params[RideRoute.ROUTE_WAY_POINTS] = waypoints
        }
        if let overviewPolyline = routeOverviewPolyline{
            params[RideRoute.ROUTE_OVERVIEW_POLYLINE] = overviewPolyline
        }
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  GET_ETA_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionhandler)
    }
    static func updateUsageCount(address: String,completionhandler : @escaping RiderRideRestClient.responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateUsageCount \(address)")
        var params  = [String : String]()
        params["address"] = address
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId())
        let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  UPDATE_PLACE_USAGE_COUNT_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionhandler, body: params)
    }
}
