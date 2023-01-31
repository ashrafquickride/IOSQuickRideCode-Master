//
//  RelayRidesCreationViewController.swift
//  Quickride
//
//  Created by Vinutha on 18/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class RelayRidesCreationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var progressAnimationView: AnimationView!
    @IBOutlet weak var taskDoneImage: UIImageView!
    @IBOutlet weak var fromToView: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondInfoLabel: UILabel!
    @IBOutlet weak var secondFromToView: UIView!
    @IBOutlet weak var secondFromLabel: UILabel!
    @IBOutlet weak var secondToLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var separationView: UIView!
    @IBOutlet weak var rideCreationFailedView: UIView!
    
    private var relayRidesCreationViewModel = RelayRidesCreationViewModel()
    
    func initializeView(parentRide: Ride,relayRideMatch: RelayRideMatch){
        relayRidesCreationViewModel = RelayRidesCreationViewModel(parentRide: parentRide, relayRideMatch: relayRideMatch)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        showProgressView(currentStatus: RelayRidesCreationViewModel.CREATING_FIRST_RIDE)
        relayRidesCreationViewModel.createFirstRide(viewController: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        confirmNsNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func confirmNsNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(firstRideCreated(_:)), name: .firstRideCreated, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(firstRideCreationFailed(_:)), name: .firstRideCreationFailed, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(firstInviteSent(_:)), name: .firstInviteSent, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(firstInviteFailed(_:)), name: .firstInviteFailed, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(secondRideCreated(_:)), name: .secondRideCreated, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(secondRideCreationFailed(_:)), name: .secondRideCreationFailed, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(secondInviteSent(_:)), name: .secondInviteSent, object: relayRidesCreationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(secondInviteFailed(_:)), name: .secondInviteFailed, object: relayRidesCreationViewModel)
    }
    private func showProgressView(currentStatus: String){
        switch currentStatus{
        case RelayRidesCreationViewModel.CREATING_FIRST_RIDE:
            firstTitleLabel.text = Strings.creating_first_ride
            firstTitleLabel.textColor = .black
            startAnimation()
            firtRideCreation()
        case RelayRidesCreationViewModel.FIRST_RIDE_CREATED:
            firstTitleLabel.text = Strings.first_ride_created
            firstTitleLabel.textColor = UIColor(netHex: 0x00B557)
            stopAnimation()
            firtRideCreation()
        case RelayRidesCreationViewModel.FIRST_RIDE_CREATION_FAILED:
            firstTitleLabel.text = Strings.ride_creation_failed
            firstTitleLabel.textColor = UIColor(netHex: 0xE20000)
            stopAnimation()
            firstRideCreationFailed()
            taskDoneImage.image = UIImage(named: "Red_Exclamation_Dot")
        case RelayRidesCreationViewModel.SENDING_FIRST_INVITATION:
            firstTitleLabel.text = Strings.sending_first_invite
            firstTitleLabel.textColor = .black
            startAnimation()
            firstInvitation()
        case RelayRidesCreationViewModel.FIRST_INVITATION_SENT:
            firstTitleLabel.text = Strings.first_invite_sent
            firstTitleLabel.textColor = UIColor(netHex: 0x00B557)
            stopAnimation()
            firstInvitation()
        case RelayRidesCreationViewModel.CREATING_SECOND_RIDE:
            firstTitleLabel.text = Strings.creating_second_ride
            firstTitleLabel.textColor = .black
            startAnimation()
            secondRideCreation()
        case RelayRidesCreationViewModel.SECOND_RIDE_CREATED:
            firstTitleLabel.text = Strings.second_ride_created
            firstTitleLabel.textColor = UIColor(netHex: 0x00B557)
            stopAnimation()
            secondRideCreation()
        case RelayRidesCreationViewModel.SECOND_RIDE_CREATION_FAILED:
            firstTitleLabel.text = Strings.ride_creation_failed
            firstTitleLabel.textColor = UIColor(netHex: 0xE20000)
            stopAnimation()
            secondRideCreationFailed()
            taskDoneImage.image = UIImage(named: "Red_Exclamation_Dot")
        case RelayRidesCreationViewModel.SENDING_SECOND_INVITATION:
            firstTitleLabel.text = Strings.sending_second_invite
            firstTitleLabel.textColor = .black
            startAnimation()
            secondInvitation()
        case RelayRidesCreationViewModel.SECOND_INVITATION_SENT:
            firstTitleLabel.text = Strings.second_invite_sent
            firstTitleLabel.textColor = UIColor(netHex: 0x00B557)
            stopAnimation()
            secondInvitation()
        default: break
        }
    }
    
    private func startAnimation(){
        taskDoneImage.isHidden = true
        progressAnimationView.isHidden = false
        progressAnimationView.animation = Animation.named("loader")
        progressAnimationView.play()
        progressAnimationView.loopMode = .loop
    }
    
    private func stopAnimation(){
        progressAnimationView.isHidden = true
        progressAnimationView.stop()
        taskDoneImage.image = UIImage(named: "check")
        taskDoneImage.isHidden = false
    }
    
    private func firtRideCreation(){
        infoLabel.isHidden = true
        fromToView.isHidden = false
        rideCreationFailedView.isHidden = true
        fromLabel.text = relayRidesCreationViewModel.parentRide?.startAddress
        toLabel.text = relayRidesCreationViewModel.relayRideMatch?.firstLegMatch?.dropLocationAddress
        secondTitleLabel.text = Strings.send_first_request
        secondInfoLabel.isHidden = false
        secondInfoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.firstLegMatch?.name ?? "")])
        secondFromToView.isHidden = true
    }
    private func firstInvitation(){
        infoLabel.isHidden = false
        rideCreationFailedView.isHidden = true
        infoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.firstLegMatch?.name ?? "")])
        fromToView.isHidden = true
        secondTitleLabel.text = Strings.create_second_ride
        secondFromToView.isHidden = false
        secondInfoLabel.isHidden = true
        secondFromLabel.text = relayRidesCreationViewModel.relayRideMatch?.secondLegMatch?.pickupLocationAddress
        secondToLabel.text = relayRidesCreationViewModel.parentRide?.endAddress
    }
    
    private func secondRideCreation(){
        infoLabel.isHidden = true
        fromToView.isHidden = false
        rideCreationFailedView.isHidden = true
        fromLabel.text = relayRidesCreationViewModel.relayRideMatch?.secondLegMatch?.pickupLocationAddress
        toLabel.text = relayRidesCreationViewModel.parentRide?.endAddress
        secondTitleLabel.text = Strings.send_second_request
        secondInfoLabel.isHidden = false
        secondInfoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.secondLegMatch?.name ?? "")])
        secondFromToView.isHidden = true
    }
    
    private func secondInvitation(){
        infoLabel.isHidden = false
        rideCreationFailedView.isHidden = true
        infoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.secondLegMatch?.name ?? "")])
        fromToView.isHidden = true
        bottomView.isHidden = true
        separationView.isHidden = true
    }
    private func firstRideCreationFailed(){
        infoLabel.isHidden = true
        fromToView.isHidden = true
        rideCreationFailedView.isHidden = false
        secondTitleLabel.text = Strings.send_first_request
        secondInfoLabel.isHidden = false
        secondInfoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.firstLegMatch?.name ?? "")])
        secondFromToView.isHidden = true
    }
    private func secondRideCreationFailed(){
        infoLabel.isHidden = true
        fromToView.isHidden = true
        rideCreationFailedView.isHidden = false
        secondTitleLabel.text = Strings.send_second_request
        secondInfoLabel.isHidden = false
        secondInfoLabel.text = String(format: Strings.to_user, arguments: [(relayRidesCreationViewModel.relayRideMatch?.secondLegMatch?.name ?? "")])
        secondFromToView.isHidden = true
    }
    
    @objc func firstRideCreated(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.FIRST_RIDE_CREATED)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.relayRidesCreationViewModel.sendInvitationToFistRider(viewController: self)
            self.showProgressView(currentStatus: RelayRidesCreationViewModel.SENDING_FIRST_INVITATION)
        }
    }
    @objc func firstRideCreationFailed(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.FIRST_RIDE_CREATION_FAILED)
    }
    
    @objc func secondRideCreated(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.SECOND_RIDE_CREATED)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.relayRidesCreationViewModel.sendInvitationToSecondRider(viewController: self)
            self.showProgressView(currentStatus: RelayRidesCreationViewModel.SENDING_SECOND_INVITATION)
        }
    }
    
    @objc func secondRideCreationFailed(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.SECOND_RIDE_CREATION_FAILED)
    }
    
    @objc func firstInviteSent(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.FIRST_INVITATION_SENT)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.relayRidesCreationViewModel.createSecondRide(viewController: self)
            self.showProgressView(currentStatus: RelayRidesCreationViewModel.CREATING_SECOND_RIDE)
        }
    }
    
    @objc func firstInviteFailed(_ notification: Notification) {
        progressAnimationView.isHidden = true
        progressAnimationView.stop()
    }
    
    @objc func secondInviteSent(_ notification: Notification) {
        showProgressView(currentStatus: RelayRidesCreationViewModel.SECOND_INVITATION_SENT)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SharedPreferenceHelper.storeRelayRideStatusForCurrentRide(rideId: self.relayRidesCreationViewModel.parentRide?.rideId ?? 0, isSelectedRelayRide: true)
            self.showSuccessMessage()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @objc func secondInviteFailed(_ notification: Notification) {
        progressAnimationView.isHidden = true
        progressAnimationView.stop()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func showSuccessMessage(){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: Strings.realy_ride_sucess_msg, isFromLinkedWallet: true, handler: {
            self.naviagteToLiveRide()
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: animationAlertController)
    }
    
    private func naviagteToLiveRide(){
        AppDelegate.getAppDelegate().log.debug("moveToRideView()")
        guard let firstRide = relayRidesCreationViewModel.firstRide, let secondRide = relayRidesCreationViewModel.secondRide else { return }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: firstRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: secondRide,requiredToShowRelayRide: RelayRideMatch.SHOW_FIRST_RELAY_RIDE)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: false)
    }
    @IBAction func tryAgainTapped(_ sender: Any) {
        if relayRidesCreationViewModel.rideCreationFailed == RelayRidesCreationViewModel.FIRST_RIDE_CREATION_FAILED{
            relayRidesCreationViewModel.createFirstRide(viewController: self)
        }else if relayRidesCreationViewModel.rideCreationFailed == RelayRidesCreationViewModel.SECOND_RIDE_CREATION_FAILED{
            relayRidesCreationViewModel.createSecondRide(viewController: self)
        }
    }
    
    @IBAction func goBackTapped(_ sender: Any) {
        closeView()
    }
}
