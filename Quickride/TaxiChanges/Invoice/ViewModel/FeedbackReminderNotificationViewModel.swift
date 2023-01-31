//
//  FeedbackReminderNotificationViewModel.swift
//  Quickride
//
//  Created by Rajesab on 20/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class FeedbackReminderNotificationViewModel {
    var taxiFeedBackNotification: TaxiFeedBackNotification?
    
    init() {}
    init(taxiFeedBackNotification: TaxiFeedBackNotification?){
        self.taxiFeedBackNotification = taxiFeedBackNotification
    }
}
