//
//  TaxipoolJoinedMembersTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 08/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxipoolJoinedMembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var joinedMembersCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }
    private var joinedMembers = [TaxiRidePassenger]()
    private var isFromLiveRide = false
    private var taxiRidePassengerBasicInfos = [TaxiRidePassengerBasicInfo]()
    
    func showJoinedMembers(joinedMembers: [TaxiRidePassenger]?,isFromLiveRide: Bool,taxiRidePassengerBasicInfos: [TaxiRidePassengerBasicInfo]?){
        self.joinedMembers = joinedMembers ?? [TaxiRidePassenger]()
        self.isFromLiveRide = isFromLiveRide
        self.taxiRidePassengerBasicInfos = taxiRidePassengerBasicInfos ?? [TaxiRidePassengerBasicInfo]()
    }
    
    private func registerCells(){
        joinedMembersCollectionView.register(UINib(nibName: "CoRidersTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell")
        joinedMembersCollectionView.reloadData()
    }
}
//UICollectionViewDataSource
extension TaxipoolJoinedMembersTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFromLiveRide{
            return taxiRidePassengerBasicInfos.count
        }else{
            return joinedMembers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoRidersTaxiPoolCollectionViewCell", for: indexPath) as! CoRidersTaxiPoolCollectionViewCell
        if isFromLiveRide{
            cell.initialiseCoRiderUserInfo(taxiRidePassengerBasicInfo: taxiRidePassengerBasicInfos[indexPath.row])
        }else{
            cell.statusView.isHidden = true
            cell.riderNameLabel.text = joinedMembers[indexPath.row].userName
            ImageCache.getInstance().setImageToView(imageView: cell.rideProfileImageView, imageUrl: joinedMembers[indexPath.row].imageURI, gender: joinedMembers[indexPath.row].gender ?? "",imageSize: ImageCache.DIMENTION_SMALL)
        }
        return cell
    }
}
extension TaxipoolJoinedMembersTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFromLiveRide{
            moveToProfile(taxiRidePassengerBasicInfo: taxiRidePassengerBasicInfos[indexPath.row])
        }
        collectionView.deselectItem(at: indexPath, animated: true)

    }
    private func moveToProfile(taxiRidePassengerBasicInfo: TaxiRidePassengerBasicInfo?){
        guard let taxiPassengerInfo = taxiRidePassengerBasicInfo else { return }
        let profileDisplayViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: taxiPassengerInfo.userId),isRiderProfile: UserRole.Passenger,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: 1, isSafeKeeper: true)
        self.parentViewController?.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
}
