//
//  RideCancellationAndUnJoinViewController.swift
//  Quickride
//
//  Created by Halesh on 26/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol RideCancelDelegate{
    func rideCancelled()
}
typealias rideCancellationCompletionHandler = () -> Void

class RideCancellationAndUnJoinViewController: ModelViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate{
    
    @IBOutlet weak var reasonsTableView: UITableView!
    
    @IBOutlet weak var cancleBtn: UIButton!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var reasonsTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideParticipantCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var rideParticipantCollectionView: UICollectionView!
    
    @IBOutlet weak var reasonTextField: UITextField!
    
    @IBOutlet weak var textFieldView: UIView!
    
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var joinedMeberLabel: UILabel!
    
    @IBOutlet weak var joinedMemberLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reasonTitleLabel: UILabel!
    
    @IBOutlet weak var sharedWithOppositeUserLabel: UILabel!
    
    @IBOutlet weak var sharedWithOppositeUserLabellHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var headingLabelHeightConstraint: NSLayoutConstraint!
    
    private var isKeyBoardVisible = false
    var rideCancellationAndUnJoinViewModel = RideCancellationAndUnJoinViewModel()
    
    func initializeDataBeforePresenting(rideParticipants : [RideParticipant]?,rideType: String?,isFromCancelRide: Bool,ride: Ride?,vehicelType: String?, rideUpdateListener: RideObjectUdpateListener?, completionHandler : rideCancellationCompletionHandler?){
        rideCancellationAndUnJoinViewModel.initailiseData(rideParticipants: rideParticipants, rideType: rideType, isFromCancelRide: isFromCancelRide, ride: ride, vehicelType: vehicelType, rideUpdateListener: rideUpdateListener, completionHandler: completionHandler)
    }
    
    func initializeDataForUnjoin(rideParticipants : [RideParticipant]?,rideType: String?,ride: Ride?,riderRideId : Double,unjoiningUserRideId : Double,unjoiningUserId : Double, unjoiningUserRideType : String?, completionHandler : rideCancellationCompletionHandler?){
        rideCancellationAndUnJoinViewModel.initialiseUnjoinData(rideParticipants: rideParticipants, rideType: rideType, ride: ride, riderRideId: riderRideId, unjoiningUserRideId: unjoiningUserRideId, unjoiningUserId: unjoiningUserId, unjoiningUserRideType: unjoiningUserRideType, completionHandler: completionHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        ViewCustomizationUtils.addCornerRadiusToView(view: cancleBtn, cornerRadius: 20)
        textFieldView.isHidden = true
        textFieldViewHeightConstraint.constant = 0
        reasonTextField.delegate = self
        rideCancellationAndUnJoinViewModel.filterRideParticipants()
        rideCancellationAndUnJoinViewModel.assignReasonsBasedOnRideStatus()
        rideCancellationAndUnJoinViewModel.checkCallAndChatOptionAvailable()
        changeTextDependingOnRide()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCancellationAndUnJoinViewController.backGroundViewTapped(_:))))
        reasonsTableViewHeightConstraint.constant = CGFloat(rideCancellationAndUnJoinViewModel.reasons.count*38)
        NotificationCenter.default.addObserver(self, selector: #selector(RideCancellationAndUnJoinViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RideCancellationAndUnJoinViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        cancleBtn.isUserInteractionEnabled = false
        if rideCancellationAndUnJoinViewModel.rideParticipants?.isEmpty == false{
            if rideCancellationAndUnJoinViewModel.rideType == Ride.RIDER_RIDE{
                joinedMeberLabel.isHidden = false
                joinedMemberLabelHeightConstraint.constant = 20
            }else{
                joinedMeberLabel.isHidden = true
                joinedMemberLabelHeightConstraint.constant = 0
            }
            rideParticipantCollectionView.isHidden = false
            rideParticipantCollectionViewHeightConstraint.constant = 90
            rideParticipantCollectionView.delegate = self
            rideParticipantCollectionView.dataSource = self
            rideParticipantCollectionView.reloadData()
            headingLabel.isHidden = false
            headingLabelHeightConstraint.constant = 20
        }else{
            rideParticipantCollectionView.isHidden = true
            rideParticipantCollectionViewHeightConstraint.constant = 0
            joinedMeberLabel.isHidden = true
            joinedMemberLabelHeightConstraint.constant = 0
            headingLabel.isHidden = true
            headingLabelHeightConstraint.constant = 0
        }
        if rideCancellationAndUnJoinViewModel.rideType == Ride.RIDER_RIDE{
            sharedWithOppositeUserLabel.text = String(format: Strings.reason_shared_with_other, arguments: ["ride takers"])
        }else{
            sharedWithOppositeUserLabel.text = String(format: Strings.reason_shared_with_other, arguments: ["ride giver"])
        }
        
        if let rideParticipants = rideCancellationAndUnJoinViewModel.rideParticipants, !rideParticipants.isEmpty {
            sharedWithOppositeUserLabellHeightConstraint.constant = 18
        }else{
            sharedWithOppositeUserLabellHeightConstraint.constant = 0
        }
    }
    
    func changeTextDependingOnRide(){
        
        if rideCancellationAndUnJoinViewModel.isFromCancelRide{
            cancleBtn.setTitle(Strings.cancel_ride.uppercased(), for: .normal)
            reasonTitleLabel.text = Strings.cancellation_reason
            headingLabel.text = Strings.do_you_want_to_cancel_ride
        }else{
            cancleBtn.setTitle(Strings.unjoin_ride, for: .normal)
            reasonTitleLabel.text = Strings.unjoin_reason
            headingLabel.text = Strings.do_you_want_to_unjoin_from_this_ride
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideCancellationAndUnJoinViewModel.reasons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CancelReasonTableViewCell", for: indexPath as IndexPath) as! CancelReasonTableViewCell
        if rideCancellationAndUnJoinViewModel.reasons.endIndex <= indexPath.row{
            return cell
        }
        cell.delegate = self
        cell.initializeCell(selectedIndex: rideCancellationAndUnJoinViewModel.selectedIndex,index: indexPath.row, reasonText: rideCancellationAndUnJoinViewModel.reasons[indexPath.row], isCallOptionAvailable: rideCancellationAndUnJoinViewModel.isCallOptionEnable,isChatOPtionAvailable: rideCancellationAndUnJoinViewModel.isChatOptionEnable)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) as? CancelReasonTableViewCell{
            selectedCell.radioImage.image = UIImage(named: "ic_radio_button_checked")
            showAlternateActionForSelectedReason(index: indexPath.row, cell: selectedCell)
        }
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(item: rideCancellationAndUnJoinViewModel.selectedIndex, section: 0))as? CancelReasonTableViewCell{
            if rideCancellationAndUnJoinViewModel.selectedIndex != indexPath.row{
                prevSelectedCell.radioImage.image = UIImage(named: "radio_button_1")
                prevSelectedCell.alternateActionButton.isHidden =  true
                prevSelectedCell.callChatView.isHidden =  true
            }
        }
        rideCancellationAndUnJoinViewModel.selectedIndex = indexPath.row
        if indexPath.row == rideCancellationAndUnJoinViewModel.reasons.count - 1{
            textFieldView.isHidden = false
            textFieldViewHeightConstraint.constant = 50
            cancleBtn.backgroundColor = UIColor(netHex: 0xD3D3D3)
            cancleBtn.isUserInteractionEnabled = false
        }else{
            textFieldView.isHidden = true
            textFieldViewHeightConstraint.constant = 0
            reasonTextField.text = ""
            reasonTextField.placeholder = Strings.type_your_message
            self.view.endEditing(false)
            cancleBtn.backgroundColor = UIColor(netHex: 0x00b557)
            cancleBtn.isUserInteractionEnabled = true
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    private func showAlternateActionForSelectedReason(index: Int, cell: CancelReasonTableViewCell){
        if rideCancellationAndUnJoinViewModel.ride?.rideType == Ride.RIDER_RIDE && rideCancellationAndUnJoinViewModel.ride?.status == Ride.RIDE_STATUS_STARTED{
            return
        }
        switch rideCancellationAndUnJoinViewModel.reasons[index] {
        case Strings.im_going_late, Strings.im_going_early:
            cell.alternateActionButton.isHidden = false
            cell.callChatView.isHidden = true
            cell.alternateActionButton.setTitle(Strings.reschedule, for: .normal)
            cell.alternateActionButtonWidthConstraint.constant = 90
        case Strings.sorry_My_plan_changed:
            cell.alternateActionButton.isHidden = false
            cell.callChatView.isHidden = true
            cell.alternateActionButton.setTitle(Strings.edit_ride, for: .normal)
            cell.alternateActionButtonWidthConstraint.constant = 70
        case Strings.passenger_asked_to_cancel:
            cell.alternateActionButton.isHidden = false
            cell.callChatView.isHidden = true
            cell.alternateActionButton.setTitle(Strings.invite_other_ride_takers, for: .normal)
            cell.alternateActionButtonWidthConstraint.constant = 172
        case Strings.ride_taker_not_reachable,Strings.passenger_not_pickup_point,Strings.ride_giver_not_reachable:
            cell.alternateActionButton.isHidden = true
            cell.callChatView.isHidden = false
            cell.alternateActionButtonWidthConstraint.constant = 75
        case Strings.ride_giver_getting_late:
            if rideCancellationAndUnJoinViewModel.isFromCancelRide{
                cell.alternateActionButton.isHidden = false
                cell.callChatView.isHidden = true
                cell.alternateActionButton.setTitle(Strings.switch_rider, for: .normal)
                cell.alternateActionButtonWidthConstraint.constant = 100
            }else{
                cell.alternateActionButton.isHidden = true
                cell.callChatView.isHidden = false
                cell.alternateActionButtonWidthConstraint.constant = 75
            }
        case Strings.rider_crossed_pick_up_point,Strings.ride_over_crowded_now,Strings.ride_giver_changed_plan:
            cell.alternateActionButton.isHidden = false
            cell.callChatView.isHidden = true
            cell.alternateActionButton.setTitle(Strings.switch_rider, for: .normal)
            cell.alternateActionButtonWidthConstraint.constant = 100
        case Strings.cancelling_as_bike_ride:
            cell.alternateActionButton.isHidden = false
            cell.callChatView.isHidden = true
            cell.alternateActionButton.setTitle(Strings.switch_to_car_ride, for: .normal)
            cell.alternateActionButtonWidthConstraint.constant = 130
        default:
            cell.alternateActionButtonWidthConstraint.constant = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rideCancellationAndUnJoinViewModel.rideParticipants?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! RideParticipantsCollectionViewCell
        let rideParticipant = rideCancellationAndUnJoinViewModel.rideParticipants?[indexPath.item]
        cell.participantNameLbl.text = rideParticipant?.name
        ImageCache.getInstance().setImageToView(imageView: cell.participantImageView, imageUrl: rideParticipant?.imageURI, gender: rideParticipant!.gender!,imageSize: ImageCache.DIMENTION_TINY)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 20)/3, height: collectionView.bounds.height)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount > 18{
            cancleBtn.backgroundColor = UIColor(netHex: 0x00b557)
            cancleBtn.isUserInteractionEnabled = true
        }else{
            cancleBtn.backgroundColor = UIColor(netHex: 0xD3D3D3)
            cancleBtn.isUserInteractionEnabled = false
        }
        let newLength = currentCharacterCount + string.count - range.length
        if newLength > 250{
            return false
        }
        return true
    }
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 35
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 35
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    @IBAction func cancelRideTapped(_ sender: Any){
        self.view.endEditing(false)
        if rideCancellationAndUnJoinViewModel.selectedIndex == -1 || (rideCancellationAndUnJoinViewModel.selectedIndex == rideCancellationAndUnJoinViewModel.reasons.count - 1 && reasonTextField.text?.isEmpty == true){
            return
        }
        var reason = ""
        if rideCancellationAndUnJoinViewModel.selectedIndex == rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = reasonTextField.text ?? ""
        }else if rideCancellationAndUnJoinViewModel.selectedIndex >= 0 && rideCancellationAndUnJoinViewModel.selectedIndex != rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = rideCancellationAndUnJoinViewModel.reasons[rideCancellationAndUnJoinViewModel.selectedIndex]
        }
        if rideCancellationAndUnJoinViewModel.rideParticipants?.isEmpty == true{
            rideCancellationAndUnJoinViewModel.cancelRide(cancelReason: reason, viewController: self, delegate: self)
        }else{
            guard let ride = rideCancellationAndUnJoinViewModel.ride else { return }
            if rideCancellationAndUnJoinViewModel.isFromCancelRide{
                rideCancellationAndUnJoinViewModel.getRideCancelEstimation(ride: ride, cancelReason: reason, uiViewController: self, delegate: self)
            }else{
                rideCancellationAndUnJoinViewModel.getRideUnjoinEstimation(unjoinReason: reason, viewController: self, delegate: self)
            }
        }
    }
    
    private func closeView(){
        if isKeyBoardVisible {
            self.view.removeFromSuperview()
            self.removeFromParent()
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
                guard let self = `self` else {return}
                self.contentView.center.y += self.contentView.bounds.height
                self.contentView.layoutIfNeeded()
            }) { (value) in
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        }
    }
    
    private func showWaviedOffPopUp(){
        let cancellationFeeWaivedOffViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CancellationFeeWaivedOffViewController") as! CancellationFeeWaivedOffViewController
        ViewControllerUtils.addSubView(viewControllerToDisplay: cancellationFeeWaivedOffViewController)
    }
}
//MARK: CancelReasonTableViewCellDelegate
extension RideCancellationAndUnJoinViewController:CancelReasonTableViewCellDelegate{
    func alternateActinTapped(action: String?) {
        guard let rideObj = rideCancellationAndUnJoinViewModel.ride else { return }
        switch action {
        case Strings.reschedule:
            RescheduleRide(ride: rideObj, viewController: self,moveToRideView: false).rescheduleRide()
        case Strings.edit_ride:
            let editRideViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideUpdateViewController") as! RideUpdateViewController
            editRideViewController.initializeDataBeforePresentingView(ride: rideObj,riderRide: nil,listener : rideCancellationAndUnJoinViewModel.rideUpdateListener)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: editRideViewController, animated: false)
        case Strings.invite_other_ride_takers,Strings.switch_rider,Strings.switch_to_car_ride:
            var isCarFilterRequired = false
            if action == Strings.switch_to_car_ride{
                isCarFilterRequired = true
            }
            guard let rideObj = rideCancellationAndUnJoinViewModel.ride else { return }
            let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
            sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: rideObj, isFromCanceRide: isCarFilterRequired, isFromRideCreation: false)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: sendInviteBaseViewController, animated: false)
        default: break
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func callButtonTapped() {
        if let callDisableMsg = rideCancellationAndUnJoinViewModel.getCallErrorMessage(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
        let rideParticipant = rideCancellationAndUnJoinViewModel.getOppositeUser()
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant?.userId), refId: Strings.profile,  name: rideParticipant?.name ?? "", targetViewController: self)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func chatButtonTapped() {
        if let chatDisableMsg = rideCancellationAndUnJoinViewModel.getChatErrorMessage(){
            UIApplication.shared.keyWindow?.makeToast( chatDisableMsg )
            return
        }
        let rideParticipant = rideCancellationAndUnJoinViewModel.getOppositeUser()
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(ride: rideCancellationAndUnJoinViewModel.ride, userId: rideParticipant?.userId ?? 0, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: viewController, animated: false)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
//MARK: RideCancelEstimationDelegate
extension RideCancellationAndUnJoinViewController: RideCancelEstimationDelegate{
    func handleSuccessResponse(){
        var reason = ""
        if rideCancellationAndUnJoinViewModel.selectedIndex == rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = reasonTextField.text ?? ""
        }else if rideCancellationAndUnJoinViewModel.selectedIndex >= 0 && rideCancellationAndUnJoinViewModel.selectedIndex != rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = rideCancellationAndUnJoinViewModel.reasons[rideCancellationAndUnJoinViewModel.selectedIndex]
        }
        if rideCancellationAndUnJoinViewModel.compensations.isEmpty{
            rideCancellationAndUnJoinViewModel.cancelRide(cancelReason: reason, viewController: self, delegate: self)
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
            let rideCancellationFeeViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationFeeViewController") as! RideCancellationFeeViewController
            rideCancellationFeeViewController.initializeCancelRideVIew(ride: rideCancellationAndUnJoinViewModel.ride, rideType: rideCancellationAndUnJoinViewModel.rideType ?? "", isFromCancelRide: rideCancellationAndUnJoinViewModel.isFromCancelRide, compensation: rideCancellationAndUnJoinViewModel.compensations, reason: reason,riderRideId: rideCancellationAndUnJoinViewModel.riderRideId,unjoiningUserRideId:  rideCancellationAndUnJoinViewModel.unjoiningUserRideId,unjoiningUserId: rideCancellationAndUnJoinViewModel.unjoiningUserId, unjoiningUserRideType: rideCancellationAndUnJoinViewModel.unjoiningUserRideType,completionHandler: {
                if self.rideCancellationAndUnJoinViewModel.isWaveOffCompensationAvailable{
                    self.showWaviedOffPopUp()
                }
                self.rideCancellationAndUnJoinViewModel.rideCancellationCompletionHandler?()
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationFeeViewController)
        }
    }
}
//MARK: RideUnjoinEstimationDelegate
extension RideCancellationAndUnJoinViewController: RideUnjoinEstimationDelegate{
    func unJoinEstimation(){
        var reason = ""
        if rideCancellationAndUnJoinViewModel.selectedIndex == rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = reasonTextField.text ?? ""
        }else if rideCancellationAndUnJoinViewModel.selectedIndex >= 0 && rideCancellationAndUnJoinViewModel.selectedIndex != rideCancellationAndUnJoinViewModel.reasons.count - 1{
            reason = rideCancellationAndUnJoinViewModel.reasons[rideCancellationAndUnJoinViewModel.selectedIndex]
        }
        
        if rideCancellationAndUnJoinViewModel.compensations.isEmpty == true || (!rideCancellationAndUnJoinViewModel.compensations.isEmpty && rideCancellationAndUnJoinViewModel.compensations[0].isSystemWaveOff == true){
            rideCancellationAndUnJoinViewModel.unJoinRide(unjoinReason: reason, viewController: self, delegate: self)
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
            let rideCancellationFeeViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationFeeViewController") as! RideCancellationFeeViewController
            rideCancellationFeeViewController.initializeCancelRideVIew(ride: rideCancellationAndUnJoinViewModel.ride, rideType: rideCancellationAndUnJoinViewModel.rideType ?? "", isFromCancelRide: rideCancellationAndUnJoinViewModel.isFromCancelRide, compensation: rideCancellationAndUnJoinViewModel.compensations, reason: reason,riderRideId: rideCancellationAndUnJoinViewModel.riderRideId,unjoiningUserRideId:  rideCancellationAndUnJoinViewModel.unjoiningUserRideId,unjoiningUserId: rideCancellationAndUnJoinViewModel.unjoiningUserId, unjoiningUserRideType: rideCancellationAndUnJoinViewModel.unjoiningUserRideType, completionHandler: {
                self.rideCancellationAndUnJoinViewModel.rideCancellationCompletionHandler?()
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationFeeViewController)
        }
    }
}
//MARK: RideCancelledOrUnjoinedDelegate
extension RideCancellationAndUnJoinViewController: RideCancelledOrUnjoinedDelegate{
    func showWaviedOffScreen() {
        showWaviedOffPopUp()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func rideCancelledBefeoreJoiningOrFeeNotApplied(){
        rideCancellationAndUnJoinViewModel.rideCancellationCompletionHandler?()
        closeView()
    }
}

