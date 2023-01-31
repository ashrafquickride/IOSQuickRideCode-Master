//
//  UserPrimaryAreaInfo.swift
//  Quickride
//
//  Created by Vinutha on 12/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserPrimaryAreaInfo: NSObject, Mappable{
    
    var userId: Double?
    var recentCountry: String?
    var recentState: String?
    var recentCity: String?
    var recentAreaName: String?
    var recentStreetName: String?
    var recentAddress: String?
    var recentLattitude: Double = 0
    var recentLongitude: Double = 0

    var registeredCountry: String?
    var registeredState: String?
    var registeredCity: String?
    var registeredAreaName: String?
    var registeredStreetName: String?
    var registeredAddress: String?
    var registeredLattitude: Double = 0
    var registeredLongitude: Double = 0
    
    var homeCountry: String?
    var homeState: String?
    var homeCity: String?
    var homeAreaName: String?
    var homeStreetName: String?
    var homeAddress: String?
    var homeLattitude: Double = 0
    var homeLongitude: Double = 0
    
    var officeCountry: String?
    var officeState: String?
    var officeCity: String?
    var officeAreaName: String?
    var officeStreetName: String?
    var officeAddress: String?
    var officeLattitude: Double = 0
    var officeLongitude: Double = 0
    
    static let recent_country = "recentCountry"
    static let recent_state = "recentState"
    static let recent_city = "recentCity"
    static let recent_area_name = "recentAreaName"
    static let recent_street_name = "recentStreetName"
    static let recent_address = "recentAddress"
    static let recent_lattitude = "recentLattitude"
    static let recent_longitute = "recentLongitude"
    
    init(location: Location) {
        self.recentCountry = location.country
        self.recentState = location.state
        self.recentCity = location.city
        self.recentAreaName = location.areaName
        self.recentAddress = location.address
        self.recentLattitude = location.latitude
        self.recentLongitude = location.longitude
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        recentCountry <- map["recentCountry"]
        recentState <- map["recentState"]
        recentCity <- map["recentCity"]
        recentAreaName <- map["recentAreaName"]
        recentStreetName <- map["recentStreetName"]
        recentAddress <- map["recentAddress"]
        recentLattitude <- map["recentLattitude"]
        recentLongitude <- map["recentLongitude"]
        registeredCountry <- map["registeredCountry"]
        registeredState <- map["registeredState"]
        registeredCity <- map["registeredCity"]
        registeredAreaName <- map["registeredAreaName"]
        registeredStreetName <- map["registeredStreetName"]
        registeredAddress <- map["registeredAddress"]
        registeredLattitude <- map["registeredLattitude"]
        registeredLongitude <- map["registeredLongitude"]
        homeCountry <- map["homeCountry"]
        homeState <- map["homeState"]
        homeCity <- map["homeCity"]
        homeAreaName <- map["homeAreaName"]
        homeStreetName <- map["homeStreetName"]
        homeAddress <- map["homeAddress"]
        homeLattitude <- map["homeLattitude"]
        homeLongitude <- map["homeLongitude"]
        officeCountry <- map["officeCountry"]
        officeState <- map["officeState"]
        officeCity <- map["officeCity"]
        officeAreaName <- map["officeAreaName"]
        officeStreetName <- map["officeStreetName"]
        officeAddress <- map["officeAddress"]
        officeLattitude <- map["officeLattitude"]
        officeLongitude <- map["officeLongitude"]
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "recentCountry: \(String(describing: self.recentCountry))," + " recentState: \( String(describing: self.recentState))," + " recentCity: \(String(describing: self.recentCity))," + " recentAreaName: \(String(describing: self.recentAreaName)),"
            + " recentStreetName: \(String(describing: self.recentStreetName))," + "recentAddress: \(String(describing: self.recentAddress))," + "recentLattitude:\(String(describing: self.recentLattitude))," + "recentLongitude:\(String(describing: self.recentLongitude))," + "registeredCountry:\(String(describing: self.registeredCountry))," + "registeredState:\(String(describing: self.registeredState))," + "registeredCity: \(String(describing: self.registeredCity))," + "registeredAreaName: \( String(describing: self.registeredAreaName))," + "registeredStreetName: \(String(describing: self.registeredStreetName))," + "registeredAddress: \( String(describing: self.registeredAddress))," + "registeredLattitude: \(String(describing: self.registeredLattitude))," + "registeredLongitude: \( String(describing: self.registeredLongitude))," + "homeCountry:\(String(describing: self.homeCountry))," + "homeState:\(String(describing: self.homeState))," + "homeCity: \(String(describing: self.homeCity))," + "homeAreaName:\(String(describing: self.homeAreaName))," + "homeStreetName: \(String(describing: self.homeStreetName))," + "homeAddress\(String(describing: self.homeAddress))," + "homeLattitude: \(String(describing: self.homeLattitude))," + "homeLongitude: \( String(describing: self.homeLongitude))," + "officeCountry:\(String(describing: self.officeCountry))," + "officeState:\(String(describing: self.officeState))," + "officeState:\(String(describing: self.officeState))," + "officeCity:\(String(describing: self.officeCity))," + "officeAreaName:\(String(describing: self.officeAreaName))," + "officeStreetName:\(String(describing: self.officeStreetName))," + "officeAddress:\(String(describing: self.officeAddress))," + "officeLattitude:\(String(describing: self.officeLattitude))," + "officeLongitude:\(String(describing: self.officeLongitude)),"
    }
}
