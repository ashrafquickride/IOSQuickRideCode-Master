//
//  TaxiDetailsTime.swift
//  Quickride
//
//  Created by QR Mac 1 on 21/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

 public class TaxiAllocationEngineConfig: Mappable {
    
    
    var  minutesToWaitAfterInstantTripCreationToTriggerAllocation: Int?
    var  minutesToWaitAfterScheduledTripCreationToTriggerAllocation: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationForAbove35KmTrip: Int?
    var  thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip: Int?
    var  thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km: Int?
    var  thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km: Int?
    var  thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km: Int?
    var  thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km: Int?
    var  thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation: Int?
    var  thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km: Int?
    var  thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km: Int?
    var  thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km: Int?
    var  thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km: Int?
    var  thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation: Int?
    
    
    
     required public init?(map: Map) {

     }
  
    
  public func mapping(map: Map) {
        minutesToWaitAfterInstantTripCreationToTriggerAllocation <- map["minutesToWaitAfterInstantTripCreationToTriggerAllocation"]
        minutesToWaitAfterScheduledTripCreationToTriggerAllocation <- map["minutesToWaitAfterScheduledTripCreationToTriggerAllocation"]
        thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationForAbove35KmTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationForAbove35KmTrip"]
        thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip <- map["thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip"]
        thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km <- map["thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km"]
        thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km <- map["thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km"]
        thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km <- map["thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km"]
        thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km <- map["thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km"]
        thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation <- map["thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation"]
        thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km <- map["thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km"]
        thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km <- map["thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km"]
        thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km <- map["thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km"]
        thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km <- map["thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km"]
        thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation <- map["thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation"]
        
    }
     

            var description: String{
                return "minutesToWaitAfterInstantTripCreationToTriggerAllocation: \(String(describing: self.minutesToWaitAfterInstantTripCreationToTriggerAllocation))"
                + "minutesToWaitAfterScheduledTripCreationToTriggerAllocation: \(String(describing: self.minutesToWaitAfterScheduledTripCreationToTriggerAllocation))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationForA2CTrip))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationForC2ATrip))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationForUpto10KmTrip))"
                + " thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationFor10To20KmTrip))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationFor20To35KmTrip))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationForAbove35KmTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationForAbove35KmTrip))"
                + "thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip: \(String(describing: self.thresholdTimeBeforeTripStartToTriggerAllocationForOutstationTrip))"
                + "thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km: \(String(describing: self.thresholdTimeBeforeAutoTripStartToTriggerAllocationForUpto10Km))"
                + "thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km: \(String(describing: self.thresholdTimeBeforeAutoTripStartToTriggerAllocationFor10To20Km))"
                + "thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km: \(String(describing: self.thresholdTimeBeforeAutoTripStartToTriggerAllocationFor20To35Km))"
                + "thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km: \(String(describing: self.thresholdTimeBeforeAutoTripStartToTriggerAllocationForAbove35Km))"
                + "thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation: \(String(describing: self.thresholdTimeBeforeAutoTripStartToTriggerAllocationForOutstation))"
                + "thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km: \(String(describing: self.thresholdTimeBeforeBikeTripStartToTriggerAllocationForUpto10Km))"
                + "thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km: \(String(describing: self.thresholdTimeBeforeBikeTripStartToTriggerAllocationFor10To20Km))"
                + "thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km: \(String(describing: self.thresholdTimeBeforeBikeTripStartToTriggerAllocationFor20To35Km))"
                + "thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km: \(String(describing: self.thresholdTimeBeforeBikeTripStartToTriggerAllocationForAbove35Km))"
                + "thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation: \(String(describing: self.thresholdTimeBeforeBikeTripStartToTriggerAllocationForOutstation))"
            
            }
}
