//
//  JobPromotionUtils.swift
//  Quickride
//
//  Created by Vinutha on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class JobPromotionUtils {
    
    static func getJobPromotionDataBasedOnScreen(screenName: String, handler : @escaping(_ jobPromotionData: [JobPromotionData]) -> Void) {
        UserRestClient.getAdsListBasedOnScreen(userId: QRSessionManager.getInstance()?.getUserId() ?? "") {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                let jobPromotionData = Mapper<JobPromotionData>().mapArray(JSONObject: responseObject!["resultData"]) ?? [JobPromotionData]()
                handler(jobPromotionData)
            } else {
                handler([JobPromotionData]())
            }
        }
    }
    
    static func updateJobPromotionViewCount(impressionAudit: ImpressionAudit) {
        UserRestClient.updateAdsImpressionCount(impressionAudit: impressionAudit) {(responseObject, error) in
        }
    }
    
}
