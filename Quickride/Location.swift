
//
//  Location.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 03/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

class Location : NSObject,Mappable{
    
    var  id : Double = 0
    var  name : String?
    var  shortAddress : String?
    var  completeAddress : String?
    var  placeId :String?
    var  state :String?
    var  latitude : Double = 0
    var  longitude: Double = 0
    var  locationType : String?
    var  country : String?
    var  city : String?
    var  areaName : String?
    var  streetName : String?
    var  offline = false
    var  address : String?
    
    static let FAVOURITE_LOCATION  = "FAVOURITE_LOCATION"
    static let RECENT_LOCATION  = "RECENT_LOCATION"
    static let COUNTRY = "country"
    static let ADMINISTRATIVE_AREA_1 = "administrative_area_level_1"
    static let LOCALITY = "locality"
    static let SUB_LOCALITY_LEVEL_1 = "sublocality_level_1"
    static let SUB_LOCALITY_LEVEL_2 = "sublocality_level_2"
    static let ADDRESS = "address"
    static let REGION = "region"
    static let FLD_CHARSEQUENCE = "charSequence"
    static let FLD_LATITUDE = "latitude"
    static let FLD_LONGITUDE = "longitude"
    static let FLD_READ_FROM_GOOGLE = "readFromGoogle"
    static let FLD_AUTO_COMPLETE_DATA = "autoCompleteData"
    static let FLD_PLACE_ID = "placeId"
    
    
    override init(){
        
    }
    
    init(id : Double,latitude : Double, longitude : Double,shortAddress : String?,completeAddress : String?,country : String? ,state : String?,city : String?,areaName : String?,streetName : String?){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.shortAddress = shortAddress
        self.completeAddress = completeAddress
        self.address = completeAddress
        self.state = state
        self.city = city
        self.country = country
        self.areaName = areaName
        self.streetName = streetName
    }
    init(latitude : Double, longitude : Double,shortAddress : String?){
        self.latitude = latitude
        self.longitude = longitude
        self.shortAddress = shortAddress
        self.completeAddress = shortAddress
        self.address = shortAddress
    }
    init(latitude : Double, longitude : Double,shortAddress : String?,completeAddress : String?,placeId : String?,locationType : String,country : String? ,state : String?,city : String?,areaName : String?,streetName : String?){
        self.placeId = placeId
        self.latitude = latitude
        self.longitude = longitude
        self.shortAddress = shortAddress
        self.completeAddress = completeAddress
        self.address = completeAddress
        self.locationType = locationType
        self.country = country
        self.state = state
        self.city = city
        self.areaName = areaName
        self.streetName = streetName
    }
    init(favouriteLocation : UserFavouriteLocation){
        self.shortAddress = favouriteLocation.shortAddress
        if self.shortAddress == nil{
            self.shortAddress = Location.getConsolidatedNameFromFormattedAddress(name: favouriteLocation.address)
        }
        self.completeAddress = favouriteLocation.address
        self.address = self.completeAddress
        if favouriteLocation.latitude != nil && favouriteLocation.longitude != nil{
            self.latitude = favouriteLocation.latitude!
            self.longitude = favouriteLocation.longitude!
        }
        self.locationType = Location.FAVOURITE_LOCATION
    }

    static func getConsolidatedNameFromFormattedAddress( name : String?) -> String{
        if name == nil {return ""}
        return name!.components(separatedBy: ",")[0]
    }
    func getConsolidatedNameFromCompleteAddress( name : String?) -> String{
        if name == nil {return ""}
        var components =  name!.components(separatedBy: ", ")
        components.removeLast()
        return components.joined(separator: ", ")
    }
    static func validateLocationForCountry( locationDescription : String) -> Bool{
        return locationDescription.contains(GoogleMapUtils.COUNTRY_NAME_INDIA)
        
    }

    func getCoordinate() -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.completeAddress <- map["completeAddress"]
        if self.completeAddress == nil {
            self.completeAddress <- map["address"]
        }
        if completeAddress == nil{
            self.completeAddress <- map["formattedAddress"]
        }
        self.shortAddress <- map["shortAddress"]
        if self.shortAddress == nil {
            self.shortAddress <- map["address"]
        }
        if shortAddress == nil{
            self.shortAddress <- map["locationName"]
        }
        if shortAddress == nil{
             self.shortAddress = completeAddress
        }
        
        self.address <- map["address"]
        if address == nil{
            self.address <- map["formattedAddress"]
        }
        self.placeId <- map["placeId"]
        self.latitude <- map["latitude"]
        if self.latitude == 0{
             self.latitude <- map["lat"]
        }
        self.longitude <- map["longitude"]
        if self.longitude == 0{
             self.longitude <- map["lon"]
        }
        self.locationType <- map["locationType"]
        self.state <- map["state"]
        self.country <- map["country"]
        self.city <- map["city"]
        self.areaName <- map["areaName"]
        self.streetName <- map["streetName"]
        self.id <- map["id"]
        self.name <- map["name"]
        self.offline <- map["offline"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "name: \(String(describing: self.name))," + " shortAddress: \( String(describing: self.shortAddress))," + " completeAddress: \(String(describing: self.completeAddress))," + " placeId: \(String(describing: self.placeId)),"
            + " state: \(String(describing: self.state))," + "latitude: \(String(describing: self.latitude))," + "longitude:\(String(describing: self.longitude))," + "locationType:\(String(describing: self.locationType))," + "country:\(String(describing: self.country))," + "city:\(String(describing: self.city))," + "areaName:\(String(describing: self.areaName))," + "streetName:\(String(describing: self.streetName)),"
    }
    
}
