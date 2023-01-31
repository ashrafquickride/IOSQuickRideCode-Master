//
//  InstantRideMatchedUserDetailTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 16/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InstantRideMatchedUserDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var matchedUsersCollectionView: UICollectionView!
    
    var viewModel = SendInviteViewModel()
    var viewController: SendInviteBaseViewController!
    
    func initialiseData(viewModel: SendInviteViewModel, viewController: SendInviteBaseViewController){
        self.viewModel = viewModel
        self.viewController = viewController
        matchedUsersCollectionView.register(UINib(nibName: "InstantRideMatchedUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InstantRideMatchedUserCollectionViewCell")
        matchedUsersCollectionView.delegate = self
        matchedUsersCollectionView.dataSource = self
        matchedUsersCollectionView.reloadData()
    }
}
extension InstantRideMatchedUserDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.readyToGoMatches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = matchedUsersCollectionView.dequeueReusableCell(withReuseIdentifier: "InstantRideMatchedUserCollectionViewCell", for: indexPath) as! InstantRideMatchedUserCollectionViewCell
        var routeMetrics: RouteMetrics?
        if let rideParticipant = SharedPreferenceHelper.getMatchedUserRideLocation(participantId: viewModel.readyToGoMatches[indexPath.row].userid ?? 0) {
            routeMetrics = viewModel.getRouteMetrics(rideParticipantLocation: rideParticipant)
        } else {
            viewModel.checkForRidePresentLocation(targetViewController: viewController)
        }
        cell.initialiseUIWithData(ride: viewModel.scheduleRide, matchedUser: viewModel.readyToGoMatches[indexPath.row], viewController: viewController, viewType: DetailViewType.MatchedUserView, selectedIndex: indexPath.row, drawerState: nil, routeMetrics: routeMetrics, rideInviteActionCompletionListener: viewController, userSelectionDelegate: viewController, selectedUserDelegate: nil)
        if viewModel.readyToGoMatches.count == 1{
            cell.cellWidth.constant = viewController.view.frame.size.width - 25
        }else {
            cell.cellWidth.constant = viewController.view.frame.size.width - 65
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewController.goToProfile(index: indexPath.row, isFromReadyToGo: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = matchedUsersCollectionView.frame.size.width
        if viewModel.matchedUsers.count > 1{
            width = matchedUsersCollectionView.frame.size.width - 40
        }
        return CGSize(width: width, height: matchedUsersCollectionView.frame.size.height)
    }
}
