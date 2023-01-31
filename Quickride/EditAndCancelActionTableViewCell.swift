//
//  EditAndCancelActionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 26/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class EditAndCancelActionTableViewCell: UITableViewCell,RideObjectUdpateListener,RideCancelDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var scheduleReturnView: UIView!
    @IBOutlet weak var editRideView: UIView!
    @IBOutlet weak var cancelRideView: UIView!
    
    private var currentUserRide = Ride()
    private  var rideParticipants : [RideParticipant]?
    //MARK: Initializer
    func initializeData(ride: Ride,rideParticipants: [RideParticipant]?) {
        self.currentUserRide = ride
        self.rideParticipants = rideParticipants
        handleEditRideButton()
    }
    private func handleEditRideButton() {
        if currentUserRide.rideType == Ride.RIDER_RIDE && currentUserRide.status == Ride.RIDE_STATUS_STARTED {
            editRideView.isHidden = true
        } else {
            editRideView.isHidden = false
        }
    }
    
    @IBAction func editRideTapped(_ sender: UIButton) {
        if currentUserRide.checkIfRideIsValid() {
            let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide))
            let editRideViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideUpdateViewController") as! RideUpdateViewController
            editRideViewController.initializeDataBeforePresentingView(ride: currentUserRide,riderRide: rideDetailInfo?.riderRide,listener : self)
            parentViewController?.navigationController?.pushViewController(editRideViewController, animated: false)
        }
    }
    
    @IBAction func cancelRideTapped(_ sender: UIButton) {
        let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide))
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
        rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(rideParticipants: rideParticipants, rideType: currentUserRide.rideType, isFromCancelRide: true,ride: currentUserRide,vehicelType: rideDetailInfo?.riderRide?.vehicleType, rideUpdateListener: self, completionHandler: {
            self.parentViewController?.parent?.navigationController?.popViewController(animated: false)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }
    
    func rideCancelled() {
        self.parentViewController?.parent?.navigationController?.popViewController(animated: false)
    }
    
    func rideUpdated(ride: Ride) {
        var userInfo = [String: Any]()
        userInfo[LiveRideNSNotificationConstants.RIDE] = ride
        NotificationCenter.default.post(name: .rideUpdated, object: nil, userInfo: userInfo)
    }
    
    @IBAction func scheduleReturnRide(_ sender: Any) {
        if currentUserRide.checkIfRideIsValid(),let returnRide = currentUserRide.copy() as? Ride{
            returnRide.startAddress = currentUserRide.endAddress
            returnRide.startLatitude = currentUserRide.startLatitude
            returnRide.startLongitude = currentUserRide.endLongitude ?? 0
            returnRide.endAddress = currentUserRide.startAddress
            returnRide.endLatitude = currentUserRide.startLatitude
            returnRide.endLongitude = currentUserRide.startLatitude
            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.routeViewController) as! RouteViewController
            routeViewController.initializeDataBeforePresenting(ride: returnRide)
            self.parentViewController?.navigationController?.pushViewController(routeViewController, animated: false)
        }
    }
}

//extension EditAndCancelActionTableViewCell : RouteSelectionDelegate {
//    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
//        QuickRideProgressSpinner.startSpinner()
//        RideServicesClient.updateRideRoute(rideId: currentUserRide.rideId, rideType: currentUserRide.rideType!, rideRoute: route, viewController: nil) { (responseObject, error) in
//            QuickRideProgressSpinner.stopSpinner()
//            let result = RestResponseParser<RideRoute>().parse(responseObject: responseObject, error: error)
//            if let updatedRoute = result.0 {
//                MyActiveRidesCache.getRidesCacheInstance()?.updateRideRoute(rideRoute: updatedRoute, rideId: self.currentUserRide.rideId, rideType: self.currentUserRide.rideType!)
//
//            }else {
//                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController,handler: nil)
//
//            }
//
//        }
//    }
//
//    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {}
//}
