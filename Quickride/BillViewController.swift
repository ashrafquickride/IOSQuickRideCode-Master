//
//  BillViewController.swift
//  Quickride
//
//  Created by Ashutos on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import MessageUI
import StoreKit
import DropDown

class BillViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var needHelpAndDoneButtonView: UIView!

    private var billViewModel = BillViewModel()

    static var COMPLETED_RIDE_TYPE : String?
    static var COMPLETED_RIDE_ID : Double?
    private var  modelLessDialogue: ModelLessDialogue?
    var isFareBreakUpTapped = false

    func initializeDataBeforePresenting(rideBillingDetails: [RideBillingDetails]?, isFromClosedRidesOrTransaction : Bool,rideType : String,currentUserRideId : Double) {
        billViewModel.rideBillingDetails = rideBillingDetails
        if let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty {
            if rideType == Ride.PASSENGER_RIDE{
                billViewModel.rideId = Double(rideBillingDetails[0].refId ?? "")
            } else {
                billViewModel.rideId = Double(rideBillingDetails[0].sourceRefId ?? "")
            }
        }
        billViewModel.isFromClosedRidesOrTransaction = isFromClosedRidesOrTransaction
        billViewModel.rideType  = rideType
        billViewModel.currentUserRideId = currentUserRideId
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setUpUI()
        setUpUIForAppStorePopUps()
        getUserBasicInfo()
    }

    private func setUpUI() {

        tableView.register(UINib(nibName: "BillHeaderCardTableViewCell", bundle: nil), forCellReuseIdentifier: "BillHeaderCardTableViewCell")

        tableView.register(UINib(nibName: "UserDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserDetailsTableViewCell")
        tableView.register(UINib(nibName: "BillInsurenceViewTableViewCell", bundle: nil), forCellReuseIdentifier: "BillInsurenceViewTableViewCell")
        tableView.register(UINib(nibName: "BillRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "BillRatingTableViewCell")
        tableView.register(UINib(nibName: "CO2TableViewCell", bundle: nil), forCellReuseIdentifier: "CO2TableViewCell")

        tableView.register(UINib(nibName: "BillRideTakersTableViewCell", bundle: nil), forCellReuseIdentifier: "BillRideTakersTableViewCell")

        tableView.register(UINib(nibName: "PassangerTableViewCell", bundle: nil), forCellReuseIdentifier: "PassangerTableViewCell")
        tableView.register(UINib(nibName: "AutoMatchTableViewCell", bundle: nil), forCellReuseIdentifier: "AutoMatchTableViewCell")
        tableView.register(UINib(nibName: "RepeatRecurringRideTableViewCell", bundle: nil), forCellReuseIdentifier: "RepeatRecurringRideTableViewCell")

        tableView.register(UINib(nibName: "BillReferralTableViewCell", bundle: nil), forCellReuseIdentifier: "BillReferralTableViewCell")
        tableView.register(UINib(nibName: "reviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewTableViewCell")
        tableView.register(UINib(nibName: "OffersListTableViewCell", bundle: nil), forCellReuseIdentifier: "OffersListTableViewCell")
        tableView.register(UINib(nibName: "UnjoinedRideParticipantTableViewCell", bundle: nil), forCellReuseIdentifier: "UnjoinedRideParticipantTableViewCell")
        tableView.register(UINib(nibName: "BillRefundDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "BillRefundDetailsTableViewCell")
         tableView.register(UINib(nibName: "TaxiPoolBillFeedBackTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolBillFeedBackTableViewCell")
        tableView.register(UINib(nibName: "NewRouteFoundTableViewCell", bundle: nil), forCellReuseIdentifier: "NewRouteFoundTableViewCell")
        tableView.register(UINib(nibName: "JobPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "JobPromotionTableViewCell")
        tableView.register(UINib(nibName: "RideGiverDetailTableViewCell", bundle : nil),forCellReuseIdentifier: "RideGiverDetailTableViewCell")
        tableView.register(UINib(nibName: "CarpoolInvoiceDetailsTableViewCell", bundle : nil),forCellReuseIdentifier: "CarpoolInvoiceDetailsTableViewCell")
        tableView.register(UINib(nibName: "FareDetailsTableViewCell", bundle : nil),forCellReuseIdentifier: "FareDetailsTableViewCell")
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
        needHelpAndDoneButtonView.addShadow()
        billViewModel.getUnjonedUsersFromThisRide(delegate: self)
        doneButton.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        doneButton.layer.shadowOffset = CGSize(width: 0,height: 1)
        doneButton.layer.shadowRadius = 3
        doneButton.layer.shadowOpacity = 1
        billViewModel.InitialiseInvoiceDropDownData()
        billViewModel.getPassengerRide()
        billViewModel.getJobPromotionAd(delegate: self)
        callRideSharingCommunityContributionGettingTask()
        billViewModel.setTripReportOptionsWithValidations()
        if billViewModel.isFromClosedRidesOrTransaction{
            doneButton.isHidden = true
        }else{
            doneButton.isHidden = false
        }

        if billViewModel.rideType == Ride.PASSENGER_RIDE {
            if let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty, let rideLastBill = rideBillingDetails.last, rideLastBill.insuranceClaimed ?? false {
                billViewModel.showInsuranceCard = true
                tableView.reloadData()
            }
            billViewModel.isTaxiIDFromTransction()
        }
        if billViewModel.isTaxiRide() {
            billViewModel.getTaxiShareRideForTaxiPool(completionHandler: {
                result in
                self.tableView.reloadData()
            })
        billViewModel.getFeedBackData(completionHandler: {
                result in
                self.tableView.reloadData()
            })
        } else {
            if let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty, let riderRideId = rideBillingDetails[0].sourceRefId  {
                MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipants(riderRideId: Double(riderRideId) ?? 0, rideParticipantsListener: self)
            }
            billViewModel.checkAndDisplayUserFeedBack(vc: self, completionHandler: {
                result in
                self.billViewModel.isFeedbackLoaded = true
                self.tableView.reloadData()
            })
        }

        if billViewModel.rideType == Ride.RIDER_RIDE, let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty, let sourceRefId = rideBillingDetails[0].sourceRefId {
            let rideTravelledPath = RideTravelledPathTask(rideId: Double(sourceRefId) ?? 0, targetViewController: self, isFromViewMap: false, listener: self)
            rideTravelledPath.getRideTravelledPath()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUiWithNewData), name: .updateUiWithNewData, object: nil)
    }

    @objc func updateUiWithNewData(_ notification: Notification){
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func setUpUIForAppStorePopUps() {
        if !billViewModel.isFromClosedRidesOrTransaction {
            let totalCompletedRides = Int(UserDataCache.getInstance()?.getLoggedInUserProfile()?.numberOfRidesAsRider ?? 0) + Int(UserDataCache.getInstance()?.getLoggedInUserProfile()?.numberOfRidesAsPassenger ?? 0)
            let lastDisplayedTime = SharedPreferenceHelper.getLikingTheAppPopupShownDate()
            if lastDisplayedTime == nil || DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayedTime!) > BillViewModel.DAYS_AFTER_LIKE_POPUP_SHOULD_SHOW {
                showAppStoreRatingPopUP(status: 1)
                return
            } else if totalCompletedRides%5 == 0 && SharedPreferenceHelper.getSkipRatingDate() != nil {
                showAppStoreRatingPopUP(status: 2)
                return
            } else {
                return
            }
        } else {
            return
        }
    }

    private func showAppStoreRatingPopUP(status: Int) {
        let appStoreRatingVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AppStoreRatingViewController") as! AppStoreRatingViewController
        appStoreRatingVC.initialiseView(status: status)
        appStoreRatingVC.delegate = self
        ViewControllerUtils.addSubView(viewControllerToDisplay: appStoreRatingVC)
    }

    private func callRideSharingCommunityContributionGettingTask() {
        if billViewModel.rideType == Ride.RIDER_RIDE, let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty, let sourceRefId = rideBillingDetails[0].sourceRefId {
            RideManagementUtils.getRideContributionForRide(rideId: sourceRefId, viewController: self) { (rideContribution, error) in
                if rideContribution != nil{
                    self.billViewModel.rideContribution = rideContribution
                    rideContribution?.userId = Double(QRSessionManager.getInstance()!.getUserId())
                    self.tableView.reloadData()
                }
            }
        }else{
            var passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: billViewModel.currentUserRideId!)
            if(passengerRide == nil) {
                passengerRide = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: billViewModel.currentUserRideId!)
            }
            if passengerRide != nil && passengerRide!.riderId != 0 && Int(passengerRide!.overLappingDistance) > 0{
                billViewModel.rideContribution?.co2Reduced = RideContribution.co2ReducedForDistance(distance: passengerRide!.overLappingDistance)
                billViewModel.rideContribution?.petrolSaved = RideContribution.petrolSavedForDistance(distance: passengerRide!.overLappingDistance)
                billViewModel.rideContribution = RideContribution()
                billViewModel.rideContribution?.co2Reduced = RideContribution.co2ReducedForDistance(distance: passengerRide!.overLappingDistance)
                billViewModel.rideContribution?.petrolSaved = RideContribution.petrolSavedForDistance(distance: passengerRide!.overLappingDistance)
                billViewModel.rideContribution?.userId = Double(QRSessionManager.getInstance()!.getUserId())
            }
            tableView.reloadData()
        }

    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            if billViewModel.isTaxiRide() {
                CustomerSupportDetailsParser.getInstance().getCustomerSupportElement { (customerSupportElement) in
                    self.moveToTaxiPoolFAQ(customerSupportElement: customerSupportElement!,index: 9)
                }
            } else {
                guard let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty else { return }
                let needHelpViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NeedHelpViewController") as! NeedHelpViewController
                needHelpViewController.initializeView(){(action)in
                    self.tableView.reloadData()
                    switch action {
                    case .refund :
                        self.showRefundDailog()
                    }

                }
                needHelpViewController.modalPresentationStyle = .overFullScreen
                self.present(needHelpViewController, animated: false, completion: nil)
            }
        }else{
            HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: String(format: Strings.rider_bill_support_subject, arguments: [UserDataCache.getInstance()?.getUserName() ?? "",StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getInstance()?.getUser()?.contactNo),UserDataCache.getInstance()?.userId ?? "",StringUtils.getStringFromDouble(decimalNumber: billViewModel.currentUserRideId)]) , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
        }
    }
    func showRefundDailog(){
       let refundAmountRequestAlertController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RefundAmountRequestAlertController") as! RefundAmountRequestAlertController
        refundAmountRequestAlertController.initializeDataBeforePresentingView(points: billViewModel.rideBillingDetails?[0].rideFare ?? 0, handler: { (text, result) in
            if result == Strings.done_caps, let points = text{
               self.billViewModel.refundRequestToRider(points: Double(points),reason: Strings.i_didnt_take_ride, remindAgain: false, viewController: self) {
                   self.tableView.reloadData()
               }
           }
       })
        self.dismiss(animated: false)
       refundAmountRequestAlertController.modalPresentationStyle = .overFullScreen
       ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: refundAmountRequestAlertController, animated: true, completion: nil)
   }


   private func moveToTaxiPoolFAQ(customerSupportElement: CustomerSupportElement,index: Int) {
        let element = customerSupportElement.customerSupportElement![index]
        let customerInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerInfoViewController") as! CustomerInfoViewController
        customerInfoViewController.initializeDataBeforepresentingView(customerSupportElement: element)
        self.navigationController?.pushViewController(customerInfoViewController, animated: false)
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        backButtonClicked()
    }

    private func moveToCommentScreenForRideGiver(rating: Int,userId: Double,rideId: Double) {
        let rideParticipentDetails = RideViewUtils.getRideParticipantObjForParticipantId(participantId: userId, rideParticipants: billViewModel.rideParticipants)
        var userFeedBackDetail: UserFeedback?
        if billViewModel.userFeedBackList.isEmpty {
            userFeedBackDetail = UserFeedback(rideid: rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(rideParticipentDetails?.userId ?? 0), rating: Float(rating), extrainfo: "", feebBackToName: rideParticipentDetails?.name ?? "",feebBackToImageURI : rideParticipentDetails?.imageURI ?? "",feedBackToUserGender : rideParticipentDetails?.gender ?? "", feedBackCommentIds: nil)
        } else {
            for data in billViewModel.userFeedBackList{
                if data.feedbacktophonenumber == rideParticipentDetails?.userId{
                    userFeedBackDetail = data
                }
            }
            userFeedBackDetail = UserFeedback(rideid: rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(rideParticipentDetails?.userId ?? 0), rating: Float(rating), extrainfo: "", feebBackToName: rideParticipentDetails?.name ?? "",feebBackToImageURI : rideParticipentDetails?.imageURI ?? "",feedBackToUserGender : rideParticipentDetails?.gender ?? "", feedBackCommentIds: nil)
        }
        navigateToUserFeedback(feedBackDetails: userFeedBackDetail!,status: 1)
    }

    private func navigateToUserFeedback(feedBackDetails: UserFeedback,status: Int) {
        let destViewController  = UIStoryboard(name: StoryBoardIdentifiers.userfeedback_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserFeedbackViewController") as! UserFeedbackViewController

        destViewController.initializeDataBeforePresenting(rideId: billViewModel.rideId!,isFromClosedRidesOrTransaction : billViewModel.isFromClosedRidesOrTransaction,userFeedbackMap: feedBackDetails, riderType: billViewModel.rideType ?? "")
        destViewController.delegate = self
        destViewController.modalPresentationStyle = .overCurrentContext
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        present(destViewController, animated: true, completion: nil)
    }

    //MARK:Refund
    private func handleRefundAction(rideBillingDetails: RideBillingDetails?) {
        let refundAmountRequestAlertController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RefundAmountRequestAlertController") as! RefundAmountRequestAlertController
        if rideBillingDetails == nil {
            if billViewModel.currentUserRideId == nil{
                UIApplication.shared.keyWindow?.makeToast( "Insufficient data,Please try later")
                return
            }
            // need to check
            refundAmountRequestAlertController.initializeDataBeforePresentingView(points: billViewModel.rideBillingDetails?.first?.rideFare ?? 0, handler: { (text, result) in
                if result == Strings.done_caps, let points = text{
                    self.billViewModel.completeRefundAfterPointsSelction(points: points,vc: self,delegate: self)
                }
            })
        } else {
            refundAmountRequestAlertController.initializeDataBeforePresentingView(points: rideBillingDetails?.rideTakerTotalAmount ?? 0.0, handler: { (text, result) in
                if result == Strings.done_caps, let points = text{
                    QuickRideProgressSpinner.startSpinner()
                    AccountRestClient.riderRefundToPassenger(accountTransactionId: nil, points: points, rideId: Double(rideBillingDetails?.refId ?? "") ?? 0, invoiceId:StringUtils.getStringFromDouble(decimalNumber: Double(rideBillingDetails?.rideInvoiceNo ?? 0)), viewController: self, completionHandler: { (responseObject, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                            UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
                        }else{
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                        }
                    })
                }
            })
        }
        self.navigationController?.view.addSubview(refundAmountRequestAlertController.view!)
        self.navigationController?.addChild(refundAmountRequestAlertController)
    }
    //MARK: SendInvoice
    private func sendInvoice() {
        let userProfile = UserDataCache.getInstance()!.userProfile
        if userProfile == nil ||
            ((userProfile!.emailForCommunication == nil || userProfile!.emailForCommunication!.isEmpty) && (userProfile!.email == nil || userProfile!.email!.isEmpty)) {
            modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as? ModelLessDialogue
            modelLessDialogue?.initializeViews(message: Strings.emailid_not_given_for_profile, actionText: Strings.configure_email)
            modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditingVC(_:))))
            modelLessDialogue?.isUserInteractionEnabled = true
            modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
            self.view.addSubview(modelLessDialogue!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.removeModelLessDialogue()
            }
            return
        }

        if UserDataCache.getInstance()?.getLoggedInUsersEmailPreferences().unSubscribe ?? false || !(UserDataCache.getInstance()?.getLoggedInUsersEmailPreferences().receiveRideTripReports ?? false) {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.preference_unsubsribe_message, message2: nil, positiveActnTitle: Strings.subscribe, negativeActionTitle : Strings.later_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
                if Strings.subscribe == result{
                    let communicationPreference = UIStoryboard(name : StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CommunicationPreferencesViewController") as! CommunicationPreferencesViewController
                    self.navigationController?.pushViewController(communicationPreference, animated: false)
                }
            })
            return
        }
        billViewModel.sendInvoice(vc: self)
    }
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }

    @objc private func profileEditingVC(_ recognizer: UITapGestureRecognizer) {
        navigateToProfile()
    }

    private func navigateToProfile() {
        let profileEditViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(profileEditViewController, animated: false)
    }

    private func navigateToRideParticipentsProfile(index:Int) {
        let profileDisplayViewController  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        guard let rideBillingDetails = billViewModel.rideBillingDetails, !rideBillingDetails.isEmpty else {
            return
        }
        var userId: Double = 0
        if billViewModel.rideType == Ride.PASSENGER_RIDE {
            if let userid = rideBillingDetails.first?.toUserId {
                userId = Double(userid)
            }
        }else {
            if let userid = rideBillingDetails[index].fromUserId {
                userId = Double(userid)
            }
        }
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: userId),isRiderProfile: UserRole.Passenger,rideVehicle : nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        profileDisplayViewController.isFromFeedbackView = true
        self.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }

    private func paymentReminderAlert(rideBillingDetails: RideBillingDetails) {
        MessageDisplay.displayErrorAlertWithAction(title: Strings.payment_pending_title, isDismissViewRequired: true, message1: Strings.payment_pending_msg, message2: nil, positiveActnTitle: Strings.send_reminder, negativeActionTitle: nil, linkButtonText: nil, viewController: self) { (actionText) in
            if actionText == Strings.send_reminder{
                QuickRideProgressSpinner.startSpinner()
                BillRestClient.requestPendingBillFromPassenger(userId: (QRSessionManager.getInstance()?.getUserId())!, billId: Double(rideBillingDetails.rideInvoiceNo ?? 0), targetViewController: self, completionHandler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        UIApplication.shared.keyWindow?.makeToast( Strings.payment_reminder_sent)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                })
            }
        }

    }
    private func getUserBasicInfo() {
        if billViewModel.rideType == Ride.PASSENGER_RIDE, let userId = billViewModel.rideBillingDetails?.first?.sourceRefId {
            UserDataCache.getInstance()?.getUserBasicInfo(userId: Double(userId) ?? 0, handler: {(userBasicInfo, responseError, error) in
                self.billViewModel.companyname = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData, companyName: userBasicInfo?.companyName?.capitalized)
                self.billViewModel.verifiedImage =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userBasicInfo?.profileVerificationData)
                self.tableView.reloadData()
            })
        }
    }
}

extension BillViewController: RideParticipantsListener {
    func getRideParticipants(rideParticipants: [RideParticipant]) {
        AppDelegate.getAppDelegate().log.debug("")
        if billViewModel.rideType == Ride.PASSENGER_RIDE {
            let userId :Double?
            let rideBill = billViewModel.rideBillingDetails?.first
            if rideBill == nil {
                RideManagementUtils.moveToRideCreationScreen(viewController: self)
                return
            }
            if QRSessionManager.getInstance()!.getUserId() == String(rideBill?.toUserId ?? 0) {
                userId = Double(rideBill?.fromUserId ?? 0)
            }else{
                userId = Double(rideBill?.toUserId ?? 0)
            }
            guard let rideParticipant = RideViewUtils.getRideParticipantObjForParticipantId(participantId: userId ?? 0, rideParticipants: rideParticipants) else { return }
            billViewModel.rideParticipants = [(rideParticipant)]
        }else{
            billViewModel.rideParticipants = rideParticipants
        }
        tableView.reloadData()
    }

    func removeCurrentUser( rideParticipants : [RideParticipant]?,userId : Double)-> [RideParticipant]?{
        var participantsOfRide = rideParticipants
        if participantsOfRide == nil || participantsOfRide!.isEmpty {
            return participantsOfRide
        }
        for index in 0...participantsOfRide!.count-1{
            if participantsOfRide![index].userId == userId{
                participantsOfRide!.remove(at: index)
                break
            }
        }
        return participantsOfRide
    }

    func onFailure(responseObject: NSDictionary?, error: NSError?) {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }

    private func passengerRatingViewForNotShowRatings() {
        if !self.billViewModel.userFeedBackList.isEmpty && self.billViewModel.userFeedBackList[0].rating != 0.0 {
            tableView.reloadData()
        }
    }
}

//MARK: UITableViewDataSource
extension BillViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            return 12
        }else{
            return 10
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            switch section {
            case 0:
                return 1 // header
            case 1:
                return 1 //userDeatils

            case 2:
                if billViewModel.rideType == Ride.PASSENGER_RIDE, billViewModel.rideBillingDetails?.last != nil && billViewModel.isExpanableBill {
                    return 1
                }else {
                    return 0
                }
            case 3:
                if billViewModel.isTaxiRide() {
                    return 1 //taxi bill details
                }else{
                    return 0
                }
            case 4:
                if billViewModel.showInsuranceCard{
                    return 1 // carpoolinsurance
                }else{
                    return 0
                }
            case 5:// co2 cell
                return 1
            case 6:// recurring ride
                if billViewModel.checkCurrentRideIsValidForRecurringRide(){
                    return 1
                }else{
                    return 0
                }
            case 7:// ride giver details
                return 1
            case 8:// job promotional data cell
                if billViewModel.jobPromotionData.count > 0{
                    return 1
                }else{
                    return 0
                }
            case 9:
                if !billViewModel.isFromClosedRidesOrTransaction{
                    return 1 // offers only ride complition not from closed and past transaction
                }else{
                    return 0
                }
            case 10:
                if billViewModel.oppositeUsers.count > 0{
                    return billViewModel.oppositeUsers.count // unjoined users from this ride
                }else{
                    return 0
                }
            case 11:
                if billViewModel.rideBillingDetails?.last?.refundRequest != nil {
                    return 1 // refund cell
                }else{
                    return 0
                }
            default:
                return 0
            }
        }else{
            switch section {
            case 0:
                return 1 // header
            case 1:
                return 1 // passenger details
            case 2:
                let count = billViewModel.rideBillingDetails?.count ?? 0
                if count > 1 {
                    return count
                }else if count == 1, billViewModel.invoiceDropDownData[0] ?? false{
                    return 1
                }else {
                    return 0
                }
            case 3:
                if billViewModel.jobPromotionData.count > 0{
                    return 1 // job promotion cell
                }else{
                    return 0
                }
            case 4:
                if billViewModel.isNewRouteFound(){
                    return 1 // new routes found
                }else{
                    return 0
                }
            case 5:
                return 1 // co2 cell
            case 6:// recurring ride
                if billViewModel.checkCurrentRideIsValidForRecurringRide(){
                    return 1
                }else{
                    return 0
                }
            case 7:
                if !billViewModel.isFromClosedRidesOrTransaction{
                    return 1 // offers etc
                }else{
                    return 0
                }
            case 8:
                if billViewModel.rideBillingDetails?.count ?? 0 > 0 {
                    return billViewModel.rideBillingDetails?.count ?? 0 // travelled passengers
                }else{
                    return 0
                }
            case 9:
                if billViewModel.oppositeUsers.count > 0{
                    return billViewModel.oppositeUsers.count //unjoined users
                }else{
                    return 0
                }
            default:
                return 0
            }

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
                cell.initializeHeaderView(rideType: billViewModel.rideType ?? "", rideDate: Double(billViewModel.rideBillingDetails?.first?.startTimeMs ?? 0), seats: "", isFromClosedRidesOrTransaction: billViewModel.isFromClosedRidesOrTransaction,isTaxiShareRide: billViewModel.isTaxiRide(), isCancelRide: false, isOutStationTaxi: billViewModel.isFromOutStation(), delegate: self, rideTackerName: nil)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsTableViewCell", for: indexPath) as! UserDetailsTableViewCell
                cell.initializeRiderDetails(isExpandable: billViewModel.isExpanableBill,riderDetails: billViewModel.rideParticipants?[0],rideBillingDetails:  billViewModel.rideBillingDetails?.first, riderType: billViewModel.rideType ?? "", isFromClosedRide: billViewModel.isFromClosedRidesOrTransaction, taxiShareInfoForInvoice: billViewModel.taxiShareInfoForInvoice, isTaxiRide: billViewModel.isTaxiRide(), isOutStationTaxi: billViewModel.isFromOutStation(), currentRide: billViewModel.ride, delegate: self)
                cell.walletNameButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
                cell.viewFareBreakUpBtn.setTitle("Break up", for: .normal)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FareDetailsTableViewCell", for: indexPath) as! FareDetailsTableViewCell
                cell.selectionStyle = .none
                cell.updateCellUIWithPassengerBillDetails(rideBillingDetails: billViewModel.rideBillingDetails?.last, companyName: billViewModel.companyname, verificationProfile: billViewModel.verifiedImage)
                cell.delegate = self
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiPoolBillFeedBackTableViewCell", for: indexPath) as! TaxiPoolBillFeedBackTableViewCell
                cell.initializeRatingCell(rating: billViewModel.ratingForTaxiPool,isRatingGiven:billViewModel.isFeedBackAlreadyGivenForTaxiPool,taxiRideId: billViewModel.getTaxiRideId(), feedBack: billViewModel.feedBackForTaxiPool)
                cell.delegate = self
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillInsurenceViewTableViewCell", for: indexPath) as! BillInsurenceViewTableViewCell
                cell.initializeInsuranceView(showInsuranceViw: billViewModel.showInsuranceCard, claimRefId: billViewModel.rideBillingDetails?.first?.claimRefId, delegate: self)
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CO2TableViewCell", for: indexPath) as! CO2TableViewCell
                cell.UpdateUI(rideContribution: billViewModel.rideContribution)
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatRecurringRideTableViewCell", for: indexPath) as! RepeatRecurringRideTableViewCell
                cell.initializeRecurringRideView(rideType: billViewModel.rideType, currentUserRideId: billViewModel.currentUserRideId,currentRide: nil)
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RideGiverDetailTableViewCell", for: indexPath) as! RideGiverDetailTableViewCell
                var userFeedback: UserFeedback?
                if !billViewModel.userFeedBackList.isEmpty{
                    userFeedback = billViewModel.userFeedBackList[0]
                }
                cell.initialiseRideGiver(riderDetails: billViewModel.rideParticipants?[0], rideBillingDetails: billViewModel.rideBillingDetails?.first, userFeedback: userFeedback, isFeedbackLoaded: billViewModel.isFeedbackLoaded,delegate: self, ratingDelegate: self)
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JobPromotionTableViewCell", for: indexPath) as! JobPromotionTableViewCell
                cell.tag = 2
                cell.setupUI(jobPromotionData: billViewModel.jobPromotionData, screenName: ImpressionAudit.TripReport)
                return cell
            case 9:
                switch SharedPreferenceHelper.getTripReportOptionShownIndex() {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AutoMatchTableViewCell", for: indexPath) as! AutoMatchTableViewCell
                    cell.seperatorView.isHidden = true
                    cell.setUpUI(rideType: billViewModel.rideType ?? Ride.PASSENGER_RIDE)
                    cell.delegate = self
                    return cell
                case 1:
                    if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                        let cell = tableView.dequeueReusableCell(withIdentifier: "BillReferralTableViewCell", for: indexPath) as! BillReferralTableViewCell
                        let info = String(format: Strings.earn_points_and_commission, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol])
                        cell.setUpView(title: String(format: Strings.hi_name, arguments: [UserDataCache.getInstance()!.getUserName()]), subTitle: info, delegate: self)

                        billViewModel.prepareOfferListAndUpdateUI()
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell", for: indexPath) as! reviewTableViewCell
                        cell.delegate = self
                        return cell
                    }
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell", for: indexPath) as! reviewTableViewCell
                    cell.delegate = self
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OffersListTableViewCell", for: indexPath) as! OffersListTableViewCell
                    cell.delegate = self
                    return cell
                }
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UnjoinedRideParticipantTableViewCell", for: indexPath) as! UnjoinedRideParticipantTableViewCell
                cell.initializeCell(oppositeUser: billViewModel.oppositeUsers[indexPath.row], rideType: billViewModel.rideType ?? "")
                return cell
            case 11:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillRefundDetailsTableViewCell", for: indexPath) as! BillRefundDetailsTableViewCell
                cell.initializeRefundDetails(refundRequest: billViewModel.rideBillingDetails?.last?.refundRequest, delegate: self)
                return cell
            default:
                break
            }
        }else{
            switch indexPath.section {
            case 0:

                var rideDate = billViewModel.rideBillingDetails?.first?.startTimeMs
                if let rideId = billViewModel.rideId,let ride = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: rideId){
                    rideDate = Int(ride.startTime)
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderCardTableViewCell", for: indexPath) as! BillHeaderCardTableViewCell
                cell.initializeHeaderView(rideType: billViewModel.rideType ?? "", rideDate: Double(rideDate ?? 0), seats: String((billViewModel.rideBillingDetails?.count ?? 0) - 1), isFromClosedRidesOrTransaction: billViewModel.isFromClosedRidesOrTransaction, isTaxiShareRide: billViewModel.isTaxiRide(), isCancelRide: false, isOutStationTaxi: false, delegate: self, rideTackerName: billViewModel.rideBillingDetails?.first?.fromUserName)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BillRideTakersTableViewCell", for: indexPath) as! BillRideTakersTableViewCell
                cell.riderWalletButton.setTitleColor(UIColor.black, for: .normal)
                cell.initializeRiderRidePassengers(viewModel: billViewModel,delegate: self)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CarpoolInvoiceDetailsTableViewCell", for: indexPath) as! CarpoolInvoiceDetailsTableViewCell
                cell.initialiseData(rideBillingDetails: billViewModel.rideBillingDetails?[indexPath.row], companyName: billViewModel.companyname, verificationProfile: billViewModel.verifiedImage, userDetailsTableViewCellDelegate: self, invoiceIndex: indexPath.row, invoiceDropDownData: billViewModel.invoiceDropDownData){ ( result, invoiceDropDownData)  in
                    if result {
                        self.billViewModel.invoiceDropDownData = invoiceDropDownData
                        self.tableView.reloadData()
                    }
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "JobPromotionTableViewCell", for: indexPath) as! JobPromotionTableViewCell
                cell.tag = 2
                cell.setupUI(jobPromotionData: billViewModel.jobPromotionData, screenName: ImpressionAudit.TripReport)
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewRouteFoundTableViewCell", for: indexPath) as! NewRouteFoundTableViewCell
                if let riderRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: billViewModel.currentUserRideId ?? 0) {
                    cell.initialiseData(newRoute: billViewModel.rideRoute, riderRide: riderRide) { (action) in
                        if action == Strings.success {
                            self.tableView.reloadData()
                        }
                    }
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CO2TableViewCell", for: indexPath) as! CO2TableViewCell
                cell.UpdateUI(rideContribution: billViewModel.rideContribution)
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatRecurringRideTableViewCell", for: indexPath) as! RepeatRecurringRideTableViewCell
                cell.initializeRecurringRideView(rideType: billViewModel.rideType, currentUserRideId: billViewModel.currentUserRideId, currentRide: nil)
                return cell
            case 7:
                switch SharedPreferenceHelper.getTripReportOptionShownIndex() {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AutoMatchTableViewCell", for: indexPath) as! AutoMatchTableViewCell
                    cell.seperatorView.isHidden = true
                    cell.setUpUI(rideType: billViewModel.rideType ?? Ride.PASSENGER_RIDE)
                    cell.delegate = self
                    return cell
                case 1:
                    if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                        let cell = tableView.dequeueReusableCell(withIdentifier: "BillReferralTableViewCell", for: indexPath) as! BillReferralTableViewCell
                        let info = String(format: Strings.earn_points_and_commission, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol])
                        cell.setUpView(title: String(format: Strings.hi_name, arguments: [UserDataCache.getInstance()!.getUserName()]), subTitle: info, delegate: self)
                        billViewModel.prepareOfferListAndUpdateUI()
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell", for: indexPath) as! reviewTableViewCell
                        cell.delegate = self
                        return cell
                    }
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell", for: indexPath) as! reviewTableViewCell
                    cell.delegate = self
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OffersListTableViewCell", for: indexPath) as! OffersListTableViewCell
                    cell.delegate = self
                    return cell
                }
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PassangerTableViewCell", for: indexPath) as! PassangerTableViewCell
                guard let rideBillingDetails = billViewModel.rideBillingDetails?[indexPath.row] else { return cell}
                cell.delegate = self
                cell.updatePassangerCellData(rideBillingDetails: rideBillingDetails, feedBackList: billViewModel.userFeedBackList, isfromCloseRide: billViewModel.isFromClosedRidesOrTransaction,index: indexPath.row,rideParticipants: billViewModel.rideParticipants)
                return cell
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UnjoinedRideParticipantTableViewCell", for: indexPath) as! UnjoinedRideParticipantTableViewCell
                cell.initializeCell(oppositeUser: billViewModel.oppositeUsers[indexPath.row], rideType: billViewModel.rideType ?? "")
                return cell
            default:
                break
            }
        }
        return UITableViewCell()
    }

}
//MARK: UITableViewDelegate
extension BillViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            UIView.animate(withDuration: 1.0, //1
//                delay: 0.0,
//                animations: ({ //6
//                cell.contentView.alpha = 0.8
//            }), completion: _ in {
//                cell.contentView.alpha = 1
//            })
//
//        }
//    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            if section == 7 && billViewModel.jobPromotionData.count > 0{
                return 10
            }else if section ==  5 && billViewModel.checkCurrentRideIsValidForRecurringRide(){
                return 1
            }else if section == 6 && !billViewModel.isFromClosedRidesOrTransaction{
                return 10
            }else if section == 8 && billViewModel.oppositeUsers.count > 0{
                return 10
            }else if section == 9 {
                switch SharedPreferenceHelper.getTripReportOptionShownIndex() {
                case 0:
                    return 10
                default :
                    if billViewModel.rideBillingDetails?.last?.refundRequest != nil {
                        return 10
                    }else{
                        return 0
                    }
                }
            }else{
                return 0
            }
        }else{
            if section == 2 && billViewModel.jobPromotionData.count > 0{
                return 10
            }else if section == 3 && billViewModel.isNewRouteFound(){
                return 10
            }else if section == 5 && billViewModel.checkCurrentRideIsValidForRecurringRide(){
                return 10
            }else if section == 6 && !billViewModel.isFromClosedRidesOrTransaction{
                return 10
            }else if section == 7 && billViewModel.rideBillingDetails?.count ?? 0 > 0 {
                return 10
            }else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if billViewModel.rideType == Ride.RIDER_RIDE && section == 8 && billViewModel.rideBillingDetails?.count ?? 0 > 0 {
            return 30
        }else{
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 5, width: 200, height: 20))
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        titleLabel.text = "RIDE TAKER DETAILS"
        headerView.addSubview(titleLabel)
        return headerView
    }

}

//MARK: getRouteMap
extension BillViewController: RideTravelledPathReceiver {
    func receiveRideTravelledPath(isFromViewMap: Bool, rideTravelledPath: String?) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug("receiveRideTravelledPath()")
        if isFromViewMap {
            if GoogleMapUtils.isPathTravelled(pathString: rideTravelledPath) == true{
                moveToTravelledPathView(rideTravelledPath: rideTravelledPath!)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.travelled_path_error)
            }
        } else if GoogleMapUtils.isPathTravelled(pathString: rideTravelledPath) == true {
            if let riderRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: billViewModel.currentUserRideId ?? 0), let rideTravelledPath = rideTravelledPath {
                let routeTravelledPathDetector = RouteTravelledPathDetector(riderRide: riderRide, travelledPath: rideTravelledPath, rideRouteReceiver: self)
                routeTravelledPathDetector.getTravelledRoute()
            }
        }

    }
    func moveToTravelledPathView(rideTravelledPath : String) {
        AppDelegate.getAppDelegate().log.debug("moveToTravelledPathView() \(rideTravelledPath)")
        let ridetravelledPathVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "RideTravelledPathViewController") as! RideTravelledPathViewController
        ridetravelledPathVC.travelledPath = rideTravelledPath
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: ridetravelledPathVC, animated: false, completion: nil)
    }
}

//MARK: UserDetailsTableViewCellDelegate
extension BillViewController: UserDetailsTableViewCellDelegate {
    func addOrRemoveFavoritePartner(userId: Double, status: Int) {
        addOrRemoveFavorite(userId: userId, status: status)
    }

    func viewMapPressed(data: Bool) {
        QuickRideProgressSpinner.startSpinner()
        // need to check for each case clearly
        let rideTravelledPath = RideTravelledPathTask(rideId: billViewModel.currentUserRideId ?? 0, targetViewController: self, isFromViewMap: true, listener: self)
        rideTravelledPath.getRideTravelledPath()
    }

    func showInsuranceView() {
        guard let rideBillingDetails = billViewModel.rideBillingDetails?.last else { return }
        let rideLevelInsuranceViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideLevelInsuranceViewController") as! RideLevelInsuranceViewController
        rideLevelInsuranceViewController.initializeDataBeforePresenting(policyUrl: rideBillingDetails.insurancePolicyUrl, passengerRideId: billViewModel.currentUserRideId, riderId: Double(rideBillingDetails.toUserId ?? 0) , rideId : billViewModel.rideId, isInsuranceClaimed: rideBillingDetails.insuranceClaimed ?? false, insurancePoints: nil,dismissHandler: {
            if rideBillingDetails.insurancePolicyUrl == nil{
                self.getPassengerBillAndUpdateView()
            }
        })
        self.navigationController?.view.addSubview(rideLevelInsuranceViewController.view)
        self.navigationController?.addChild(rideLevelInsuranceViewController)
    }

    private func getPassengerBillAndUpdateView() {

        let passengerRide = billViewModel.ride as? PassengerRide
        var id = 0.0
        if passengerRide?.taxiRideId == nil || passengerRide?.taxiRideId == 0.0 {
            id = billViewModel.rideId ?? 0.0
        } else {
            id = passengerRide?.taxiRideId ?? 0.0
        }

        QuickRideProgressSpinner.startSpinner()

        BillRestClient.getPassengerRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber: id), userId: QRSessionManager.getInstance()!.getUserId(), completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let rideBillingDetails = Mapper<RideBillingDetails>().map(JSONObject: responseObject!["resultData"])!
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                self.billViewModel.rideBillingDetails = rideBillingDetailslist
                self.tableView.reloadData()
                if self.billViewModel.rideBillingDetails?.last?.claimRefId != nil {
                    self.billViewModel.showInsuranceCard = true
                    self.tableView.reloadData()
                }
            }
        })
    }

    func viewFareDetailsPressed() {
        billViewModel.isExpanableBill = !billViewModel.isExpanableBill
        if billViewModel.rideType == Ride.RIDER_RIDE {
            if billViewModel.invoiceDropDownData[0] ?? false {
                billViewModel.invoiceDropDownData[0] = false
            }else{
                billViewModel.invoiceDropDownData[0] = true
            }
        }
        tableView.reloadData()
    }

    func paynowBtnPressed(rideBillingDetails: RideBillingDetails) {
        if billViewModel.rideType == Ride.RIDER_RIDE {
            paymentReminderAlert(rideBillingDetails: rideBillingDetails)
        }else{
            //MARK: PayNow for Passenger
            QuickRideProgressSpinner.startSpinner()
            guard let passengerRideId = billViewModel.rideBillingDetails?.first?.refId else {
                return
            }
            AccountRestClient.getOpenLinkedWalletTransactions(userId: (QRSessionManager.getInstance()?.getUserId())!, rideId: Double(passengerRideId), viewController: self, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                    self.billViewModel.pendingLinkedWalletTransactions = Mapper<LinkedWalletPendingTransaction>().mapArray(JSONObject: responseObject!["resultData"])!
                    self.updateOrderIdForPendingTransaction(txIds: self.getTransactionIdsString())
                }
            })
        }
    }

    private func getTransactionIdsString() -> String{
        var txnIds = [String]()
        billViewModel.totalAmount = 0
        for transaction in billViewModel.pendingLinkedWalletTransactions{
            txnIds.append(transaction.transactionId!)
            billViewModel.totalAmount += transaction.amount!
        }
        return txnIds.joined(separator: ",")
    }

    private func updateOrderIdForPendingTransaction(txIds : String?){
        billViewModel.orderId = billViewModel.accountUtils.generateOrderIDWithPrefix()
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateOrderIdForPendingLinkedWalletTransaction(userId: (QRSessionManager.getInstance()?.getUserId())!, txnIds: txIds! , orderId: billViewModel.orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.billViewModel.accountUtils.rechargeThroughPayTm(amount: self.billViewModel.totalAmount, delegate: self, custId: PendingUPILinkedWalletTransactionViewController.LINKED_WALLET_PENDING_TRANSACTIONS + QRSessionManager.getInstance()!.getUserId(), orderId: self.billViewModel.orderId!)

            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
}

//MARK: Paytm payment
extension BillViewController: PGTransactionDelegate {
    func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        billViewModel.accountUtils.removeController(controller: controller)
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateLinkedWalletOfUserAsSuccess(userId: (QRSessionManager.getInstance()?.getUserId())!, orderId: billViewModel.orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, amount: billViewModel.totalAmount, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(  Strings.pending_bills_cleared)
                self.billViewModel.rideBillingDetails?.first?.status = ""
                self.tableView.reloadData()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
        }
    }

    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        billViewModel.accountUtils.removeController(controller: controller)
        if let response = response {
            if let responseCodeObj = response["RESPCODE"] {
                let responseCodeStr = responseCodeObj as? String
                let responseCode = Int(responseCodeStr!)
                if (responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_1 || responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_2 || responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_3 ) {
                    AppDelegate.getAppDelegate().log.debug("Transaction was cancelled by user")
                    return
                }
            }
            MessageDisplay.displayAlert(title: Strings.recharge_failed,messageString: response["RESPMSG"] as? String ?? "", viewController: self, handler: nil)
        } else if ((error) != nil){
            MessageDisplay.displayAlert( title: Strings.recharge_failed,messageString: error.localizedDescription, viewController: self, handler: nil)
        }
        UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
    }

    func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        billViewModel.accountUtils.removeController(controller: controller)
    }
}

//MARK: PassangerTableViewCellDelegate
extension BillViewController: PassangerTableViewCellDelegate, AddFavPartnerReceiver,RemoveFavouritePartnerReciever {
    func ratingOrexpandPassengerCell(rating: Int, userId: Double,rideId: Double, status: Int) {
        self.tableView.reloadData()
        moveToCommentScreenForRideGiver(rating: rating,userId: userId, rideId: rideId)
    }

    func addOrRemoveFavorite(userId: Double, status: Int) {
        if status == 0{
            RemoveFavouritePartnerTask.removeFavouritePartner(phoneNumber: userId, viewController: self, receiver: self)
        }else{
            AddFavouritePartnerTask.addFavoritePartner(userId: (QRSessionManager.getInstance()?.getUserId())!, favouritePartnerUserIds: [userId], receiver: self, viewController: self)
        }
    }
    func showRideParticipentProfile(index: Int) {
        navigateToRideParticipentsProfile(index: index)
    }

    func refundOrInfoButtonPressed(rideBillingDetails: RideBillingDetails,status: Int) {
        if status == 0{
            paymentReminderAlert(rideBillingDetails: rideBillingDetails)
        }else{
            let optionMenuForPassenger = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let matchDetails = UIAlertAction(title: Strings.match_details, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.showRefundPopUp(rideBillingDetails: rideBillingDetails)
            })
            optionMenuForPassenger.addAction(matchDetails)

            let refundPopUP = UIAlertAction(title: Strings.refund, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handleRefundAction(rideBillingDetails: rideBillingDetails)
            })
            optionMenuForPassenger.addAction(refundPopUP)
            let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenuForPassenger.addAction(removeUIAlertAction)
            self.present(optionMenuForPassenger, animated: false, completion: {
                optionMenuForPassenger.view.tintColor = Colors.alertViewTintColor
            })
        }
    }

    private func showRefundPopUp(rideBillingDetails: RideBillingDetails) {
        if let rideParticipants = billViewModel.rideParticipants {
            var participantId = 0
            if billViewModel.rideType == Ride.PASSENGER_RIDE {
                participantId = rideBillingDetails.toUserId ?? 0
            }else {
                participantId = rideBillingDetails.fromUserId ?? 0
            }
            let rideParticipentDetails = RideViewUtils.getRideParticipantObjForParticipantId(participantId: Double(participantId), rideParticipants: rideParticipants)
            let passengerBillDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PassengerBillDetailViewController") as! PassengerBillDetailViewController

            passengerBillDetailViewController.initializeData(rideParticipant: rideParticipentDetails, rideBillingDetails: rideBillingDetails)
            self.navigationController?.view.addSubview(passengerBillDetailViewController.view!)
            self.navigationController?.addChild(passengerBillDetailViewController)
        }
    }

    func favPartnerAdded() {
        UIApplication.shared.keyWindow?.makeToast( Strings.added_to_favorite, duration: 2.0)
        tableView.reloadData()
    }
    func favPartnerAddingFailed(responseError: ResponseError) {
        MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self,handler: nil)
    }

    func favouritePartnerRemoved() {
        UIApplication.shared.keyWindow?.makeToast( Strings.remove_from_favorite, duration: 2.0)
        tableView.reloadData()
        QuickRideProgressSpinner.stopSpinner()
    }
}

extension BillViewController: saveFeedBackVCDelegate {
    func saveBtnPressed(feedBackData: UserFeedback) {
        if billViewModel.rideType == Ride.RIDER_RIDE {
            if !billViewModel.userFeedBackList.isEmpty{
                var isFeedBackDataExisted = false
                for feedBacks in billViewModel.userFeedBackList{
                    if feedBacks.feedbacktophonenumber == feedBackData.feedbacktophonenumber {
                        feedBacks.rating = feedBackData.rating
                        isFeedBackDataExisted = true
                    }
                }
                if !isFeedBackDataExisted {
                    billViewModel.userFeedBackList.append(feedBackData)
                }
            } else {
                billViewModel.userFeedBackList.append(feedBackData)
            }
        } else {
            billViewModel.rating = 0
            billViewModel.userFeedBackList.append(feedBackData)
        }
        tableView.reloadData()
    }
}
//MARK: Automatch
extension BillViewController: AutoMatchTableViewCellDelegate,SaveRidePreferencesReceiver {
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        tableView.reloadData()
    }

    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }

    func updateAndSaveAutoMatchPreference(status: Bool,preference: RidePreferences) {
        preference.autoConfirmEnabled = status
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: preference, viewController: self, receiver: self).saveRidePreferences()
    }

    func autoMatchSettingTapped() {
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences ?? RidePreferences()
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: ridePreference)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideAutoConfirmationSettingViewController, animated: false)
          }
}

//MARK: OFFERList
extension BillViewController: OffersListTableViewCellDelegate {
    func moveToOfferDetails(offerData: Offer) {
        if let offerLinkURL = offerData.linkUrl {
            let queryItems = URLQueryItem(name: "&isMobile", value: "true")
            let userId = QRSessionManager.getInstance()?.getUserId()
            var urlcomps = URLComponents(string: offerLinkURL)
            var existingQueryItems = urlcomps?.queryItems ?? []
            if !existingQueryItems.isEmpty {
                existingQueryItems.append(queryItems)
            }else {
                existingQueryItems = [queryItems]
            }
            urlcomps?.queryItems = existingQueryItems
            if urlcomps?.url != nil{
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.initializeDataBeforePresenting(titleString: Strings.offers, url: urlcomps!.url!, actionComplitionHandler: nil)
                self.navigationController?.pushViewController(webViewController, animated: false)
                UserRestClient.saveOfferStatus(userId: userId, offerId: offerData.id, viewController: self, handler: { (responseObject, error) in})
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
}


//MARK: Review
extension BillViewController: reviewTableViewCellDelegate,MFMailComposeViewControllerDelegate {
    func haveAconcernTapped() {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: Strings.sub_for_supportmail_from , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }

    func rateUsClicked() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            OpenAppStore()
        }

    }
    private func OpenAppStore() {
        let url = NSURL(string: AppConfiguration.application_link)
        if url == nil || !UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_launch_app_store)
        }else{
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }

}

extension BillViewController: AppStoreRatingViewControllerDelegate {
    func rateUsInAppStoreClicked() {
        rateUsClicked()
    }
    func supportEmailClicked() {
        haveAconcernTapped()
    }
}


//MARK: BillHeaderCardTableViewCellDelegate
extension BillViewController: BillHeaderCardTableViewCellDelegate{
    func backButtonTapped(){
        backButtonClicked()
    }
    private func backButtonClicked(){
        if let rating = billViewModel.rating,rating != 0{
            guard let rideParticipent = billViewModel.rideParticipants else { return }
            billViewModel.saveUserFeedBackDetails(riderDetails: rideParticipent[0],rating: billViewModel.rating ?? 0, vc: self)
        }
        if SharedPreferenceHelper.getTripReportOptionShownIndex() == 3 {
            billViewModel.setOfferIndexShown()
        }
        billViewModel.setTripReportOptionData()
        if billViewModel.isFromClosedRidesOrTransaction {
            self.navigationController?.popViewController(animated: false)
        }else{
            RideManagementUtils.moveToRideCreationScreen(viewController: self)
        }
    }

    func menuButtonTapped(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendByEmailOption = UIAlertAction(title: Strings.sendmail, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sendInvoice()
        })
        optionMenu.addAction(sendByEmailOption)
        if billViewModel.rideType == Ride.PASSENGER_RIDE{
            if billViewModel.taxiShareInfoForInvoice == nil {
                let refundAction = UIAlertAction(title: Strings.refund_request, style: UIAlertAction.Style.default) { (UIAlertAction) in
                    self.handleRefundAction(rideBillingDetails: nil)
                }
                optionMenu.addAction(refundAction)
            }
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }

}

//MARK: ReferralTableViewCellDelegate
extension BillViewController: ReferralTableViewCellDelegate{
    func referNowButtonpressed() {
        AppDelegate.getAppDelegate().log.debug("referThroughThroughWhatsApp()")
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }

        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                let referralURL = String(format: Strings.share_and_earn_msg, arguments: [(UserDataCache.getInstance()?.getReferralCode() ?? ""),url,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
                let urlStringEncoded = StringUtils.encodeUrlString(urlString: referralURL)
                let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded)")
                if UIApplication.shared.canOpenURL(url! as URL) {
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }else{
                    MessageDisplay.displayAlert(messageString: Strings.can_not_find_whatsup, viewController: self,handler: nil)
                }
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }

    func howItWorksPressed() {
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HowItWorkPopUpForShareAndEarnViewController") as! HowItWorkPopUpForShareAndEarnViewController
        showTermsAndConditionsViewController.initializeView(shareAndEarnOffer: billViewModel.shareAndEarnOffers[0])
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }

    func shareButtonPressed() {
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }

    private func shareReferralContext(urlString : String) {
        let message = String(format: Strings.share_and_earn_msg, arguments: [UserDataCache.getInstance()?.getReferralCode() ?? "",urlString,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
        let activityItem: [AnyObject] = [message as AnyObject]
        let vc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            vc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        vc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
}
//MARK: BillRatingTableViewCellDelegate
extension BillViewController: BillRatingTableViewCellDelegate{
    func moveToRatingScreen(rating: Int) {
        if !billViewModel.userFeedBackList.isEmpty{
            billViewModel.userFeedBackList[0].rating = Float(rating)
            navigateToUserFeedback(feedBackDetails: billViewModel.userFeedBackList[0], status: 0)
        }else{
            guard let riderDetails = billViewModel.rideParticipants else{ return }
            let userFeedbackDetails = UserFeedback(rideid: billViewModel.rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(riderDetails[0].userId), rating: Float(rating), extrainfo: "", feebBackToName: riderDetails[0].name ?? "",feebBackToImageURI : riderDetails[0].imageURI ?? "",feedBackToUserGender : riderDetails[0].gender ?? "", feedBackCommentIds: nil)
            navigateToUserFeedback(feedBackDetails: userFeedbackDetails, status: 0)
        }
    }

    func ratingButtonTapped(rating: Int){
        billViewModel.rating = rating
        tableView.reloadData()
    }
}

//MARK: BillInsurenceViewTableViewCellDelegate
extension BillViewController: BillInsurenceViewTableViewCellDelegate{
    func insuranceClaimedBtnTapped(){
        showInsuranceView()
    }
}
extension BillViewController: BillRefundDetailsTableViewCellDelegate{
    func clickedOnSupportMail() {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: "" , toRecipients: [AppConfiguration.support_email],ccRecipients: [],mailBody: "")
    }
}
extension BillViewController: RefundRequestDelegate{
    func refundRequestSuccessHandler() {
        tableView.reloadData()
    }
}
extension BillViewController: GetUnjoinedMembersFromThisRide{
    func preparedUnjoinedMembers() {
        self.tableView.reloadData()
    }
}
extension BillViewController: updateRatingDelegate {
    func data(rating: Double) {
        billViewModel.ratingForTaxiPool = rating
        self.tableView.reloadData()
    }
}
extension BillViewController: TravelledRideRouteReceiver {
    func receiveTravelledRideRoute(newRoute: RideRoute?) {
        billViewModel.rideRoute = newRoute
        tableView.reloadData()
    }

}
extension BillViewController: JobPromotionDataDelegate{
    func jobPromotionalDataReceived(){
        tableView.reloadData()
    }
}
