//
//  RouteDeviationInfoViewController.swift
//  Quickride
//
//  Created by Vinutha on 15/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias routeDeviationActionCompletionHandler = (_ state: String, _ newRoute: RideRoute?) -> Void

class RouteDeviationInfoViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var userImageView: UIView!
    @IBOutlet weak var userImageView1: CircularImageView!
    @IBOutlet weak var userImageView2: CircularImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButtonView: QRCustomButton!
    @IBOutlet weak var positiveActionButton: QRCustomButton!
    @IBOutlet weak var postiveActionAnimationView: UIView!
    @IBOutlet weak var animationViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var negativeActionButton: QRCustomButton!
    @IBOutlet weak var gotItButton: QRCustomButton!
    
    //MARK: Properties
    private var routeDeviationConfirmTimer: Timer!
    private var inviteCancelConfirmTimer: Timer!
    private var routeDeviationInfoViewModel = RouteDeviationInfoViewModel()
    private var completionHandler: routeDeviationActionCompletionHandler?
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        setUpUI()
    }

    //MARK: Initializer
    func initialiseData(riderRide: RiderRide, rideParticipantLocation: RideParticipantLocation, completionHandler: routeDeviationActionCompletionHandler?) {
        self.completionHandler = completionHandler
        routeDeviationInfoViewModel.initialiseData(riderRide: riderRide, rideParticipantLocation: rideParticipantLocation)
    }
    //MARK: Methods
    private func setUpUI() {
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        userImageView1.isHidden = false
        let image = UIImage(named: "route_deviate_icon")?.withRenderingMode(.alwaysTemplate)
        userImageView1.image = image
        userImageView1.tintColor = UIColor(netHex:0x007AFF)
        userImageView2.isHidden = true
        addAnimationViewForRouteDeviationConfirmButton()
        
    }
    
    private func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.infoView.center.y -= self.infoView.bounds.height
            }, completion: nil)
    }
    
    @objc private func backGroundViewTapped(_ gesture : UITapGestureRecognizer) {
        removeView(state: RouteDeviationDetector.CANCELLED)
    }
    
    private func removeView(state: String) {
        stopTimer()
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.infoView.center.y += self.infoView.bounds.height
            self.infoView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.completionHandler?(state, self.routeDeviationInfoViewModel.newRoute)
        }
    }
    
    private func addAnimationViewForRouteDeviationConfirmButton() {
        routeDeviationConfirmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(routeDeviationTimerAction), userInfo: nil, repeats: true)
        
    }
    
    private func addAnimationForInviteCancelConfirmButton() {
        inviteCancelConfirmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(inviteCancelConfirmTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc func routeDeviationTimerAction() {
        if routeDeviationInfoViewModel.timeLeft != 0 {
            postiveActionAnimationView.isHidden = false
            routeDeviationInfoViewModel.timeLeft -= 1
            animationViewWidthConstraint.constant += positiveActionButton.bounds.size.width/10
        } else {
            stopTimer()
            routeDeviationInfoViewModel.timeLeft = 10
            handleViewBasedOnPendingPickupsOrInvite()
        }
    }
    
    @objc func inviteCancelConfirmTimerAction() {
        if routeDeviationInfoViewModel.timeLeft != 0 {
            postiveActionAnimationView.isHidden = false
            routeDeviationInfoViewModel.timeLeft -= 1
            animationViewWidthConstraint.constant += positiveActionButton.bounds.width/10
        } else {
            stopTimer()
            handleCancelInviteView()
        }
    }
    
    private func stopTimer() {
        postiveActionAnimationView.isHidden = true
        if routeDeviationConfirmTimer != nil {
            routeDeviationConfirmTimer.invalidate()
        }
        if inviteCancelConfirmTimer != nil {
            inviteCancelConfirmTimer.invalidate()
        }
    }
    
    private func handleViewBasedOnPendingPickupsOrInvite() {
        if let riderRide = routeDeviationInfoViewModel.riderRide, let rideParticipantLocation = routeDeviationInfoViewModel.rideParticipantLocation {
            var wayPoints = [Location]()
            wayPoints.append(Location(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!, shortAddress: nil))
            QuickRideProgressSpinner.startSpinner()
            MyRoutesCache.getInstance()?.getUserRoute(useCase: "iOS.App.RiderRide.CustomRoute.RouteDeviationHold", rideId: riderRide.rideId, startLatitude: riderRide.startLatitude, startLongitude: riderRide.startLongitude, endLatitude: riderRide.endLatitude!, endLongitude: riderRide.endLongitude!, wayPoints: wayPoints.toJSONString(), routeReceiver: self, saveCustomRoute: false)
        }
    }
    
    private func handlePickupView() {
        if !routeDeviationInfoViewModel.rideParticipants.isEmpty {
            actionButtonView.isHidden = true
            gotItButton.isHidden = false
            let rideParticipants = routeDeviationInfoViewModel.rideParticipants
            if rideParticipants.count == 1 {
                userImageView1.isHidden = false
                userImageView2.isHidden = true
                ImageCache.getInstance().setImageToView(imageView: userImageView1, imageUrl: rideParticipants[0].imageURI, gender: rideParticipants[0].gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                titleLabel.text = String(format: Strings.missing_pickup, arguments: [rideParticipants[0].name!])
                subTitleLabel.text = String(format: Strings.due_to_route_deviation_you_may_pickup, arguments: [rideParticipants[0].name!])
            } else if rideParticipants.count > 1 {
                userImageView1.isHidden = false
                userImageView2.isHidden = false
                ImageCache.getInstance().setImageToView(imageView: userImageView1, imageUrl: rideParticipants[0].imageURI, gender: rideParticipants[0].gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                ImageCache.getInstance().setImageToView(imageView: userImageView2, imageUrl: rideParticipants[1].imageURI, gender: rideParticipants[1].gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                titleLabel.text = String(format: Strings.missing_pickup, arguments: [rideParticipants[0].name! + "+\(rideParticipants.count - 1)"])
                subTitleLabel.text = String(format: Strings.due_to_route_deviation_you_may_pickup, arguments: [rideParticipants[0].name! + "+\(rideParticipants.count - 1)"])
            }
        }
    }
    
    private func handleRideInviteView() {
        if !routeDeviationInfoViewModel.rideInvites.isEmpty {
            let rideInvites = routeDeviationInfoViewModel.rideInvites
            titleLabel.text = Strings.route_deviation_found
            animationViewWidthConstraint.constant = 0
            addAnimationForInviteCancelConfirmButton()
            if rideInvites.count == 1 {
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[0].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    self.userImageView1.isHidden = false
                    self.userImageView2.isHidden = true
                    if userBasicInfo != nil {
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView1, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!])
                    } else {
                        self.subTitleLabel.text = "You may miss to add requested user to your ride if you confirm new route"
                    }
                })
            } else if rideInvites.count > 1 {
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[0].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    self.userImageView1.isHidden = false
                    if userBasicInfo != nil {
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView1, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                    } else {
                        self.subTitleLabel.text = "You may miss to add requested users to your ride if you confirm new route"
                    }
                })
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[1].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    if userBasicInfo != nil {
                        self.userImageView2.isHidden = false
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView2, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                    } else {
                        self.userImageView2.isHidden = true
                        self.subTitleLabel.text = "You may miss to add requested users to your ride if you confirm new route"
                    }
                })
            }
        }
    }
    
    private func handleCancelInviteView() {
        if !routeDeviationInfoViewModel.rideInvites.isEmpty {
            positiveActionButton.setTitle(Strings.yes_caps, for: .normal)
            negativeActionButton.setTitle(Strings.no_caps, for: .normal)
            let rideInvites = routeDeviationInfoViewModel.rideInvites
            if rideInvites.count == 1 {
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[0].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    self.userImageView1.isHidden = false
                    self.userImageView2.isHidden = true
                    if userBasicInfo != nil {
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView1, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.titleLabel.text = String(format: Strings.want_to_cancel_request, arguments: [userBasicInfo!.name!])
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!])
                    } else {
                        self.titleLabel.text = "Want to Cancel Request?"
                        self.subTitleLabel.text = "You may miss to add requested user to your ride if you confirm new route"
                    }
                })
                
            } else if rideInvites.count > 1 {
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[0].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    self.userImageView1.isHidden = false
                    if userBasicInfo != nil {
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView1, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.titleLabel.text = String(format: Strings.want_to_cancel_request, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                    } else {
                        self.titleLabel.text = "Want to Cancel Requests?"
                        self.subTitleLabel.text = "You may miss to add requested users to your ride if you confirm new route"
                    }
                })
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvites[1].passengerId, handler: { (userBasicInfo, responseResponse, error) in
                    if userBasicInfo != nil {
                        self.userImageView2.isHidden = false
                        ImageCache.getInstance().setImageToView(imageView: self.userImageView2, imageUrl: userBasicInfo!.imageURI, gender: userBasicInfo!.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
                        self.titleLabel.text = String(format: Strings.want_to_cancel_request, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                        self.subTitleLabel.text = String(format: Strings.you_may_miss_ride_taker, arguments: [userBasicInfo!.name!+"+\(rideInvites.count - 1)"])
                    } else {
                        self.userImageView2.isHidden = true
                        self.titleLabel.text = "Want to Cancel Requests?"
                        self.subTitleLabel.text = "You may miss to add requested users to your ride if you confirm new route"
                    }
                })
            }
        }
    }
    
    private func cancelRideInvitations() {
        let rideInvites = routeDeviationInfoViewModel.rideInvites
        for rideInvite in rideInvites {
            if rideInvite.invitingUserId == UserDataCache.getCurrentUserId() {
                QuickRideProgressSpinner.startSpinner()
                RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvite.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: self) { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if error != nil {
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, rideInvitation: rideInvite)
                    }
                }
            }else{
                let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvite, moderatorId: nil, viewController: nil, rideRejectReason: Strings.invite_reject_reason, rideInvitationActionCompletionListener: self)
                riderRejectPassengerInvitationTask.rejectPassengerInvitation()
            }
        }
    }
    
    private func removeInvitationAndRefreshData(status : String, rideInvitation : RideInvitation){
        let totleRideInvitations = routeDeviationInfoViewModel.rideInvites
        for (index,rideInvite) in totleRideInvitations.enumerated() {
            if rideInvite.rideInvitationId == rideInvitation.rideInvitationId {
                routeDeviationInfoViewModel.rideInvites.remove(at: index)
                break
            } else {
                continue
            }
        }
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
        rideInvitation.invitationStatus = status
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
        if routeDeviationInfoViewModel.rideInvites.isEmpty {
            self.removeView(state: RouteDeviationDetector.CONFIRMED)
        }
    }
    
    //MARK: Actions
    @IBAction func positiveActionButtonTapped(_ sender: UIButton) {
        if routeDeviationInfoViewModel.rideInvites.isEmpty && positiveActionButton.titleLabel?.text == Strings.confirm_caps {
            stopTimer()
            handleViewBasedOnPendingPickupsOrInvite()
        } else if positiveActionButton.titleLabel?.text == Strings.confirm_caps {
            stopTimer()
            handleCancelInviteView()
        } else if positiveActionButton.titleLabel?.text == Strings.yes_caps {
            cancelRideInvitations()
        }
    }
    
    @IBAction func negativeActionButtonTapped(_ sender: UIButton) {
        removeView(state: RouteDeviationDetector.CANCELLED)
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        removeView(state: RouteDeviationDetector.CANCELLED)
    }
    
}
//MARK: Route Receiver delegate
extension RouteDeviationInfoViewController: RouteReceiver {
    func receiveRoute(rideRoute: [RideRoute], alternative: Bool) {
        QuickRideProgressSpinner.stopSpinner()
        if !rideRoute.isEmpty {
            routeDeviationInfoViewModel.newRoute = rideRoute[0]
            let missingPickups = RouteDeviationDetector().getMissingPickups(riderRide: routeDeviationInfoViewModel.riderRide!, newRoute: routeDeviationInfoViewModel.newRoute!)
            let rideInvites = RouteDeviationDetector().getMissingRideInvites(riderRide: routeDeviationInfoViewModel.riderRide!, newRoute: routeDeviationInfoViewModel.newRoute!)
            if !missingPickups.isEmpty {
                routeDeviationInfoViewModel.rideParticipants = missingPickups
                handlePickupView()
            } else if !rideInvites.isEmpty {
                routeDeviationInfoViewModel.rideInvites = rideInvites
                handleRideInviteView()
            } else {
                removeView(state: RouteDeviationDetector.CONFIRMED)
            }
        }
    }
    
    func receiveRouteFailed(responseObject: NSDictionary?, error: NSError?) {
        QuickRideProgressSpinner.stopSpinner()
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
}
//MARK: RideInvitationActionCompletionListener delegate
extension RouteDeviationInfoViewController: RideInvitationActionCompletionListener {
    
    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED, rideInvitation: rideInvitation)
    }
    
    func rideInviteAcceptCompleted(rideInvitationId: Double) {}
    
    func rideInviteActionFailed(rideInvitationId: Double, responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {}
    
    func rideInviteActionCancelled() {}
    
}
