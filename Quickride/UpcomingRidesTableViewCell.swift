//
//  UpcomingRidesTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import DropDown

class UpcomingRidesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ridesCollectionView: UICollectionView!
    private var upcomingRides = [Ride]()
    
    func initialiseNextRides(upcomingRides: [Ride]){
        self.upcomingRides = upcomingRides
        self.upcomingRides.sort(by: { $0.startTime < $1.startTime})
        ridesCollectionView.register(UINib(nibName: "UpcomingRideCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingRideCollectionViewCell")
        ridesCollectionView.reloadData()
    }
    @IBAction func viewAllButtonTapped(_ sender: Any) {
        let myTripsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyRidesDetailViewController") as! MyRidesDetailViewController
        self.parentViewController?.navigationController?.pushViewController(myTripsViewController, animated: false)
    }
}
extension UpcomingRidesTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingRides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingRideCollectionViewCell", for: indexPath) as! UpcomingRideCollectionViewCell
        if upcomingRides.endIndex <= indexPath.row{
            return cell
        }
        cell.delegate = self
        cell.overflowButton.tag = indexPath.row
        cell.cellIndexPath = indexPath
        cell.configureView(ride: upcomingRides[indexPath.row])
        cell.configureMatchingListForMyRides(ride:  upcomingRides[indexPath.row], section: indexPath.section, row: indexPath.row, viewController: parentViewController ?? ViewControllerUtils.getCenterViewController())
        return cell
    }
}

extension UpcomingRidesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = ridesCollectionView.frame.size.width
        if upcomingRides.count > 1{
            width = ridesCollectionView.frame.size.width - 40
        }
        return CGSize(width: width, height: ridesCollectionView.frame.size.height)
    }
}
//MARK: MY RIDE CELL DELEGATE
extension UpcomingRidesTableViewCell: MyRidesDetailTableViewCellDelegate {
    func rideEditButtonTapped(ride: Ride?, rideParticipants: [RideParticipant], senderTag: Int, taxiShareRide: TaxiShareRide?, dropDownView: AnchorView?) {
    }
    func createRideButtonTap() {}
    func receivePendingInvitation() {}
    func matchUserProfileButtonTapped(ride: Ride) {
        let sendInviteViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteViewController.initializeDataBeforePresenting(scheduleRide: ride, isFromCanceRide: false, isFromRideCreation: false)
        parentViewController?.navigationController?.pushViewController(sendInviteViewController, animated: false)
    }
    
    func cellButtonTapped(ride: Ride?, indexPath: IndexPath) {
        var isRequiredToShowRelayRide = ""
        if ride?.rideType == Ride.PASSENGER_RIDE,let relayRide = (ride as? PassengerRide)?.relayLeg{
            if relayRide == RelayRideMatch.RELAY_LEG_ONE{
                isRequiredToShowRelayRide = RelayRideMatch.SHOW_FIRST_RELAY_RIDE
            }else if relayRide == RelayRideMatch.RELAY_LEG_TWO{
                isRequiredToShowRelayRide = RelayRideMatch.SHOW_SECOND_RELAY_RIDE
            }
        }
        var alternateRide: Ride?
        if !isRequiredToShowRelayRide.isEmpty{
            alternateRide = MyActiveRidesCache.getRidesCacheInstance()?.getOtherChildRelayRide(ride: ride as? PassengerRide)
        }
        let firstRide: Ride?
        let secondRide: Ride?
        if isRequiredToShowRelayRide == RelayRideMatch.SHOW_FIRST_RELAY_RIDE{
            firstRide = ride
            secondRide = alternateRide
        }else if isRequiredToShowRelayRide == RelayRideMatch.SHOW_SECOND_RELAY_RIDE{
            firstRide = alternateRide
            secondRide = ride
        }else{
            firstRide = ride
            secondRide = nil
        }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: firstRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: secondRide,requiredToShowRelayRide: isRequiredToShowRelayRide)
        ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: mainContentVC, animated: false)
    }
}
