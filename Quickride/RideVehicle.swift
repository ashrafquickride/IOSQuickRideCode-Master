//
//  RideVehicle.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 28/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

import ObjectMapper

public class RideVehicle : NSObject, Mappable{
    var vehicleId : Double = 0
    var rideId : Double = 0
    var model : String?
    var registrationNumber : String?
    var capacity : Int = 0
    var fare : Double = 0
    var imageURI : String?
    var makeAndCategory : String?
    var additionalFacilities : String?
    var vehicleType : String?
    
     init(vehicleId : Double, rideId : Double, model : String, registrationNumber : String, capacity : Int, fare : Double,imageURI : String, makeAndCategory : String,additionalFacilities : String, vehicleType : String) {
        self.vehicleId = vehicleId
        self.rideId = rideId
        self.model = model
        self.registrationNumber = registrationNumber
        self.capacity = capacity
        self.fare = fare
        self.imageURI = imageURI
        self.makeAndCategory = makeAndCategory
        self.additionalFacilities = additionalFacilities
        self.vehicleType = vehicleType
    }
    required public init?(map: Map) {
        
    }
    
    override init(){
        
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["rideId"] = StringUtils.getStringFromDouble(decimalNumber : self.rideId)
        params["vehicleId"] = StringUtils.getStringFromDouble(decimalNumber : self.vehicleId)
        params["model"] =  self.model
        params["capacity"] = String(self.capacity)
        params["fare"] = String(self.fare)
        params["regno"] = self.registrationNumber
        params["imageURI"] = self.imageURI
        params["makeAndCategory"] = self.makeAndCategory
        params["additionalFacilities"] = self.additionalFacilities
        params["vehicleType"] = self.vehicleType
        return params
    }
    
    public func mapping(map: Map) {
        
        rideId <- map["rideId"]
        vehicleId <- map["vehicleId"]
        model <- map["model"]
        capacity <- map["capacity"]
        fare <- map["fare"]
        imageURI <- map["imageURI"]
        registrationNumber <- map["regno"]
        makeAndCategory <- map["makeAndCategory"]
        additionalFacilities <- map["additionalFacilities"]
        vehicleType <- map["vehicleType"]
    }
    public override var description: String {
        return "vehicleId: \(String(describing: self.vehicleId))," + "rideId: \(String(describing: self.rideId))," + " model: \( String(describing: self.model))," + " registrationNumber: \(String(describing: self.registrationNumber))," + " capacity: \(String(describing: self.capacity)),"
            + " fare: \(String(describing: self.fare))," + "imageURI: \(String(describing: self.imageURI))," + "makeAndCategory: \(String(describing: self.makeAndCategory))," + "additionalFacilities: \(String(describing: self.additionalFacilities))," + " vehicleType: \( String(describing: self.vehicleType)),"
    }
}
