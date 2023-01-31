//
//  SkillsAndInterestsData.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SkillsAndInterestsData: Mappable {
    
    var interestsData = [UserAttributePopularity]()
    var skillsData = [UserAttributePopularity]()
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        interestsData <- map["interestsData"]
        skillsData <- map["skillsData"]
    }
    
}
