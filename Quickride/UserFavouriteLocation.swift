//
//  UserFavouriteLocation.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserFavouriteLocation : NSObject,Mappable{
    
    static let PHONE = "phone"
    static let NAME = "name"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
    static let ADDRESS = "address"
    static let HOME_FAVOURITE = "Home"
    static let OFFICE_FAVOURITE = "Office"
    static let LEAVING_TIME = "leavingTime"
    static let COUNTRY = "country"
    static let STATE = "state"
    static let CITY = "city"
    static let AREA_NAME = "areaName"
    static let STREET_NAME = "streetName"

    var locationId:Double?
    var phoneNumber:Double?
    var name:String?
    var shortAddress: String?
    var address:String?
    var latitude:Double?
    var longitude:Double?
    var leavingTime : Double?
    var country:String?
    var state:String?
    var city:String?
    var areaName:String?
    var streetName:String?
    
    required public init(map:Map){
        
    }
    
    public override init(){
        
    }
    
    init(shortAddress: String?, address: String?, latitude: Double?, longitute: Double?){
        self.shortAddress = shortAddress
        self.address = address
        self.latitude = latitude
        self.longitude = longitute
    }
    public func mapping(map:Map){
        locationId <- map["id"]
        phoneNumber <- map["phone"]
        name <- map["name"]
        address <- map["address"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        leavingTime <- map["leavingTime"]
        country <- map["country"]
        state <- map["state"]
        city <- map["city"]
        areaName <- map["areaName"]
        streetName <- map["streetName"]
        shortAddress <- map["shortAddress"]
        if shortAddress == nil{
            shortAddress <- map["address"]
        }
    }
    public func getParams() -> [String : String]{
      AppDelegate.getAppDelegate().log.debug("getParams()")
        var params: [String : String] = [String : String]()
        if(self.locationId != 0) {
            params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.locationId)
        }
        if phoneNumber != nil {
            params[UserFavouriteLocation.PHONE] = String(phoneNumber!).components(separatedBy: ".")[0]
        }
        params[UserFavouriteLocation.NAME] = name!
        params[UserFavouriteLocation.ADDRESS] = address!
        params[UserFavouriteLocation.LATITUDE] = String(latitude!)
        params[UserFavouriteLocation.LONGITUDE] = String(longitude!)
        if leavingTime != nil
        {
            params[UserFavouriteLocation.LEAVING_TIME] = StringUtils.getStringFromDouble(decimalNumber: leavingTime!)
        }
        params[UserFavouriteLocation.CITY] = city
        params[UserFavouriteLocation.STATE] = state
        params[UserFavouriteLocation.COUNTRY] = country
        params[UserFavouriteLocation.AREA_NAME] = areaName
        params[UserFavouriteLocation.STREET_NAME] = streetName
        return params
    }
    public override var description: String {
        return "locationId: \(String(describing: self.locationId))," + "phoneNumber: \(String(describing: self.phoneNumber))," + " name: \( String(describing: self.name))," + " shortAddress: \(String(describing: self.shortAddress))," + " address: \(String(describing: self.address)),"
            + " latitude: \(String(describing: self.latitude))," + "longitude: \(String(describing: self.longitude))," + "leavingTime:\(String(describing: self.leavingTime))," + "country:\(String(describing: self.country))," + "state:\(String(describing: self.state))," + "city:\(String(describing: self.city))," + "areaName: \(String(describing: self.areaName))," + "streetName: \( String(describing: self.streetName)),"
    }
}
