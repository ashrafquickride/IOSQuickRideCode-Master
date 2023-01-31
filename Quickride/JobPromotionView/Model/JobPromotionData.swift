//
//  JobPromotionData.swift
//  Quickride
//
//  Created by Vinutha on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class JobPromotionData: NSObject, Mappable {
    
    
    var id = 0
    var userId = 0
    var name: String?
    var budget = 0.0
    var startTime = 0
    var endTime = 0
    var status: String?
    var costPerImpression = 0.0
    var availableBudget = 0.0
    var type: String?
    var createdTime = 0
    var modifiedTime = 0
    var targetCohort: String?
    var screens: String?
    var bannerType: String?
    var imageUrl: String?
    var referenceId = 0
    var displayDurationInSeconds = 0
    var maxImpressionsPerUser = 0
    var html: String?
    var deeplinkForPostedJob: String?
    var isImpressionSaved = false // for saving purpuse in appside
    
    
    static let CAMPAIGN_DATA = "campaignData"
    static let CAMPAIGN_ID = "id"
    static let STATUS = "status"
    static let USER_ID = "userId"
    
    
    // Status types
    static let STATUS_PENDING = "PENDING"
    static let STATUS_APPROVED = "APPROVED"
    static let STATUS_EXPIRED = "EXPIRED"
    static let STATUS_SUSPENDED = "SUSPENDED"
    
    // Campaign types
    static let CAMPAIGN_TYPE_JOB = "JOB"
    
    // Banner types
    static let SINGLE_IMAGE_BANNER = "SingleImage"
    static let DOUBLE_IMAGE_BANNER = "DoubleImage"
    static let FULL_IMAGE_BANNER = "FullImage"
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        name <- map["name"]
        budget <- map["budget"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        status <- map["status"]
        costPerImpression <- map["costPerImpression"]
        availableBudget <- map["availableBudget"]
        type <- map["type"]
        targetCohort <- map["targetCohort"]
        modifiedTime <- map["modifiedTime"]
        createdTime <- map["createdTime"]
        screens <- map["screens"]
        bannerType <- map["bannerType"]
        referenceId <- map["referenceId"]
        imageUrl <- map["imageUrl"]
        displayDurationInSeconds <- map["displayDurationInSeconds"]
        maxImpressionsPerUser <- map["maxImpressionsPerUser"]
        html <- map["html"]
        deeplinkForPostedJob <- map["deeplinkForPostedJob"]
    }
    
    public override var description: String {
        return "id: \(String(describing: id))," + "userId: \(String(describing: userId))," + " name: \( String(describing: name))," + " budget: \(String(describing: budget))" + "startTime: \(String(describing: startTime))," + "endTime: \(String(describing: endTime))," + " status: \( String(describing: status))," + " costPerImpression: \(String(describing: costPerImpression))" + "availableBudget: \(String(describing: availableBudget))," + "type: \(String(describing: type))," + " targetCohort: \( String(describing: targetCohort))," + " modifiedTime: \(String(describing: modifiedTime))" + "createdTime: \(String(describing: createdTime))," + "screens: \(String(describing: screens))," + "bannerType: \(String(describing: bannerType))," + " referenceId: \( String(describing: referenceId))," + " imageUrl: \(String(describing: imageUrl))" + "displayDurationInSeconds: \(String(describing: displayDurationInSeconds))," + "maxImpressionsPerUser: \(String(describing: maxImpressionsPerUser))," + " html: \( String(describing: html)),"
    }
    
}
