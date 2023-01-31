//
//  LocationResponse.swift
//  Quickride
//
//  Created by KNM Rao on 14/06/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LocationResponse : NSObject, Mappable {
    
    var results : [Results]?
    var status : String?
    var error_message : String?
    required init?(map:Map){
        
    }
    
    
    func mapping(map: Map) {
        self.results <- map["results"]
        self.status <- map["status"]
        self.error_message <- map["error_message"]
    }
    public override var description: String {
        return "results: \(String(describing: self.results))," + "status: \(String(describing: self.status))," + " error_message: \( String(describing: self.error_message)),"
    }
    
    
    
}
class Results :NSObject, Mappable{
    var address_components : [Address_components]?
    var formatted_address : String?
    var geometry : Geometry?
    var place_id : String?
    var types : [String]?
    
    func getAdministrativeArea() -> String?{
        if address_components == nil{
            return nil
        }
        for component in address_components!{
            if types == nil{
                continue
            }
            for type in component.types!{
                if type == "administrative_area_level_1"{
                    return component.long_name
                }
            }
        }
        return nil
    }
    
    required init?(map:Map){
        
    }
    
    
    func mapping(map: Map) {
        self.address_components <- map["address_components"]
        self.formatted_address <- map["formatted_address"]
        self.geometry <- map["geometry"]
        self.place_id <- map["place_id"]
        self.types <- map["types"]
    }
    public override var description: String {
        return "address_components: \(String(describing: self.address_components))," + "formatted_address: \(String(describing: self.formatted_address))," + " geometry: \( String(describing: self.geometry))," + "place_id: \(String(describing: self.place_id))," + " types: \( String(describing: self.types)),"
    }
}

class Address_components :NSObject, Mappable {
    var long_name : String?
    var short_name : String?
    var types : [String]?
    
    required init?(map:Map){
        
    }
    
    
    
    func mapping(map: Map) {
        self.long_name <- map["long_name"]
        self.short_name <- map["short_name"]
        self.types <- map["types"]
    }
    public override var description: String {
        return "long_name: \(String(describing: self.long_name))," + "short_name: \(String(describing: self.short_name))," + " types: \( String(describing: self.types)),"
    }
    
}
class Geometry :NSObject, Mappable{
    var location : Point?
    var location_type : String?
    
    
    required init?(map:Map){
        
    }
    
    func mapping(map: Map) {
        self.location <- map["location"]
        self.location_type <- map["location_type"]
    }
    public override var description: String {
        return "location: \(String(describing: self.location))," + "location_type: \(String(describing: self.location_type)),"
    }
}
class Point :NSObject, Mappable {
    var lat : Double?
    var lng : Double?
    
    required init?(map:Map){
        
    }
    
    func mapping(map: Map) {
        self.lat <- map["lat"]
        self.lng <- map["lng"]
    }
    public override var description: String {
        return "lat: \(String(describing: self.lat))," + "lng: \(String(describing: self.lng)),"
    }
}
