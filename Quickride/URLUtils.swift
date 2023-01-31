//
//  URLUtils.swift
//  Quickride
//
//  Created by Quick Ride on 7/8/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class URLUtils {
    
    static func appendMobileViewQueryItem(_ urlString: String?)->URL?{
        guard let urlString = urlString else { return nil }
        let queryItem = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  urlString)
        if let _ = urlcomps?.queryItems{
            urlcomps?.queryItems?.append(queryItem)
        }else{
            urlcomps?.queryItems = [queryItem]
        }
        return urlcomps?.url
        
    }
    
    
}
