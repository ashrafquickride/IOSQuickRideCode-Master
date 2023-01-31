//
//  RideDetailedViewController.swift
//  Quickride
//
//  Created by Vinutha on 11/03/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import ObjectMapper
import FloatingPanel

enum DetailViewType {
    case RideInviteView // Ride invitation High alert
    case RideConfirmView // Ride confirm high alert For Passenger
    case RideDetailView // Normal Ride detail
    case MatchedUserView // ReadyToGo matches in matching option screen
    case PaymentPendingView // Showing ride payment pending showing 
}

@objc protocol SelectedUserDelegate  {
    @objc optional func selectedUser(selectedUser : MatchedUser)
    @objc optional func saveRide(ride: Ride)
    @objc optional func notSelected()
    @objc optional func rejectUser(selectedUser : MatchedUser)
}

protocol MatchedUserDataChangeDelagate: class {
    func selectedIndexChanged(selectedIndex: Int)
    func displayAckForRideRequest(matchedUser: MatchedUser)
    func pickupDropChangedForJoinMyRide(matchedUser: MatchedUser)
}

class RideDetailedViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var userDetailTableView: UITableView!
    
    //MARK: Properties
    var matchedUserDataChangeDelagate: MatchedUserDataChangeDelagate?
    var backGroundView: UIView?
    private var rideDetailMapViewModel = RideDetailMapViewModel()
    private var drawerState = FloatingPanelPosition.half
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userDetailTableView.register(UINib(nibName: "MatchedUserReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchedUserReviewTableViewCell")
        userDetailTableView.register(UINib(nibName: "MatchedUserDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchedUserDetailTableViewCell")
        userDetailTableView.estimatedRowHeight = 240
        userDetailTableView.rowHeight = UITableView.automaticDimension
        checkAndDisplayMatchedPassengers()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        userDetailTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: Methods
    func initializeData(ride: Ride, matchedUserList: [MatchedUser], viewType: DetailViewType, selectedIndex: Int, startAndEndChangeRequired: Bool, selectedUserDelegate: SelectedUserDelegate?, matchedUserDataChangeDelagate: MatchedUserDataChangeDelagate?) {
        
        rideDetailMapViewModel.initializeData(ride: ride, matchedUserList: matchedUserList,  routePathReceiveDelagate: nil, rideParticipantLocationReceiveDelagate: nil, viewType: viewType, selectedIndex: selectedIndex, startAndEndChangeRequired: startAndEndChangeRequired, selectedUserDelegate: selectedUserDelegate, matchedPassengerReciever: self)
        self.matchedUserDataChangeDelagate = matchedUserDataChangeDelagate
    }
    
    func checkAndDisplayMatchedPassengers(){
        
        if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == MatchedUser.RIDER{
            let matchedRider = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider
            if matchedRider.capacity ?? 0 - (matchedRider.availableSeats ?? 0) <= 0{
                return
            }
            if matchedRider.joinedPassengers == nil && rideDetailMapViewModel.selectedIndex >= 0 && rideDetailMapViewModel.selectedIndex <= rideDetailMapViewModel.matchedUserList.count - 1 {
                RideServicesClient.getAlreadyJoinedPassengersOfRide(riderRideId: matchedRider.rideid!,  userId: QRSessionManager.getInstance()?.getUserId(), pickupLat: matchedRider.pickupLocationLatitude, pickupLng: matchedRider.pickupLocationLongitude, dropLat: matchedRider.dropLocationLatitude, dropLng: matchedRider.dropLocationLongitude, viewController: self, handler: { (responseObject, error) in
                    if responseObject != nil && responseObject![HttpUtils.RESULT] as! String == HttpUtils.RESPONSE_SUCCESS {
                        (self.rideDetailMapViewModel.matchedUserList[self.rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers = Mapper<UserBasicInfo>().mapArray(JSONObject: responseObject![HttpUtils.RESULT_DATA])
                        if (self.rideDetailMapViewModel.matchedUserList[self.rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers?.isEmpty == false {
                            self.userDetailTableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    private func popViewControllerWithAnimation() {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window?.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    private func addRideActionButtons(){
        if let rideDetailedMapViewController = self.parent?.parent as? RideDetailedMapViewController {
            rideDetailedMapViewController.showRideActionButtonsView()
        }
    }
}
//MARK: RideInviteAction Protocal
extension RideDetailedViewController: RideInvitationActionCompletionListener {
    func rideInviteAcceptCompleted(rideInvitationId: Double) {
        QuickRideProgressSpinner.startSpinner()
        RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitationId) { invite, responseError, error in
            QuickRideProgressSpinner.stopSpinner()
            if let invite = invite {
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: RideInviteStatus(rideInvitation: invite))
                NotificationCenter.default.post(name: .updateUiWithNewData, object: nil)
            }
        }
        popViewControllerWithAnimation()
    }
    
    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        popViewControllerWithAnimation()
    }
    
    func rideInviteActionFailed(rideInvitationId : Double, responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {
        if responseError != nil {
            if responseError!.errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE{
                removeInvitationAndRefreshData(rideInvitationId: rideInvitationId, status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
            } else if responseError!.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE || responseError!.errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR {
                removeInvitationAndRefreshData(rideInvitationId: rideInvitationId, status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED)
            } else if responseError!.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError!.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR || responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR {
                removeInvitationAndRefreshData(rideInvitationId: rideInvitationId, status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED)
            }
        }
        userDetailTableView.reloadData()
    }
    
    private func removeInvitationAndRefreshData(rideInvitationId: Double, status : String) {
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationId)
    }
    
    func rideInviteActionCancelled() {
        popViewControllerWithAnimation()
    }
    
    private func moveToNextAfterAcionCompletes() {
        if rideDetailMapViewModel.matchedUserList.count == 1 {
            rideDetailMapViewModel.selectedIndex = 0
        }
        rideDetailMapViewModel.matchedUserList.remove(at: rideDetailMapViewModel.selectedIndex)
        if rideDetailMapViewModel.matchedUserList.count == 0 {
            popViewControllerWithAnimation()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.userDetailTableView.reloadData()
                self.matchedUserDataChangeDelagate?.selectedIndexChanged(selectedIndex: self.rideDetailMapViewModel.selectedIndex)
            })
        }
    }
}
//MARK: TableView Delegate
extension RideDetailedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
//            if rideDetailMapViewModel.matchedUserList.count > rideDetailMapViewModel.selectedIndex , rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].rating ?? 0 > 0 {
//                return 1
//            }
            return 0 // disabled rating, ontime and required seats showing cell 
        case 2:
            if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == Ride.RIDER_RIDE, (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers?.isEmpty == false {
                return 1
            } else {
                return 0
            }
        case 3:
            if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == Ride.RIDER_RIDE, let matchedRider = rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as? MatchedRider, let _ = matchedRider.vehicleNumber {
                return 1
            }else {
                return 0
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchedUsers = rideDetailMapViewModel.matchedUserList
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MatchedUserDetailTableViewCell", for: indexPath) as! MatchedUserDetailTableViewCell
            if matchedUsers.endIndex <= indexPath.row {
                return cell
            }
            cell.initialiseUIWithData(ride: rideDetailMapViewModel.ride, matchedUser: matchedUsers[rideDetailMapViewModel.selectedIndex], viewController: self, viewType: rideDetailMapViewModel.viewType!, selectedIndex: rideDetailMapViewModel.selectedIndex, drawerState: drawerState, routeMetrics: nil, rideInviteActionCompletionListener: self, userSelectionDelegate: self, selectedUserDelegate: rideDetailMapViewModel.selectedUserDelegate)
            checkAndAddRideDetailViewSwipeGesture(cell: cell)
            addRideActionButtons()
            return cell
        case 1:
            let matchedUserReviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MatchedUserReviewTableViewCell") as! MatchedUserReviewTableViewCell
            var userOnTimeComplianceRating: String?
            var requiredSeats: Int?
            if rideDetailMapViewModel.ride?.rideType == Ride.PASSENGER_RIDE {
                userOnTimeComplianceRating = matchedUsers[rideDetailMapViewModel.selectedIndex].userOnTimeComplianceRating
            }else {
                requiredSeats = (matchedUsers[rideDetailMapViewModel.selectedIndex] as? MatchedPassenger)?.requiredSeats
            }
            matchedUserReviewTableViewCell.initialiseData(rating: matchedUsers[rideDetailMapViewModel.selectedIndex].rating ?? 0, noOfReviews: matchedUsers[rideDetailMapViewModel.selectedIndex].noOfReviews, userOnTimeComplianceRating: userOnTimeComplianceRating, requiredSeats: requiredSeats)
            return matchedUserReviewTableViewCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoRidersTableViewCell", for: indexPath) as! CoRidersTableViewCell
            if matchedUsers.endIndex <= indexPath.row {
                return cell
            }
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleDetailTableViewCell", for: indexPath) as! VehicleDetailTableViewCell
            if matchedUsers.endIndex <= indexPath.row {
                return cell
            }
            cell.initializeData(matchedUser: matchedUsers[rideDetailMapViewModel.selectedIndex])
            return cell
        default:
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if tableView.numberOfRows(inSection: 1) > 0 || tableView.numberOfRows(inSection: 2) > 0 || tableView.numberOfRows(inSection: 3) > 0 {
                return 10
            }
            return 0
        case 1:
//            if rideDetailMapViewModel.matchedUserList.count > rideDetailMapViewModel.selectedIndex && (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].rating ?? 0 > 0) && ((tableView.numberOfRows(inSection: 2) > 0) || (tableView.numberOfRows(inSection: 3) > 0)){
//                return 10
//            }
            return 0
        case 2:
            if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == Ride.RIDER_RIDE, (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers?.isEmpty == false, (tableView.numberOfRows(inSection: 3) > 0) {
                return 10
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return footerCell
    }
}
extension RideDetailedViewController {
    
    func floatingLabelPositionChanged(position: FloatingPanelPosition) {
        if position == .full {
            self.drawerState = position
            self.userDetailTableView.isScrollEnabled = true
        }else{
            self.drawerState = position
            self.userDetailTableView.isScrollEnabled = false
        }
        self.userDetailTableView.reloadData()
    }
    
    func checkAndAddRideDetailViewSwipeGesture(cell: MatchedUserDetailTableViewCell) {
        if drawerState == .full {
            cell.leftView.isHidden = true
            cell.rightView.isHidden = true
            cell.backGroundView.isUserInteractionEnabled = true
            cell.backGroundView.gestureRecognizers?.removeAll()
        } else {
            if rideDetailMapViewModel.matchedUserList.count > 1 && drawerState != .full {
                cell.backGroundView.isUserInteractionEnabled = true
                backGroundView = cell.backGroundView
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                leftSwipe.direction = .left
                backGroundView!.addGestureRecognizer(leftSwipe)
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                rightSwipe.direction = .right
                backGroundView!.addGestureRecognizer(rightSwipe)
            }else{
                cell.leftView.isHidden = true
                cell.rightView.isHidden = true
            }
            if rideDetailMapViewModel.selectedIndex == 0{
                cell.leftView.isHidden = true
                
            }else{
                cell.leftView.isHidden = false
            }
            if rideDetailMapViewModel.selectedIndex == rideDetailMapViewModel.matchedUserList.count - 1 {
                cell.rightView.isHidden = true
            }else{
                cell.rightView.isHidden = false
            }
        }
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            
            if rideDetailMapViewModel.selectedIndex != rideDetailMapViewModel.matchedUserList.count - 1{
                backGroundView!.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
        }else if gesture.direction == .right {
            
            if rideDetailMapViewModel.selectedIndex != 0 {
                backGroundView!.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
        }
        if gesture.direction == .left {
            rideDetailMapViewModel.selectedIndex += 1
            if rideDetailMapViewModel.selectedIndex > rideDetailMapViewModel.matchedUserList.count - 1 {
                rideDetailMapViewModel.selectedIndex = rideDetailMapViewModel.matchedUserList.count - 1
            }
        }else if gesture.direction == .right {
            rideDetailMapViewModel.selectedIndex -= 1
            if rideDetailMapViewModel.selectedIndex < 0 {
                rideDetailMapViewModel.selectedIndex = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.userDetailTableView.reloadData()
            self.matchedUserDataChangeDelagate?.selectedIndexChanged(selectedIndex: self.rideDetailMapViewModel.selectedIndex)
        })
        
    }
}

//MARK: CollectionView Delegate
extension RideDetailedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! RiderAndPassengerCollectionViewCell
        let userBasicInfo = (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers![indexPath.row]
        
        cell.lblName.text = userBasicInfo.name!
        if let userImageURI = userBasicInfo.imageURI, !userImageURI.isEmpty  {
            ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_TINY, handler:  {(image, imageURI) in
                if let image = image , imageURI == userImageURI{
                    
                    ImageCache.getInstance().checkAndSetCircularImage(imageView: cell.imgProfilePic, image: image)
                }else{
                    ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_TINY, handler : {(image, imageURI) in
                        if let image = image , imageURI == userImageURI {
                             
                            ImageCache.getInstance().checkAndSetCircularImage(imageView: cell.imgProfilePic, image: image)
                        }else{
                            cell.imgProfilePic.image = ImageCache.getInstance().getDefaultUserImage(gender: userBasicInfo.gender ?? "U")
                        }
                    })
                }
            })
        }else {
            cell.imgProfilePic.image = ImageCache.getInstance().getDefaultUserImage(gender: userBasicInfo.gender ?? "U")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == MatchedUser.RIDER && (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers != nil{
            return (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userBasicInfo = (rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex] as! MatchedRider).joinedPassengers![indexPath.row]
        let userRole: UserRole?
        if rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex].userRole == MatchedUser.RIDER{
            userRole = UserRole.Rider
        }
        else{
            userRole = UserRole.Passenger
        }
        let vc  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: userBasicInfo.userId),isRiderProfile: userRole!,rideVehicle: nil,userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

//MARK: RideDetailTableViewCell Delegate
extension RideDetailedViewController: RideDetailTableViewCellUserSelectionDelegate {
    
    func declineInviteAction(rideInvitation: RideInvitation?) {
        if let rideInvitation = rideInvitation {
            var rideType :  String?
            if rideInvitation.rideType == Ride.RIDER_RIDE
            {
                rideType = Ride.PASSENGER_RIDE
            }
            else if rideInvitation.rideType == TaxiPoolConstants.Taxi
            {
                rideType = Ride.RIDER_RIDE
            }
            else
            {
                rideType = Ride.RIDER_RIDE
            }
            let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
            rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: rideType) { (text, result) in
                
                if result == Strings.confirm_caps{
                    self.completeRejectAction(rejectReason: text, rideInvitation: rideInvitation)
                }
            }
        }
    }
    
    func completeRejectAction(rejectReason : String?, rideInvitation: RideInvitation){
        var isModerator = false
        if let rideUserId = rideDetailMapViewModel.ride?.userId, rideUserId != 0, let currentUserId = Double(QRSessionManager.getInstance()?.getUserId() ?? "0"), currentUserId != 0, rideUserId != currentUserId {
            isModerator = true
        }
        if Ride.RIDER_RIDE == rideDetailMapViewModel.ride?.rideType || isModerator {
            let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvitation, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            riderRejectPassengerInvitationTask.rejectPassengerInvitation()
        } else {
            let passengerRejectRiderInvitationTask = PassengerRejectRiderInvitationTask(rideInvitation: rideInvitation, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            passengerRejectRiderInvitationTask.rejectRiderInvitation()
        }
    }
    
    func gotItAction() {
        popViewControllerWithAnimation()
        moveToLiveRideView()
    }
    
    func changePlanAction() {
        if let ride = rideDetailMapViewModel.ride {
            
            let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
            rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(rideParticipants: nil, rideType: ride.rideType, isFromCancelRide: ( rideDetailMapViewModel.viewType == DetailViewType.PaymentPendingView) ? true : false , ride: ride, vehicelType: nil, rideUpdateListener: nil, completionHandler: {
                self.popViewControllerWithAnimation()
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
        }
    }
    
    private func moveToLiveRideView() {
        var isFreezeRideRequired = false
        if Ride.RIDER_RIDE == rideDetailMapViewModel.ride?.rideType {
            if let riderRide = (rideDetailMapViewModel.ride) as? RiderRide, riderRide.availableSeats == 0 {
                isFreezeRideRequired = true
            }
        }
        let centerViewController = ViewControllerUtils.getCenterViewController()
        var navigationController : UINavigationController?
        if centerViewController.navigationController != nil{
            navigationController = centerViewController.navigationController
        }else{
            navigationController = (centerViewController as? ContainerTabBarViewController)?.centerNavigationController
        }
        
        navigationController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.indexToSelect = 1
        
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: rideDetailMapViewModel.ride, isFromRideCreation: false, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: false, relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    func cancelSelectedUserPressed(invitation: RideInvitation, status: Int) {
        if status == 0 {
            QuickRideProgressSpinner.startSpinner()
            RideMatcherServiceClient.updateRideInvitationStatus(invitationId: invitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: self) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if error != nil {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    UIApplication.shared.keyWindow?.makeToast(Strings.invite_cancelled_toast, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                    invitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                    let rideInvitationStatus = RideInviteStatus(rideInvitation: invitation)
                    RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                    self.userDetailTableView.reloadData()
                    if let navigationController = self.parent?.navigationController {
                        navigationController.popViewController(animated: true)
                    }else {
                        self.parent?.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    func selectedUserDelegate() {
        ViewControllerUtils.finishViewController(viewController: self)
        if rideDetailMapViewModel.ride?.routePathPolyline != nil{
            rideDetailMapViewModel.selectedUserDelegate?.saveRide?(ride: rideDetailMapViewModel.ride!)
        }
        rideDetailMapViewModel.selectedUserDelegate?.selectedUser?(selectedUser: rideDetailMapViewModel.matchedUserList[rideDetailMapViewModel.selectedIndex])
        
        rideDetailMapViewModel.selectedUserDelegate = nil
    }
    
    func displayAckForRideRequest(matchedUser: MatchedUser) {
        matchedUserDataChangeDelagate?.displayAckForRideRequest(matchedUser: matchedUser)
    }
    
    func updateRideStatusView() {
        userDetailTableView.reloadData()
    }
}
extension RideDetailedViewController: PickUpAndDropSelectionDelegate {
    func pickUpAndDropChanged(matchedUser: MatchedUser, userPreferredPickupDrop: UserPreferredPickupDrop?) {
        matchedUserDataChangeDelagate?.pickupDropChangedForJoinMyRide(matchedUser: matchedUser)
    }
    
}
extension RideDetailedViewController: MatchedPassengerRecieverDelegate {
    func recievedMatchedUserSucceded() {
        userDetailTableView.reloadData()
        matchedUserDataChangeDelagate?.selectedIndexChanged(selectedIndex: rideDetailMapViewModel.selectedIndex)
    }
    
}
