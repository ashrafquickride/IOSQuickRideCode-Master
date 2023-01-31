//
//  FuelCardRegistration.swift
//  Quickride
//
//  Created by KNM Rao on 25/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FuelCardRegistration : NSObject, Mappable{
    
    static let PREFERRED_FUEL_COMPANY : String = "preferredFuelCompany"
    static let CARD_STATUS : String = "cardStatus"
    static let DELIVERY_ADDRESS : String = "deliveryAddress"
    static let FUEL_CARD_ID : String = "fuelCardId"
    static let FUEL_CARD_HP : String = "HP"
    static let FUEL_CARD_SHELL : String = "Shell"
    static let ACTIVE = "ACTIVE"
    static let PENDING = "PENDING"
    static let OPEN = "OPEN"
    
    
    var preferredFuelCompany : String?
    var deliveryAddress : String?
    var userId : Double?
    var fuelCardId : String?
    var cardStatus : String?
    var houseNo : String?
    var streetName : String?
    var areaName : String?
    var state : String?
    var city : String?
    var pincode : String?
    var contactNo : String?
    
    init(cardType : String, userId: String, contactNo: String?, houseNo: String,streetName: String, areaName: String, state: String, city: String,pincode: String) {
        self.userId = Double(userId)
        self.preferredFuelCompany = cardType
        self.houseNo = houseNo
        self.streetName = streetName
        self.areaName = areaName
        self.state = state
        self.city = city
        self.pincode = pincode
        self.contactNo =  contactNo
    }
    init(userId: String, preferredFuelCompany: String,cardStatus:String) {
        self.userId = Double(userId)
        self.preferredFuelCompany = preferredFuelCompany
        self.cardStatus = cardStatus
    }
    override init(){
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        preferredFuelCompany <- map["preferredFuelCompany"]
        deliveryAddress <- map["deliveryAddress"]
        userId <- map["userId"]
        fuelCardId <- map["fuelCardId"]
        cardStatus <- map["cardStatus"]
        houseNo <- map["houseNo"]
        streetName <- map["streetName"]
        areaName <- map["areaName"]
        state <- map["state"]
        city <- map["city"]
        pincode <- map["pincode"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["type"] = self.preferredFuelCompany
        params["contactNo"] = self.contactNo
        params["accountid"] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params["houseNo"] = self.houseNo
        params["streetName"] = self.streetName
        params["areaName"] = self.areaName
        params["state"] = self.state
        params["city"] = self.city
        params["pincode"] = self.pincode
        return params
    }
    public override var description: String {
        return "preferredFuelCompany: \(String(describing: self.preferredFuelCompany))," + "deliveryAddress: \(String(describing: self.deliveryAddress))," + " userId: \(String(describing: self.userId))," + " fuelCardId: \(String(describing: self.fuelCardId))," + " cardStatus: \(String(describing: self.cardStatus)),"
            + "houseNo: \(String(describing: self.houseNo))," + "streetName: \(String(describing: self.streetName))," + "areaName: \(String(describing: self.areaName))," + "state: \(String(describing: self.state))," + "city: \(String(describing: self.city))," + "pincode: \(String(describing: self.pincode)),"
    }
    
}
