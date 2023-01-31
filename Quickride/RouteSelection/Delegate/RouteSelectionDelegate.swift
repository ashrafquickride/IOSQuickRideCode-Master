//
//  RouteSelectionDelegate.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
protocol RouteSelectionDelegate {
    func receiveSelectedRoute(ride : Ride?,route : RideRoute)
    func recieveSelectedPreferredRoute(ride : Ride?, preferredRoute : UserPreferredRoute)
}

protocol RentalPackageSelectionDelegate{
    func selectedRentalPackage(packageDistance: Int ,packageDuration: Int)
    func pickUpDateTapped()
    func pickupLocationChanged()
    func showPackageInfo()
}
