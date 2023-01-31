//
//  SwitchRiderTableViewCell.swift
//  Quickride
//
//  Created by HK on 12/08/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SwitchRiderTableViewCell: UITableViewCell {

    @IBOutlet weak var switchRiderView: UIView!
    @IBOutlet weak var switchRiderCollectionView: UICollectionView!
    @IBOutlet weak var switchRiderCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var viewModel = EidtAndCancelCardViewModel()
    //MARK: Initializer
    func initializeData(ride: Ride) {
        self.viewModel = EidtAndCancelCardViewModel(currentUserRide: ride)
        handleSwitchRideView()
    }
    
    private func handleSwitchRideView() {
        switchRiderView.isHidden = false
        if !viewModel.outGoingRideInvites.isEmpty {
            switchRiderCollectionView.isHidden = false
            switchRiderCollectionViewHeightConstraint.constant = 94
            switchRiderCollectionView.register(UINib(nibName: "JoinedMembersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "JoinedMembersCollectionViewCell")
            switchRiderCollectionView.reloadData()
        } else {
            switchRiderCollectionView.isHidden = true
            switchRiderCollectionViewHeightConstraint.constant = 0
        }
    }
    
    private func setImageViewBasedOnInvitationStatus( imageView : UIImageView, status : String){
        AppDelegate.getAppDelegate().log.debug(status)
        var image : UIImage
        switch status {
        case RideInvitation.RIDE_INVITATION_STATUS_RECEIVED:
            image = UIImage(named:"delivered_icon")!
        case RideInvitation.RIDE_INVITATION_STATUS_NEW:
            image = UIImage(named:"sent_icon")!
        case RideInvitation.RIDE_INVITATION_STATUS_FAILED:
            image = UIImage(named:"error_icon")!
        case RideInvitation.RIDE_INVITATION_STATUS_READ:
            image = UIImage(named:"double_tick_green")!
        default:
            image = UIImage(named:"sent_icon")!
            break
        }
        imageView.image = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.tintColor = UIColor.black
    }
    
    //MARK: Actions
    @IBAction func switchRideTapped(_ sender: UIButton) {
       let viewController = parentViewController!
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.DATA_CONNECTION_NOT_AVAILABLE, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-180), title: nil, image: nil, completion: nil)
            return
        }

        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: viewModel.currentUserRide, isFromCanceRide: false, isFromRideCreation: false)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: sendInviteBaseViewController, animated: false)
    }
}
// MARK: - Collection view delegate and data source
extension SwitchRiderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return viewModel.outGoingRideInvites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JoinedMembersCollectionViewCell", for: indexPath) as! JoinedMembersCollectionViewCell
        var rideInvitation : RideInvitation?
        if viewModel.outGoingRideInvites.endIndex <= indexPath.row{
            return cell
        }
        rideInvitation = viewModel.outGoingRideInvites[indexPath.item]
        cell.userId = rideInvitation!.riderId
        cell.labelName.text = nil
        cell.imageViewProfilePic.image = nil
        if rideInvitation!.noOfSeats > 1{
            cell.labelNoOfSeats.isHidden = false
            cell.labelNoOfSeats.text = "+\(String(rideInvitation!.noOfSeats-1))"
        }else{
            cell.labelNoOfSeats.isHidden = true
        }
        UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation!.riderId, handler: { (userBasicInfo,responseError,error) in
            if userBasicInfo != nil{
                cell.invitationStatusIcon.isHidden = false
                ImageCache.getInstance().setImageToView(imageView: cell.imageViewProfilePic, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                cell.labelName.text = userBasicInfo?.name?.capitalizingFirstLetter()
                self.setImageViewBasedOnInvitationStatus(imageView: cell.invitationStatusIcon, status :rideInvitation!.invitationStatus!)
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel.outGoingRideInvites.count <= indexPath.item{
            return
        }
        let rideInvitation = viewModel.outGoingRideInvites[indexPath.item]
            QuickRideProgressSpinner.startSpinner()
            viewModel.getMatchedUserForOutGoingInvite(rideInvitation: rideInvitation) { (matchedUser, responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                guard let matchedUser = matchedUser else {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                    return
                }
                var matchedUserList = [MatchedUser]()
                matchedUserList.append(matchedUser)
                self.moveToRideDetailView(matchedUser: matchedUserList)
            }
        
    }
    func moveToRideDetailView(matchedUser: [MatchedUser]) {
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: viewModel.currentUserRide, matchedUserList: matchedUser, viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: nil)
        ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
}
