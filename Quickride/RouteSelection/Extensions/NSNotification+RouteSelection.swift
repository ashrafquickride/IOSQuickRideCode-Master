//
//  NSNotification+RouteSelectiob.swift
//  Quickride
//
//  Created by Quick Ride on 6/16/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

extension NSNotification.Name{
    static let routeReceived = NSNotification.Name("routeReceived")
    static let routeFailed = NSNotification.Name("routeFailed")
    static let routeContainLoops = NSNotification.Name("routeContainLoops")
    static let viaPointsChanged = NSNotification.Name("viaPointsChanged")
    static let newViaPointChanged = NSNotification.Name("newViaPointChanged")
    static let viaPointEditUndone = NSNotification.Name("viaPointEditUndone")
    static let rideDetailsChanged = NSNotification.Name("rideDetailsChanged")
}
