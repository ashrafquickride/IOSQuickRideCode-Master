//
//  ContactModeratorViewModel.swift
//  Quickride
//
//  Created by Vinutha on 03/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ContactModeratorViewModel {
    
    var rideParticipant: RideParticipant?
    var riderRideId: Double?
    var rideModerators = [RideParticipant]()
    var rideStatusText: String?
    var rideType: String?
    
    init(rideStatusText: String?, rideParticipant: RideParticipant, riderRideId: Double, rideModerators: [RideParticipant], rideType: String) {
        self.rideParticipant = rideParticipant
        self.riderRideId = riderRideId
        self.rideModerators = rideModerators
        self.rideStatusText = rideStatusText
        self.rideType = rideType
    }
    
    func getFullName() -> String? {
        var prefix: String?
        if let name = self.rideParticipant?.name {
            if self.rideParticipant?.gender == User.USER_GENDER_MALE {
                prefix = "Mr. " + name
            } else if self.rideParticipant?.gender == User.USER_GENDER_FEMALE{
                prefix = "Ms. " + name
            } else {
                prefix = name
            }
        }
        return prefix
    }
    
    func getSubTitleBasedOnGender() -> String? {
        var text: String?
        if self.rideParticipant?.gender == User.USER_GENDER_MALE {
            text = String(format: Strings.rider_driving_not_able_attent_call, arguments: ["He"])
        } else if self.rideParticipant?.gender == User.USER_GENDER_FEMALE{
            text = String(format: Strings.rider_driving_not_able_attent_call, arguments: ["She"])
        } else {
            text = String(format: Strings.rider_driving_not_able_attent_call, arguments: ["Rider"])
        }
        return text
    }
    
}
