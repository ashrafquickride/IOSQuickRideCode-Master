//
//  InActiveMatchesTableViewCell.swift
//  Quickride
//
//  Created by HK on 20/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InActiveMatchesTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var numberOfSeatsImageArray = [UIImageView]()
    private var rideInviteActionCompletionListener : RideInvitationActionCompletionListener?
    weak var delegate : MatchedUserTableViewCellProfileVerificationViewDelegate?
    weak var matchedUserSelectionDelegate: MatchedUserTableViewCellUserSelectionDelegate?
    weak var userSelectionDelegate : UserSelectedDelegate?
    var rideId : Double?
    var rideType : String?
    var ride : Ride?
    var row:Int?
    var selectedUser = false
    var inActiveMatchedUser = [MatchedUser]()
    
    func initialiseUIWithData(rideId : Double?, rideType : String?,inactiveMatchUser: [MatchedUser],isSelected : Bool?, matchedUserSelectionDelegate: MatchedUserTableViewCellUserSelectionDelegate, row: Int,ride : Ride?,rideInviteActionCompletionListener : RideInvitationActionCompletionListener?, userSelectionDelegate : UserSelectedDelegate?) {
        selectedUser = isSelected ?? false
        self.matchedUserSelectionDelegate = matchedUserSelectionDelegate
        self.userSelectionDelegate = userSelectionDelegate
        self.inActiveMatchedUser = inactiveMatchUser
        self.rideId = rideId
        self.rideType = rideType
        self.ride = ride
        self.row = row
        self.rideInviteActionCompletionListener = rideInviteActionCompletionListener
        collectionView.register(UINib(nibName: "InActiveMatchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InActiveMatchCollectionViewCell")
        collectionView.reloadData()
        
    }
}
extension InActiveMatchesTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inActiveMatchedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InActiveMatchCollectionViewCell", for: indexPath) as! InActiveMatchCollectionViewCell
        if inActiveMatchedUser.endIndex <= indexPath.row{
            return cell
        }
        cell.initialiseUIWithData(rideId: rideId, rideType: rideType, matchUser: inActiveMatchedUser[indexPath.row], isSelected: selectedUser, matchedUserSelectionDelegate: matchedUserSelectionDelegate!, row: row!, ride: ride, rideInviteActionCompletionListener: rideInviteActionCompletionListener, userSelectionDelegate: userSelectionDelegate,viewController: parentViewController)
        cell.delegate = delegate
        return cell
    }
}
extension InActiveMatchesTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if inActiveMatchedUser.endIndex <= indexPath.row{
            return
        }
        moveToRideDetailView(index: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    private func moveToRideDetailView(index: Int){
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride!, matchedUserList: inActiveMatchedUser, viewType: DetailViewType.RideDetailView, selectedIndex: index, startAndEndChangeRequired: false, selectedUserDelegate: nil)
        self.parentViewController?.navigationController?.pushViewController(mainContentVC, animated: false)
    }
}
extension InActiveMatchesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.size.width - 15
        if inActiveMatchedUser.count > 1{
            width = collectionView.frame.size.width - 40
        }
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
}
