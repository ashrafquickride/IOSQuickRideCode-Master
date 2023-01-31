//
//  RepeatRecurringRideTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 05/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RepeatRecurringRideTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recurringRideDaysLabel: UILabel!
    
    private var ride: Ride?
    func initializeRecurringRideView(rideType: String?,currentUserRideId: Double?,currentRide: Ride?) {
        if currentRide != nil{
            ride = currentRide
        }else{
            if rideType == Ride.RIDER_RIDE{
                ride = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: currentUserRideId ?? 0)
            } else if rideType == Ride.PASSENGER_RIDE{
                ride = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: currentUserRideId ?? 0)
            }
        }
    }
    
    @IBAction func createRecurringRide(_ sender: Any) {
        guard let currentRide = ride else { return }
        let regularRidecreationCreation = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RegularRideCreationViewController") as! RegularRideCreationViewController
        regularRidecreationCreation.initializeView(createRideAsRecuringRide: true, ride: currentRide)
        self.parentViewController?.navigationController?.pushViewController(regularRidecreationCreation, animated: false)
    }
}
