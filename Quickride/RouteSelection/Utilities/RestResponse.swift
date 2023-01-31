//
//  RestResponse.swift
//  Quickride
//
//  Created by Quick Ride on 1/27/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RestResponse<T :BaseMappable>{
   
    var result : T?
    var responseError : ResponseError?
    var error : NSError?
    
    init(responseObject: NSDictionary?,error: NSError?)  {
       
        if let result = responseObject?["result"] as? String{
            switch result {
            case HttpUtils.RESPONSE_SUCCESS:
                self.result = Mapper<T>().map(JSONObject: responseObject?["resultData"])
            case HttpUtils.RESPONSE_FAILURE:
                responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
            default:
                self.error = error
            }
        }
    }
    init(result : T) {
        self.result = result
    }
}


