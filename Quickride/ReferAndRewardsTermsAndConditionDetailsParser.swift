//
//  ReferAndRewardsTermsAndConditionDetailsParser.swift
//  Quickride
//
//  Created by Halesh on 03/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias ReferAndRewardsTermsAndConditionHandler = (_ ReferAndRewardsTermsAndConditions : RewardsTermsAndConditions?) -> Void
class ReferAndRewardsTermsAndConditionDetailsParser {
    
    var rewardsTermsAndConditions :  RewardsTermsAndConditions?
    static var instance : ReferAndRewardsTermsAndConditionDetailsParser?
    
    static func getInstance() -> ReferAndRewardsTermsAndConditionDetailsParser{
        if instance == nil{
            instance = ReferAndRewardsTermsAndConditionDetailsParser()
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            let url = clientConfiguration.referAndEarnTermsAndConditionsFileURL
            HttpUtils.performRestCallToOtherServer(url: url, params:  [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
                if responseObject != nil {
                    let rewardsTermsAndConditions = Mapper<RewardsTermsAndConditions>().map(JSONObject: responseObject)
                    instance?.rewardsTermsAndConditions = rewardsTermsAndConditions
                }
            })
        }
        return instance!
    }
    func getRewardsTermsAndConditionElement(handler : @escaping ReferAndRewardsTermsAndConditionHandler){
        if rewardsTermsAndConditions != nil{
            return handler(rewardsTermsAndConditions!)
        }
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let url = clientConfiguration.referAndEarnTermsAndConditionsFileURL
        HttpUtils.performRestCallToOtherServer(url: url, params: [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
            if responseObject != nil {
                let rewardsTermsAndConditions = Mapper<RewardsTermsAndConditions>().map(JSONObject: responseObject)
                self.rewardsTermsAndConditions = rewardsTermsAndConditions
                handler(self.rewardsTermsAndConditions)
            }else{
                handler(self.readFromLocal())
            }
            
        })
    }
    
    func readFromLocal() -> RewardsTermsAndConditions? {
        
        let file = Bundle.main.url(forResource: "ReferAndRewardsTermsAndConditions", withExtension: "json")
        if file == nil{
            return nil
        }
        do {
            let data = try Data(contentsOf: file!)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let rewardsTermsAndCondtions = Mapper<RewardsTermsAndConditions>().map(JSONObject: json)
            return rewardsTermsAndCondtions
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

