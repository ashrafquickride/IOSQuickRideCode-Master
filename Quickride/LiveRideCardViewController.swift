//
//  LiveRideCardViewController.swift
//  Quickride
//
//  Created by Vinutha on 04/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import MessageUI

class LiveRideCardViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var liveRideTableView: UITableView!
    @IBOutlet weak var callChatButtonContainerView: UIView!
    @IBOutlet weak var callChatButton: UIButton!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var liveRideViewModel = LiveRideViewModel()

    //MARK: Initializer
    func initializeDataBeforePresenting(liveRideViewModel: LiveRideViewModel) {
        self.liveRideViewModel = liveRideViewModel
    }

    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: liveRideTableView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        if !liveRideViewModel.isRideDataValid(){
            if let liveRideMapViewController = self.parent?.parent as? LiveRideMapViewController {
                liveRideMapViewController.displayRideClosedDialogue()
                return
            }
        }
        registerCell()
        addNotificationObservers()
        liveRideViewModel.getJobPromotionAd {
            self.liveRideTableView.reloadData()
        }
        liveRideViewModel.getOffers()
        if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE {
            liveRideViewModel.getTaxiOptions { [weak self](result) in
                    self?.liveRideTableView.reloadData()
            }
        }
        checkAndGetRidePaymentDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        relaodTableView()
    }

    private func registerCell() {
        
        liveRideTableView.estimatedRowHeight = 150
        liveRideTableView.rowHeight = UITableView.automaticDimension
        liveRideTableView.register(UINib(nibName: "UserDetailForRiderAndPassengerCardTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailForRiderAndPassengerCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "RiderDetailToPassengerCardTableViewCell", bundle: nil), forCellReuseIdentifier: "RiderDetailToPassengerCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "JoinedRideParticipantCardTableViewCell", bundle: nil), forCellReuseIdentifier: "JoinedRideParticipantCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "InviteByContactTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteByContactTableViewCell")
        liveRideTableView.register(UINib(nibName: "RideEtiquettesCardTableViewCell", bundle: nil), forCellReuseIdentifier: "RideEtiquettesCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "RideModeratorCardTableViewCell", bundle: nil), forCellReuseIdentifier: "RideModeratorCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "PaymentInfoCardTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentInfoCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "AddPaymentCardTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPaymentCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "WhatsAppUpdateCardTableViewCell", bundle: nil), forCellReuseIdentifier: "WhatsAppUpdateCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "EditAndCancelActionTableViewCell", bundle: nil), forCellReuseIdentifier: "EditAndCancelActionTableViewCell")
        liveRideTableView.register(UINib(nibName: "JobPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "JobPromotionTableViewCell")
        liveRideTableView.register(UINib(nibName: "PaymentPendingCardTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentPendingCardTableViewCell")
        liveRideTableView.register(UINib(nibName: "PaymentDetailsOutStationTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentDetailsOutStationTableViewCell")
        liveRideTableView.register(UINib(nibName: "HomeScreenAndLiveRideOfferTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeScreenAndLiveRideOfferTableViewCell")
        liveRideTableView.register(UINib(nibName: "RideNotesTableViewCell", bundle: nil), forCellReuseIdentifier: "RideNotesTableViewCell")
        liveRideTableView.register(UINib(nibName: "ShareRidePathTableViewCell", bundle: nil), forCellReuseIdentifier: "ShareRidePathTableViewCell")
        liveRideTableView.register(UINib(nibName: "RepeatRecurringRideTableViewCell", bundle: nil), forCellReuseIdentifier: "RepeatRecurringRideTableViewCell")
        liveRideTableView.register(UINib(nibName: "SwitchRiderTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchRiderTableViewCell")
        liveRideTableView.register(UINib(nibName: "CarpoolContactCustomerCareTableViewCell", bundle: nil), forCellReuseIdentifier: "CarpoolContactCustomerCareTableViewCell")
        liveRideTableView.register(UINib(nibName: "MatchingTaxipoolTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingTaxipoolTableViewCell")
        liveRideTableView.register(UINib(nibName: "HomepageTaxiCardTableViewCell", bundle: nil), forCellReuseIdentifier: "HomepageTaxiCardTableViewCell")
    }


    fileprivate func relaodTableView() {
        if !liveRideViewModel.isRideDataValid(){
            if let liveRideMapViewController = self.parent?.parent as? LiveRideMapViewController {
                liveRideMapViewController.displayRideClosedDialogue()
                return
            }
        }
        if let liveRideMapViewController = self.parent?.parent as? LiveRideMapViewController {
            liveRideMapViewController.enableControlsAsPerStatus()
            
        }
        liveRideTableView.reloadData()
        handleVisibilityOfCallChatButton()
    }

    func handleRequestedRide(){
        AppDelegate.getAppDelegate().log.debug("handleRequestedRide()")
        guard let passengerRideId = liveRideViewModel.currentUserRide?.rideId else { return }
        liveRideViewModel.currentUserRide =  MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: passengerRideId)
        if liveRideViewModel.currentUserRide != nil {
            liveRideViewModel.rideDetailInfo = nil
            liveRideViewModel.updateIsModerator()
            relaodTableView()
        }
    }

    func handleScheduleRide() {
        liveRideViewModel.getRideDetailInfo { [weak self](responseError, error) in
            if error == nil && responseError == nil {
                self?.liveRideViewModel.updateIsModerator()
                self?.relaodTableView()
            }
        }
    }
    func handleRideParticipantLocations(rideParticipantLocations : [RideParticipantLocation]){
        liveRideViewModel.rideDetailInfo?.rideParticipantLocations = rideParticipantLocations
        if let cell = liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserDetailForRiderAndPassengerCardTableViewCell {
            cell.handleEtaShowingToRider()
        }
    }
    
    func handleRiderStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleRiderStatusChange")
        guard let newRideStatus = rideStatus.status, let currentUserRide = liveRideViewModel.currentUserRide else {
            return
        }
        if Ride.RIDE_STATUS_STARTED == newRideStatus ||
            Ride.RIDE_STATUS_DELAYED == newRideStatus || Ride.RIDE_STATUS_COMPLETED == newRideStatus {

                liveRideViewModel.getRideDetailInfo { [weak self] (responseError, error) in
                    if error == nil && responseError == nil{
                        self?.relaodTableView()
                    }
                
            }
        } else if Ride.RIDE_STATUS_CANCELLED == newRideStatus {
            if currentUserRide.rideType == Ride.PASSENGER_RIDE{
                handleRequestedRide()
                return
            }
        }
    }
    
    private func handleVisibilityOfCallChatButton(){
        guard let currentUserRide = liveRideViewModel.currentUserRide else { return }
        guard let riderParticipanInfo = liveRideViewModel.getRiderParticipantInfo() else {
            callChatButtonContainerView.isHidden = true
            return
        }
        if currentUserRide.rideType == Ride.PASSENGER_RIDE && riderParticipanInfo.enableChatAndCall && currentUserRide.status != Ride.RIDE_STATUS_REQUESTED {
            callChatButtonContainerView.isHidden = false
        }else {
            callChatButtonContainerView.isHidden = true
        }
    }
    
    func handlePassengerStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handlePassengerStatusChange")
        guard let newRideStatus = rideStatus.status,let currentUserRide = liveRideViewModel.currentUserRide else {
            return
        }
        
        if Ride.RIDE_STATUS_SCHEDULED == newRideStatus && rideStatus.userId == currentUserRide.userId{
            handleScheduleRide()
        }else if Ride.RIDE_STATUS_SCHEDULED == newRideStatus
                    || Ride.RIDE_STATUS_STARTED == newRideStatus
                    || Ride.RIDE_STATUS_COMPLETED == newRideStatus
                    || Ride.RIDE_STATUS_CANCELLED == newRideStatus
                    || Ride.RIDE_STATUS_DELAYED == rideStatus.status{
            if liveRideViewModel.taxiRideId != 0 {
                relaodTableView()
            }else{
                
                if Ride.RIDER_RIDE == currentUserRide.rideType,let userDetailToRiderAndPassengerTableViewCell = self.liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserDetailForRiderAndPassengerCardTableViewCell{
                    userDetailToRiderAndPassengerTableViewCell.initiateData(currentUserRide: currentUserRide, isFromRideCreation: false)
                }else{
                    liveRideViewModel.getRideDetailInfo { [weak self](responseError, error) in
                        if error != nil && responseError == nil { return }
                        if Ride.RIDE_STATUS_STARTED == newRideStatus {
                            self?.relaodTableView()
                        }else {
                            if let joinedRideParticipantCardTableViewCell = self?.liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? JoinedRideParticipantCardTableViewCell,let ride = self?.liveRideViewModel.currentUserRide {
                                joinedRideParticipantCardTableViewCell.initializeData(ride: ride, riderRide: self?.liveRideViewModel.rideDetailInfo?.riderRide, passengersInfo: self?.liveRideViewModel.getPassengersParticipantInfo() ?? [], taxiShareRide: self?.liveRideViewModel.rideDetailInfo?.taxiShareRide)
                            }
                            if let riderDetailToPassengerCardTableViewCell = self?.liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RiderDetailToPassengerCardTableViewCell{
                                riderDetailToPassengerCardTableViewCell.initiateData(ride: currentUserRide)
                            }
                        }
                    }
                }
            }
        }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
            if Ride.RIDER_RIDE == currentUserRide.rideType,let userDetailToRiderAndPassengerTableViewCell = self.liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UserDetailForRiderAndPassengerCardTableViewCell{
                userDetailToRiderAndPassengerTableViewCell.initiateData(currentUserRide: currentUserRide, isFromRideCreation: false)
            } else if rideStatus.userId == currentUserRide.userId{
                handleRequestedRide()
            } else {
                liveRideViewModel.getRideDetailInfo { [weak self] (responseError, error) in
                    if error == nil && responseError == nil{
                        if let joinedRideParticipantCardTableViewCell = self?.liveRideTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? JoinedRideParticipantCardTableViewCell,let ride = self?.liveRideViewModel.currentUserRide{
                            joinedRideParticipantCardTableViewCell.initializeData(ride: ride, riderRide: self?.liveRideViewModel.rideDetailInfo?.riderRide, passengersInfo: self?.liveRideViewModel.getPassengersParticipantInfo() ?? [], taxiShareRide: self?.liveRideViewModel.rideDetailInfo?.taxiShareRide)
                        }
                    }
                }
            }
        }
    }

    func taxiReachedState() {
        let indexPath = IndexPath(row: 0,section: 0)
        self.liveRideTableView.reloadRows(at: [indexPath], with: .none)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: nil) {(data) in
            self.liveRideTableView.reloadData()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    private func checkAndGetRidePaymentDetails(){
        liveRideViewModel.getRidePaymentDetails { responseError, error in
            if responseError == nil && error == nil {
                self.liveRideTableView.reloadData()
            }
        }
    }
    
    @IBAction func callChatButtonTapped(_ sender: Any) {
        guard let rideParticipant = liveRideViewModel.getRiderParticipantInfo() else {
            return
        }
        var isRideStarted = false
        if rideParticipant.rider && rideParticipant.status == Ride.RIDE_STATUS_STARTED && rideParticipant.callSupport != UserProfile.SUPPORT_CALL_NEVER{
            isRideStarted = true
        }else{
            isRideStarted = false
        }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.initializeDataBeforePresentingView(ride: liveRideViewModel.currentUserRide, userId: rideParticipant.userId, isRideStarted: isRideStarted, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
}
//MARK: TableView datasource
extension LiveRideCardViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 17
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Requested
            if liveRideViewModel.currentUserRide?.rideType == Ride.RIDER_RIDE  || liveRideViewModel.isModerator || liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_REQUESTED {
                return 1
            }
            return 0
        case 1: // joined
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED) && !liveRideViewModel.isModerator {
                return 1
            }
            return 0
        case 2:
            if let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide,passengerRide.riderId == 0{
                if let _ = liveRideViewModel.matchedTaxipool{
                    return 1
                }else if let detailEstimatedFare =  liveRideViewModel.detailEstimatedFare,detailEstimatedFare.serviceableArea,!liveRideViewModel.isOutstationRide(){
                    return 1
                }
            }
            return 0
        case 3: // Joined ride participant
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED) && !liveRideViewModel.isModerator {
                return 1
            }
            return 0
        case 4:// payment
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE, liveRideViewModel.ridePaymentDetails != nil {
                return 1
            }else if let riderRide = liveRideViewModel.currentUserRide as? RiderRide,riderRide.noOfPassengers > 0{
                return 1
            }
            return 0
        case 5:
            if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil {
                return 1
            }
            return 0
        case 6: //invite by conatact
            if let ridetype = liveRideViewModel.currentUserRide?.rideType, ridetype == Ride.RIDER_RIDE, let riderRide =  liveRideViewModel.currentUserRide as? RiderRide, riderRide.freezeRide == false{
                return 1
            }else if let ridetype = liveRideViewModel.currentUserRide?.rideType, ridetype == Ride.PASSENGER_RIDE,let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide, passengerRide.riderId == 0{
                return 1
            }
            return 0
        case 7: // ettiqueates
            if let rideType = liveRideViewModel.currentUserRide?.rideType, LiveRideViewModelUtil.filterRideEtiqueteIamges(rideType: rideType).count > 0{
                return 1
            }
            return 0
        case 8: //ride notes
            if let ridetype = liveRideViewModel.currentUserRide?.rideType, ridetype == Ride.RIDER_RIDE {
                return 1
            }
            return 0
        case 9: // recurring ride
            if liveRideViewModel.checkCurrentRideIsValidForRecurringRide(){
                return 1
            }
            return 0
        case 10: // moderator
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_REQUESTED {
                return 0
            }
            return 1
        case 11: // job promotion
            if !liveRideViewModel.jobPromotionData.isEmpty {
                return 1
            }
            return 0
        case 12: // Offer
            if liveRideViewModel.finalOfferList.count > 0 {
                return 1
            }else{
                return 0
            }
        case 13: // whatsapp
            return 1
        case 14: //share ride path
            if liveRideViewModel.currentUserRide?.rideType == Ride.RIDER_RIDE || (liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_SCHEDULED || liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_STARTED || liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_DELAYED)){
                return 1
            }else{
                return 0
            }
        case 15: // help
            return 1
        case 16: // edit ride
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let userDetailForRiderAndPassengerCardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserDetailForRiderAndPassengerCardTableViewCell", for: indexPath) as! UserDetailForRiderAndPassengerCardTableViewCell
            userDetailForRiderAndPassengerCardTableViewCell.initiateData(currentUserRide: liveRideViewModel.currentUserRide!, isFromRideCreation: liveRideViewModel.isFromRideCreation )
            liveRideViewModel.isFromRideCreation = false
            return userDetailForRiderAndPassengerCardTableViewCell
        case 1:
            let riderDetailToPassengerCardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RiderDetailToPassengerCardTableViewCell", for: indexPath) as! RiderDetailToPassengerCardTableViewCell
            riderDetailToPassengerCardTableViewCell.initiateData(ride: liveRideViewModel.currentUserRide!)
            return riderDetailToPassengerCardTableViewCell
        case 2:
            if let matchedTaxipool = liveRideViewModel.matchedTaxipool{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingTaxipoolTableViewCell", for: indexPath) as! MatchingTaxipoolTableViewCell
                cell.showMatchedTaxiUserInfo(taxiMatchedGroup: matchedTaxipool,ride: self.liveRideViewModel.currentUserRide!)
                return cell
            }else{
                let taxiCell = tableView.dequeueReusableCell(withIdentifier: "HomepageTaxiCardTableViewCell", for: indexPath) as! HomepageTaxiCardTableViewCell
                taxiCell.initialiseTaxiView(detailEstimatedFare: liveRideViewModel.detailEstimatedFare!,ride: liveRideViewModel.currentUserRide)
                return taxiCell
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedRideParticipantCardTableViewCell", for: indexPath) as! JoinedRideParticipantCardTableViewCell
            cell.initializeData(ride: liveRideViewModel.currentUserRide!, riderRide: liveRideViewModel.rideDetailInfo?.riderRide, passengersInfo: liveRideViewModel.getPassengersParticipantInfo(), taxiShareRide: self.liveRideViewModel.rideDetailInfo?.taxiShareRide)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentInfoCardTableViewCell", for: indexPath) as! PaymentInfoCardTableViewCell
            cell.initializeData(rideObj: liveRideViewModel.currentUserRide!, ridePaymentDetails: liveRideViewModel.ridePaymentDetails, viewController: self){ completed in
                if completed {
                    self.showPaymentDrawer()
                }
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPaymentCardTableViewCell", for: indexPath) as! AddPaymentCardTableViewCell
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteByContactTableViewCell", for: indexPath) as! InviteByContactTableViewCell
            cell.initializeInviteByContactView(ride: liveRideViewModel.currentUserRide!,isFromLiveride: true, viewContoller: self,taxiRide: nil)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideEtiquettesCardTableViewCell", for: indexPath) as! RideEtiquettesCardTableViewCell
            cell.initializeView(rideObj: liveRideViewModel.currentUserRide!)
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideNotesTableViewCell", for: indexPath) as! RideNotesTableViewCell
            cell.initialiseRideNotes()
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatRecurringRideTableViewCell", for: indexPath) as! RepeatRecurringRideTableViewCell
            cell.initializeRecurringRideView(rideType: liveRideViewModel.currentUserRide?.rideType ?? "", currentUserRideId: liveRideViewModel.currentUserRide?.rideId,currentRide: liveRideViewModel.currentUserRide)
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideModeratorCardTableViewCell", for: indexPath) as! RideModeratorCardTableViewCell
            cell.initializeData(rideType: liveRideViewModel.currentUserRide!.rideType!)
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobPromotionTableViewCell", for: indexPath) as! JobPromotionTableViewCell
            cell.setupUI(jobPromotionData: liveRideViewModel.jobPromotionData,screenName: ImpressionAudit.LiveRide)
            return cell
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
            cell.prepareData(offerList: liveRideViewModel.finalOfferList,isFromLiveRide: true)
            return cell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhatsAppUpdateCardTableViewCell", for: indexPath) as! WhatsAppUpdateCardTableViewCell
            cell.initialiseWhatsappStatus()
            return cell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareRidePathTableViewCell", for: indexPath) as! ShareRidePathTableViewCell
            cell.initialiseRidePath(ride: liveRideViewModel.currentUserRide)
            return cell
        case 15:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolContactCustomerCareTableViewCell", for: indexPath) as! CarpoolContactCustomerCareTableViewCell
            cell.initialiseHelp(title: "NEED HELP", tripStatus: nil, tripType: nil, sharing: nil, isFromTaxiPool: false)
            return cell
        case 16:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditAndCancelActionTableViewCell", for: indexPath) as! EditAndCancelActionTableViewCell
            cell.initializeData(ride: liveRideViewModel.currentUserRide!, rideParticipants: liveRideViewModel.rideDetailInfo?.rideParticipants)
            return cell
        default:
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
            
        }
    }
}
//MARK: TableView delegate
extension LiveRideCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED) && !liveRideViewModel.isModerator {
                return 0
            }
            return 10
        case 1:
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED) && !liveRideViewModel.isModerator {
                return 10
            }
            return 0
        case 2:
            if let passengerRide = liveRideViewModel.currentUserRide as? PassengerRide,passengerRide.riderId == 0{
                if let _ = liveRideViewModel.matchedTaxipool{
                    return 10
                }else if let detailEstimatedFare =  liveRideViewModel.detailEstimatedFare,detailEstimatedFare.serviceableArea,!liveRideViewModel.isOutstationRide(){
                    return 10
                }
            }
            return 0
        case 3: // joined members casd
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && (liveRideViewModel.currentUserRide?.status != Ride.RIDE_STATUS_REQUESTED) && !liveRideViewModel.isModerator {
                return 10
            }
            return 0
        case 4:
            if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil {
                return 1
            }else {
                if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE, liveRideViewModel.ridePaymentDetails != nil {
                    return 10
                }else if let riderRide = liveRideViewModel.currentUserRide as? RiderRide,riderRide.noOfPassengers > 0{
                    return 10
                }
                return 0
            }
        case 5:
            if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil {
                return 10
            }
            return 0
        case 7:
            if let rideType = liveRideViewModel.currentUserRide?.rideType, LiveRideViewModelUtil.filterRideEtiqueteIamges(rideType:  rideType).count > 0{
                return 10
            }
            return 0
        case 8:
            if let ridetype = liveRideViewModel.currentUserRide?.rideType, ridetype == Ride.RIDER_RIDE {
                return 10
            }
            return 0
        case 9:
            if liveRideViewModel.checkCurrentRideIsValidForRecurringRide(){
                return 10
            }
            return 0
        case 10: //recurring
            if liveRideViewModel.currentUserRide?.rideType == Ride.PASSENGER_RIDE && liveRideViewModel.currentUserRide?.status == Ride.RIDE_STATUS_REQUESTED {
                return 0
            }
            return 10
        case 11:
            if !liveRideViewModel.jobPromotionData.isEmpty {
                return 10
            }
            return 0
        case 12:
            if liveRideViewModel.finalOfferList.count > 0 {
                return 10
            }else{
                return 0
            }
        case 13:
            return 10
        case 14:
            return 1
        case 15:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor(netHex: 0xEDEDED)
        return footerCell
    }
}
extension LiveRideCardViewController {

    func addNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(linkedWalletAdded), name: .linkedWalletAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(freezeRideUpdated), name: .freezeRideUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rideModerationStatusChanged), name: .rideModerationStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rideModerationStatusChanged), name: .rideModerationStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(passengerPickedUp), name: .passengerPickedUp, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(passengerPickedUpRideStartedStatus), name: .passengerPickedUpRideStartedStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(outStationViewTaxiDetail), name: .outStationViewTaxiDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(outStationViewTaxiDetail), name: .outStationViewTaxiDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUiWithNewData), name: .updateUiWithNewData, object: nil)
    }

    @objc func updateUiWithNewData(_ notification: Notification){
        relaodTableView()
    }

    @objc func outStationViewTaxiDetail(_ notification: Notification){
        let data = notification.userInfo?["outstationTaxiAvailabilityInfo"] as? OutstationTaxiAvailabilityInfo
        liveRideViewModel.outstationTaxiAvailabilityInfo = data
    }

    @objc func passengerPickedUpRideStartedStatus(_ notification: Notification){
        relaodTableView()
    }

    @objc func passengerPickedUp(_ notification: Notification){
        relaodTableView()
    }

    @objc func rideModerationStatusChanged(_ notification: Notification){
        liveRideViewModel.updateIsModerator()
        if let passenger = liveRideViewModel.currentUserRide as? PassengerRide,passenger.status == PassengerRide.RIDE_STATUS_STARTED{
            relaodTableView()
        }
    }

    @objc func freezeRideUpdated(_ notification: Notification){
        if let currentUserRide = self.liveRideViewModel.currentUserRide{
            self.relaodTableView()
        }
    }

    @objc func linkedWalletAdded(_ notification: Notification){
        relaodTableView()
    }
}
