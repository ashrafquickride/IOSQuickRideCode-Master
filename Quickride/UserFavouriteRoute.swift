//
//  UserFavouriteRoute.swift
//  Quickride
//
//  Created by Admin on 05/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserFavouriteRoute : NSObject,Mappable{
   
    var userId : Double?
    var startLatitude : Double?
    var startLongitude : Double?
    var endLatitude : Double?
    var endLongitude : Double?
    var rideType : String?
    var country : String?
    var state : String?
    var city : String?
    var areaName : String?
    var streetName : String?
    var startAddress : String?
    var endAddress : String?
    var userName : String?
    var appName : String?
    var status : String?
    var distance : Double?
    var isUserCreated = false
    
     static let ACTIVE_USER_FAVOURITE_ROUTE="ACTIVE"
    static let INACTIVE_USER_FAVOURITE_ROUTE="INACTIVE"
    static let DELETED_USER_FAVOURITE_ROUTE="DELETED"
    
    static let FLD_USER_ID = "userId";
    static let FLD_USER_NAME = "userName";
    static let FLD_STARTADDRESS = "startAddress";
    static let FLD_STARTLATITUDE = "startLatitude";
    static let FLD_STARTLONGITUDE = "startLongitude";
    static let FLD_ENDADDRESS = "endAddress";
    static let FLD_ENDLATITUDE = "endLatitude";
    static let FLD_ENDLONGITUDE = "endLongitude";
    static let FLD_DISTANCE = "distance";
    static let FLD_START_TIME = "startTime";
    static let FLD_RIDE_START_TIME = "rideStartTime";
    static let FLD_RIDE_TYPE = "rideType";
    static let FLD_APP_NAME = "appName";
    static let FLD_COUNTRY = "country";
    static let FLD_STATE = "state";
    static let FLD_CITY = "city";
    static let FLD_AREANAME = "areaName";
    static let FLD_STREET_NAME = "streetName";
    static let FLD_STATUS = "status";
    static let FLD_USER_CREATED = "isUserCreated";
    static let FLD_LEAVE_TIME = "leaveTime";
    static let FLD_HOME_TO_OFFICE_ROUTEID = "homeToOfficeRouteId";
    static let FLD_OFFICE_TO_HOME_ROUTEID = "officeToHomeRouteId";
    
    required init?(map: Map) {
        
    }
    override init()
    {}
    
    init(userId : Double?,userName : String?,startLatitude : Double?,startLongitude : Double?,startAddress : String?,endLatitude : Double,endLongitude : Double?,endAddress : String?,rideType : String?,status : String,isUserCreated : Bool,appName : String?,country : String?,state : String?,city : String?,areaName : String?,streetName : String?,distance : Double) {
       

        self.userId = userId
        self.userName =  userName
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.startAddress = startAddress
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.endAddress = endAddress
        self.rideType = rideType
        self.status = status
        self.isUserCreated = isUserCreated
        self.appName = appName
        self.country = country
        self.state = state
        self.city = city
        self.areaName = areaName
        self.streetName = streetName
        self.distance = distance
       
    }
    
    
     func mapping(map: Map) {
        
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "startLatitude: \(String(describing: self.startLatitude))," + " startLongitude: \( String(describing: self.startLongitude))," + " endLatitude: \(String(describing: self.endLatitude))," + " endLongitude: \(String(describing: self.endLongitude)),"
            + " rideType: \(String(describing: self.rideType))," + "country: \(String(describing: self.country))," + "state:\(String(describing: self.state))," + "city:\(String(describing: self.city))," + "country:\(String(describing: self.country))," + "city:\(String(describing: self.city))," + "areaName:\(String(describing: self.areaName))," + "streetName:\(String(describing: self.streetName))," + "startAddress: \(String(describing: self.startAddress))," + " endAddress: \( String(describing: self.endAddress))," + " userName: \(String(describing: self.userName))," + " appName: \(String(describing: self.appName)),"
            + " status: \(String(describing: self.status))," + "distance: \(String(describing: self.distance))," + "isUserCreated:\(String(describing: self.isUserCreated)),"
    }
    
}
