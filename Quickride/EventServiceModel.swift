//
//  EventServiceModel.swift
//  Quickride
//
//  Created by KNM Rao on 18/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class EventServiceModel {
  var uniqueId : String?
  var time : NSDate?
  
  init(uniqueId : String,time : NSDate?){
    self.uniqueId = uniqueId
    self.time = time
  }
}
