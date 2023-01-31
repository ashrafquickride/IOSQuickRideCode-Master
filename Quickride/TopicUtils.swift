//
//  TopicUtils.swift
//  Quickride
//
//  Created by KNM Rao on 15/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class TopicUtils {
    static let QUICKRIDE_TOPIC_PREFIX = ""
    static let WERIDE_TOPIC_PREFIX = "WR"
    static let GRIDE_TOPIC_PREFIX = "GR"
    static let MYRIDE_TOPIC_PREFIX = "MR"
    
//   static func getPrefixForTopic( appName : String)->String {
//    return "WeRide".equalsIgnoreCase(appName)?"WR":("G-Ride".equalsIgnoreCase(appName)?"GR":"");
//    }
  
   static func addPrefixForTopic(appName : String,  topic : String)->String {
//    if User.APP_NAME_GRIDE == appName{
//      return GRIDE_TOPIC_PREFIX+topic
//    }else if User.APP_NAME_WE_RIDE == appName{
//      return WERIDE_TOPIC_PREFIX+topic
//    }else if User.APP_NAME_MYRIDE == appName{
//        return MYRIDE_TOPIC_PREFIX+topic
//    }else{
      return topic
//    }
  }
}
