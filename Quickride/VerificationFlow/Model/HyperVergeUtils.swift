//
//  HyperVergeUtils.swift
//  Quickride
//
//  Created by Vinutha on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import HyperSnapSDK

public class HyperVergeUtils: NSObject {
    
    static var shared = HyperVergeUtils()
    
    func getDocumentType(verificationType: String) -> HyperSnapParams.DocumentType{
        if verificationType == PersonalIdDetail.VOTER_ID {
            return .other
        } else {
            return .card
        }
    }
    
    func getAspectRatio(verificationType: String) -> Double{
        if verificationType == PersonalIdDetail.VOTER_ID {
            return 1.5
        } else {
            return 0.625
        }
    }
    
    func getEndpoint(verificationType: String)->String {
        if verificationType == PersonalIdDetail.DL {
            return ConfigurationCache.getObjectClientConfiguration().hyperVergeReadDL
        } else {
            return ConfigurationCache.getObjectClientConfiguration().hyperVergeReadKyc
        }
    }
    
    func getFaceMatchEndpoint()->String{
        return ConfigurationCache.getObjectClientConfiguration().hyperVergeFaceIDMatch
    }
}
