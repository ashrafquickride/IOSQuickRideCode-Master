//
//  Vehicle.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class Vehicle :NSObject, Mappable,NSCopying{
  
  var vehicleId : Double = 0
  var ownerId : Double = 0
  var vehicleModel : String = ""
  var registrationNumber : String = ""
  var capacity : Int = 0
  var fare : Double = 0
  var imageURI : String?
  var makeAndCategory : String?
  var additionalFacilities : String?
  var vehicleType : String?
  var defaultVehicle = false
  var riderHasHelmet = true
  var status  = Vehicle.VEHICLE_STATUS_ACTIVE
    
  static let VEHICLE_TYPE_BIKE = "Bike";
  static let BIKE_MODEL_SPORTS = "Sports Bike";
  static let BIKE_MODEL_SCOOTER = "Scooter";
  static let BIKE_MODEL_REGULAR = "Regular Bike";
  static let BIKE_MODEL_CRUISE = "Cruise Bike";
  static let VEHICLE_TYPE_CAR = "Car";
  static let VEHICLE_MODEL_HATCHBACK = "Hatch Back";
  static let VEHICLE_MODEL_SEDAN = "Sedan";
  static let VEHICLE_MODEL_SUV = "SUV";
  static let VEHICLE_MODEL_PREMIUM = "Premium";
  static let VEHICLE_MODEL_KOMBI = "Kombi";
  static let VEHICLE_TYPE_TAXI = "Taxi";
  static let VEHICLE_STATUS_ACTIVE = "Active";
  static let VEHICLE_STATUS_INACTIVE = "InActive";
  static let IMAGE_URI = "vehicleImageURI";
    
  public static let FLD_OWNER_ID = "ownerid"
  public static let FLD_VEHICLE_ID = "id"
  public static let FLD_REG_NO = "regno"
  public static let FLD_STATUS = "status"
  public static let FLD_TYPE = "type"
  public static let FLD_SOURCE = "source"
  public static let FLD_DL_NUM = "dlNumber"
    
  public static let VEHICLE_MAX_FARE : Double = 15.0
  public static let VEHICLE_MIN_CAPACITY : Int = 1
  public static let VEHICLE_MAX_CAPACITY : Int = 50
  public static let VEHICLE_MAX_REGNO_LENGTH : Int = 15
  public static let BIKE_MAX_CAPACITY : Int = 1
    
  public static let VEHICLE_SEAT_CAPACITY_1 = "1"
  public static let VEHICLE_SEAT_CAPACITY_2 = "2"
  public static let VEHICLE_SEAT_CAPACITY_3 = "3"
  public static let VEHICLE_SEAT_CAPACITY_4 = "4"
  public static let VEHICLE_SEAT_CAPACITY_5 = "5"
  public static let VEHICLE_SEAT_CAPACITY_6 = "6"
  
  required public init?(map: Map) {
    
  }
  
  override init(){
    
  }
  
  init(ownerId : Double, vehicleModel : String, registrationNumber : String?, capacity : Int, fare : Double){
    super.init()

    self.ownerId = ownerId
    self.vehicleModel = vehicleModel
    if registrationNumber != nil{
      self.registrationNumber = registrationNumber!
    }
    if vehicleType == nil || vehicleType!.isEmpty{
      vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: vehicleModel)
    }
    self.capacity = capacity
    self.fare = fare
    
  }
  init(ownerId : String?, vehicleModel : String?, registrationNumber : String?, capacity : Int?, fare : Double?, imageURI : String?){
    
    if ownerId != nil{
      self.ownerId = Double(ownerId!)!
    }
    if (imageURI != nil) {
      self.imageURI = imageURI!
    }

    self.vehicleModel = vehicleModel!
    if (registrationNumber != nil) {
      self.registrationNumber = registrationNumber!
    }
    if (capacity != nil) {
      self.capacity = capacity!
    }
    if (fare != nil) {
      self.fare = fare!
    }
  }
    init(ownerId : Double, vehicleModel : String,vehicleType : String?, registrationNumber : String?, capacity : Int, fare : Double, makeAndCategory : String?,additionalFacilities : String?,riderHasHelmet : Bool){
    
    self.ownerId = ownerId
    self.vehicleModel = vehicleModel
    if registrationNumber != nil{
      self.registrationNumber = registrationNumber!
    }
    if vehicleType == nil || vehicleType!.isEmpty{
      self.vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: vehicleModel)
    }else{
      self.vehicleType = vehicleType
    }
    
    self.capacity = capacity
    self.fare = fare
    self.makeAndCategory = makeAndCategory
    self.additionalFacilities = additionalFacilities
    self.riderHasHelmet = riderHasHelmet
  }
  static func getDeFaultVehicle() -> Vehicle{
    let vehicle = Vehicle()
    var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    if clientConfiguration == nil
    {
        clientConfiguration = ClientConfigurtion()
    }
    vehicle.vehicleModel = Vehicle.VEHICLE_MODEL_HATCHBACK
    vehicle.vehicleType = Vehicle.VEHICLE_TYPE_CAR
    vehicle.capacity = clientConfiguration!.hatchBackCarDefaultCapacity
    vehicle.fare = clientConfiguration!.carDefaultFare
    return vehicle
  }
  func  getParamsMap() -> [String : String] {
    var params : [String : String] = [String : String]()
    params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.vehicleId)
    params["model"] =  self.vehicleModel
    params["capacity"] = String(self.capacity)
    params["fare"] = String(self.fare)
    params["ownerid"] = StringUtils.getStringFromDouble(decimalNumber: self.ownerId)
    params["regno"] = self.registrationNumber
    params["imageURI"] = self.imageURI
    params["makeAndCategory"] = self.makeAndCategory
    params["additionalFacilities"] = self.additionalFacilities
    params["vehicleType"] = self.vehicleType
    params["defaultVehicle"] = String(self.defaultVehicle)
    params["status"] = self.status
    params["riderHasHelmet"] = String(self.riderHasHelmet)
    return params
  }
  
  public func mapping(map: Map) {
    
    vehicleId <- map["id"]
    ownerId <- map["ownerid"]
    vehicleModel <- map["model"]
    capacity <- map["capacity"]
    fare <- map["fare"]
    imageURI <- map["imageURI"]
    registrationNumber <- map["regno"]
    makeAndCategory <- map["makeAndCategory"]
    additionalFacilities <- map["additionalFacilities"]
    vehicleType <- map["vehicleType"]
    
    if vehicleType == nil || vehicleType!.isEmpty{
      vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: vehicleModel)
    }
    defaultVehicle <- map["defaultVehicle"]
    status <- map["status"]
    riderHasHelmet <- map["riderHasHelmet"]
  }
  static func checkVehicleTypeFromModel(vehicleModel : String?) -> String{
    
    if vehicleModel == Vehicle.BIKE_MODEL_CRUISE || vehicleModel == Vehicle.BIKE_MODEL_SPORTS || vehicleModel == Vehicle.BIKE_MODEL_REGULAR || vehicleModel == Vehicle.BIKE_MODEL_SCOOTER || vehicleModel == Vehicle.VEHICLE_TYPE_BIKE{
      return Vehicle.VEHICLE_TYPE_BIKE
    }else{
      return Vehicle.VEHICLE_TYPE_CAR
    }
  }
  static func isOfferedSeatsValid(offeredSeats : String) -> Bool {
    
    if offeredSeats.isEmpty == true || offeredSeats.count > 2 {
      return false
    }
    let intRegEx = "[0-9]+"
    
    let intTest = NSPredicate(format: "SELF MATCHES %@", intRegEx)
    
    let result = intTest.evaluate(with: offeredSeats)
    let noOfSeats = Int(offeredSeats)!
    if result == true && (noOfSeats <= 0 || noOfSeats > 50){
      return false

    }
    return result
  }
  
  static func isVehicleFareValid(selectedFare : String) -> Bool {
    if selectedFare.isEmpty{
      return false
    }
    let doubleRegEx = "[0-9]?(\\.\\d+)?"
    let doubleTest = NSPredicate(format: "SELF MATCHES %@", doubleRegEx)
    
    let result = doubleTest.evaluate(with: selectedFare)
    if (result == false) {
      return false
    }
    var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
    if clientConfiguration == nil{
      clientConfiguration = ClientConfigurtion()
    }
    if let fare = Double(selectedFare), fare > clientConfiguration!.vehicleMaxFare{
      return false
    }

    return true
  }
  static func isVehicleNumberValid(selectedNumber : String) -> Bool {
    if selectedNumber.isEmpty == true || selectedNumber.count > VEHICLE_MAX_REGNO_LENGTH
    {
      return false
    }
    return true
  }
   public func copy(with zone: NSZone? = nil) -> Any {
    let vehicle = Vehicle()
    vehicle.vehicleId = self.vehicleId
    vehicle.ownerId = self.ownerId
    vehicle.vehicleModel = self.vehicleModel
    vehicle.registrationNumber = self.registrationNumber
    vehicle.capacity = self.capacity
    vehicle.fare = self.fare
    vehicle.imageURI = self.imageURI
    vehicle.makeAndCategory = self.makeAndCategory
    vehicle.additionalFacilities = self.additionalFacilities
    vehicle.vehicleType = self.vehicleType
    vehicle.defaultVehicle = self.defaultVehicle
    vehicle.status = self.status
    vehicle.riderHasHelmet = self.riderHasHelmet
    return vehicle
  }
    public override var description: String {
        return "vehicleId: \(String(describing: self.vehicleId))," + "ownerId: \(String(describing: self.ownerId))," + " vehicleModel: \( String(describing: self.vehicleModel))," + " registrationNumber: \(String(describing: self.registrationNumber))," + " capacity: \(String(describing: self.capacity)),"
            + " fare: \(String(describing: self.fare))," + "imageURI: \(String(describing: self.imageURI))," + "makeAndCategory:\(String(describing: self.makeAndCategory))," + "additionalFacilities:\(String(describing: self.additionalFacilities))," + "vehicleType:\(String(describing: self.vehicleType))," + "defaultVehicle:\(String(describing: self.defaultVehicle))," + "riderHasHelmet: \(String(describing: self.riderHasHelmet))," + "status: \( String(describing: self.status)),"
    }
}
