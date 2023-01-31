//
//  RelayRideMatchTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 10/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class RelayRideMatchTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var firstLegUserImageView: UIImageView!
    @IBOutlet weak var secondLegUserImageView: UIImageView!
    @IBOutlet weak var firstLegUserNameLabel: UILabel!
    @IBOutlet weak var secondLegUserNameLabel: UILabel!
    @IBOutlet weak var routeMatchLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pickUpTimeLabel: UILabel!
    @IBOutlet weak var viewAllButtonExtendedView: UIView!
    
    //Walk path
    @IBOutlet weak var stopOverLocationLabel: UILabel!
    @IBOutlet weak var walkDistanceView: UIView!
    @IBOutlet weak var walkingDistanceLabel: UILabel!
    @IBOutlet weak var walkingDistanceAfterRideLabel: UILabel!
    @IBOutlet weak var walkDistanceAfterRideView: UIView!
    @IBOutlet weak var walkingDistance2ndPickup: UILabel!
    
    private var ride: Ride?
    private var relayRideMatch: RelayRideMatch?
    override func prepareForReuse() {
        self.firstLegUserImageView.image = nil
        self.secondLegUserImageView.image = nil
    }
    
    func initializeRelayRideMatch(relayRideMatch: RelayRideMatch, ride: Ride){
        self.ride = ride
        self.relayRideMatch = relayRideMatch
        ImageCache.getInstance().setImageToView(imageView: firstLegUserImageView, imageUrl: relayRideMatch.firstLegMatch?.imageURI ?? "", gender: relayRideMatch.firstLegMatch?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        ImageCache.getInstance().setImageToView(imageView: secondLegUserImageView, imageUrl: relayRideMatch.secondLegMatch?.imageURI ?? "", gender: relayRideMatch.secondLegMatch?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        firstLegUserNameLabel.text = relayRideMatch.firstLegMatch?.name
        secondLegUserNameLabel.text = relayRideMatch.secondLegMatch?.name
        routeMatchLabel.text = "\(relayRideMatch.totalMatchingPercent)" + Strings.percentage_symbol
        pointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: relayRideMatch.totalPoints) + " " + Strings.points_new
        pickUpTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: relayRideMatch.firstLegMatch?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        stopOverLocationLabel.text = (relayRideMatch.midLocationAddress ?? "") + " " + "(\(relayRideMatch.timeDeviationInMins) min)"
        
        let startLocation = CLLocation(latitude:ride.startLatitude,longitude: ride.startLongitude)
        let pickUpLoaction = CLLocation(latitude: relayRideMatch.firstLegMatch?.pickupLocationLatitude ?? 0,longitude: relayRideMatch.firstLegMatch?.pickupLocationLongitude ?? 0)
        let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: ride.routePathPolyline)
        walkingDistanceLabel.text = getDistanceString(distance: startToPickupWalkDistance)
        
        let firstDropLocation = CLLocation(latitude:relayRideMatch.firstLegMatch?.dropLocationLatitude ?? 0,longitude: relayRideMatch.firstLegMatch?.dropLocationLongitude ?? 0)
        let secondPickupLocation = CLLocation(latitude: relayRideMatch.secondLegMatch?.pickupLocationLatitude ?? 0,longitude: relayRideMatch.secondLegMatch?.pickupLocationLongitude ?? 0)
        let dropToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: firstDropLocation, point2: secondPickupLocation, polyline: ride.routePathPolyline)
        walkingDistance2ndPickup.text = getDistanceString(distance: dropToPickupWalkDistance)
        
        let endLocation =  CLLocation(latitude: ride.endLatitude ?? 0, longitude: ride.endLongitude ?? 0)
        let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: relayRideMatch.secondLegMatch?.dropLocationLatitude ?? 0, longitude: relayRideMatch.secondLegMatch?.dropLocationLongitude ?? 0), point2: endLocation , polyline: ride.routePathPolyline)
        walkingDistanceAfterRideLabel.text = getDistanceString(distance: dropToEndWalkDistance)
        
    }
    func getDistanceString( distance: Double) -> String {
        if distance > 1000{
            var convertDistance = (distance/1000)
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
    
    @IBAction func joinRelayTapped(_ sender: UIButton) {
        guard let rideObj = ride, let match = relayRideMatch else { return }
        let relayRidesCreationViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RelayRidesCreationViewController") as! RelayRidesCreationViewController
        relayRidesCreationViewController.initializeView(parentRide: rideObj, relayRideMatch: match)
        ViewControllerUtils.addSubView(viewControllerToDisplay: relayRidesCreationViewController)
    }
}
