//
//  UserPreferredRoute.swift
//  Quickride
//
//  Created by rakesh on 11/29/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserPreferredRoute : NSObject, Mappable{
    
    var id : Double?
    var userId : Double?
    var routeId : Double?
    var fromLatitude : Double?
    var fromLongitude : Double?
    var toLatitude : Double?
    var toLongitude : Double?
    var rideRoute : RideRoute?
    var fromLocation : String?
    var toLocation : String?
    var routeName : String?
    
    static let ID = "id"
    static let USER_ID = "userId"
    static let ROUTE_ID = "routeId"
    static let FROM_LATITUDE = "fromLatitude"
    static let FROM_LONGITUDE = "fromLongitude"
    static let TO_LATITUDE = "toLatitude"
    static let TO_LONGITUDE = "toLongitude"
    static let FROM_LOCATION = "fromLocation"
    static let TO_LOCATION = "toLocation"
    static let ROUTE_NAME = "routeName"
    
    required init?(map: Map) {
        
    }
    
    override init(){
        
    }
    
    init(id : Double?,userId : Double?,routeId : Double?,fromLatitude : Double?,fromLongitude : Double?,toLatitude : Double,toLongitude : Double?,rideRoute : RideRoute?,fromLocation : String?,toLocation : String?,routeName : String?){
        
        self.id = id
        self.userId = userId
        self.routeId = routeId
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
        self.rideRoute = rideRoute
        self.fromLocation = fromLocation
        self.toLocation = toLocation
        self.routeName = routeName
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        routeId <- map["routeId"]
        fromLatitude <- map["fromLatitude"]
        fromLongitude <- map["fromLongitude"]
        toLatitude <- map["toLatitude"]
        toLongitude <- map["toLongitude"]
        rideRoute <- map["rideRoute"]
        fromLocation <- map["fromLocation"]
        toLocation <- map["toLocation"]
        routeName <- map["routeName"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " routeId: \( String(describing: self.routeId))," + " fromLatitude: \(String(describing: self.fromLatitude))," + " fromLongitude: \(String(describing: self.fromLongitude)),"
            + " toLatitude: \(String(describing: self.toLatitude))," + " toLatitude: \(String(describing: self.toLatitude)),"
    }
    
}
