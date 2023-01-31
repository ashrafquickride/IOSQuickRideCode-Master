//
//  QuickridePledgeViewModel.swift
//  Quickride
//
//  Created by Admin on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickridePledgeViewModel{
    
    var pledgeImages = [UIImage]()
    var pledgeTitle = [String]()
    var pledgeDetails = [String]()
    var images = [UIImage]()
    var titles = [String]()
    var messages = [String]()
    var isFromLogin = false
    var handler: actionCompletionHandler?
    var actionName: String?
    var heading: String?
    
    init(titles: [String], messages: [String], images: [UIImage], actionName: String, heading: String?, handler: actionCompletionHandler?) {
        self.titles = titles
        self.messages = messages
        self.images = images
        self.handler = handler
        self.actionName = actionName
        self.heading = heading
    }
    
    
    
}
