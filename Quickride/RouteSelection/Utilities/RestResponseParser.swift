//
//  RestResponseParser.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
struct RestResponseParser<T :BaseMappable>{
    
    func parse(responseObject: NSDictionary?,error: NSError?) -> (T?,ResponseError?,NSError?) {
        if let result = responseObject?["result"] as? String{
            switch result {
            case HttpUtils.RESPONSE_SUCCESS:
                if let result = Mapper<T>().map(JSONObject: responseObject!["resultData"]){
                    return(result,nil,nil)
                }
            case HttpUtils.RESPONSE_FAILURE:
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"]){
                    return(nil,responseError,nil)
                }
            default:
                return(nil,nil,error)
            }
        }
        return(nil,nil,error)
    }
    func parseArray(responseObject: NSDictionary?,error: NSError?) -> ([T]?,ResponseError?,NSError?) {
        if let result = responseObject?["result"] as? String{
            switch result {
            case HttpUtils.RESPONSE_SUCCESS:
                if let result = Mapper<T>().mapArray(JSONObject: responseObject!["resultData"]){
                    return(result,nil,nil)
                }
            case HttpUtils.RESPONSE_FAILURE:
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"]){
                    return(nil,responseError,nil)
                }
            default:
                return(nil,nil,error)
            }
        }
        return(nil,nil,error)
    }
}
