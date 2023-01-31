//
//  RideModerationInfoViewModel.swift
//  Quickride
//
//  Created by Vinutha on 30/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideModerationInfoViewModel {
    
    var titleMessage: String?
    var infoImages = [UIImage]()
    var infoTitles = [String]()
    var infoSubTitles = [String]()
    var ridePreferenceReceiver: SaveRidePreferencesReceiver?
    var subTitle: String?
    
    init(titleMessage: String, subTitle: String?, infoImages: [UIImage], infoTitles: [String], infoSubTitles: [String], ridePreferenceReceiver: SaveRidePreferencesReceiver?) {
        self.titleMessage = titleMessage
        self.subTitle = subTitle
        self.infoImages = infoImages
        self.infoTitles = infoTitles
        self.infoSubTitles = infoSubTitles
        self.ridePreferenceReceiver = ridePreferenceReceiver
    }
}
