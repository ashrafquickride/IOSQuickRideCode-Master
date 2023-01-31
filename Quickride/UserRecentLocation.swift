//
//  UserRecentLocation.swift
//  Quickride
//
//  Created by KNM Rao on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class UserRecentLocation{
    
    var recentLocationId : String?
    var recentAddress : String?
    var recentAddressName : String?
    var latitude : Double?
    var longitude : Double?
    var time : Double = 0
    var country:String?
    var state:String?
    var city:String?
    var areaName:String?
    var streetName:String?
    
    init(){
        
    }
    
    init(recentLocationId : String , recentAddress : String,recentAddressName : String, latitude : Double, longitude : Double, country:String?, state:String?, city:String? , areaName:String?, streetName:String?){
        self.recentLocationId = recentLocationId
        self.recentAddress = recentAddress
        self.recentAddressName = recentAddressName
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.city = city
        self.areaName = areaName
        self.streetName = streetName
        self.state = state
    }
    
    
}
