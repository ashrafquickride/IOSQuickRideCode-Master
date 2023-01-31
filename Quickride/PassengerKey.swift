//
//  PassengerKey.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerKey:NSObject,Mappable{
  
    private var rideid:Double?
    private var passengerid:Double?
    
    required init(map:Map){
        
    }
    func mapping(map:Map){
        rideid <- map["rideid"]
        passengerid <- map["passengerid"]
        
    }
    public override var description: String {
        return "rideid: \(String(describing: self.rideid))," + "passengerid: \(String(describing: self.passengerid)),"
    }
    
}
