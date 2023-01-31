//
//  BillViewModel.swift
//  Quickride
//
//  Created by Ashutos on 28/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit

protocol GetUnjoinedMembersFromThisRide{
    func preparedUnjoinedMembers()
}
protocol RefundRequestDelegate {
    func refundRequestSuccessHandler()
}
protocol JobPromotionDataDelegate {
    func jobPromotionalDataReceived()
}

class BillViewModel {
    var rideBillingDetails: [RideBillingDetails]?
    var rideContribution: RideContribution?
    var rideParticipants : [RideParticipant]?
    var isExpanableBill = false
    var isCo2Expandable = false
    var rideId : Double?
    var isFromClosedRidesOrTransaction = false
    var currentUserRideId : Double?
    var rideType : String?
    var orderId : String?
    var totalAmount = 0.0
    var accountUtils = AccountUtils()
    var pendingLinkedWalletTransactions = [LinkedWalletPendingTransaction]()
    var txIds : String?
    var userFeedBackList = [UserFeedback]()
    var rating: Int?
    var feedbackPendingUserIDS  = [Double]()
    var clickedOffer: Offer?
    var ride: Ride?
    static let DAYS_AFTER_LIKE_POPUP_SHOULD_SHOW = 24*60*30
    var shareAndEarnOffers = [ShareAndEarnOffer]()
    var rewardsTermsAndConditions = [String : [String]]()
    var showInsuranceCard = false
    var taxiShareInfoForInvoice: TaxiShareInfoForInvoice?
    var isFeedbackLoaded = false
    var isFromPastTranction = false
    var verifiedImage = UIImage()
    var companyname = ""
    var invoiceDropDownData = [Int : Bool]()
    
    //UnjonedUsers
    var rideCancellationReports = [RideCancellationReport]()
    var invoices = [Invoice]()
    var userBasicInfos = [UserBasicInfo]()
    var oppositeUsers = [OppositeUser]()
    var compensetionNotApplied = false
    var isFeedBackAlreadyGivenForTaxiPool = false
    var ratingForTaxiPool = 0.0
    var feedBackForTaxiPool = ""
    var rideRoute: RideRoute?
    var jobPromotionData = [JobPromotionData]()
    
    func InitialiseInvoiceDropDownData() {
        if let count = rideBillingDetails?.count, count > 0{
            for index  in 0 ..< count { 
                invoiceDropDownData[index] = false
            }
        }
    }
    
    func isNewRouteFound() -> Bool {
        let riderRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: currentUserRideId ?? 0)
        if riderRide == nil || rideRoute == nil || rideRoute?.overviewPolyline == nil{
            return false
        }
        if let userPreferredRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: riderRide!.startLatitude, startLongitude: riderRide!.startLongitude, endLatitude: riderRide!.endLatitude ?? 0, endLongitude: riderRide!.endLongitude ?? 0), let overviewPolyline = userPreferredRoute.rideRoute?.overviewPolyline, overviewPolyline.elementsEqual(rideRoute!.overviewPolyline!) {
            return false
        }
        return true
    }
    
    func isTaxiRide() -> Bool {
        if ((ride as? PassengerRide)?.taxiRideId == nil || (ride as? PassengerRide)?.taxiRideId == 0.0) && !isFromPastTranction {
            return false
        } else {
            return true
        }
    }
    
    func isFromOutStation() -> Bool {
        if let taxiShareInfoForInvoice = taxiShareInfoForInvoice, taxiShareInfoForInvoice.tripType == Strings.out_station{
            return true
        }else{
            return false
        }
    }
    
    func getPassengerRide() {
        if rideType == Ride.PASSENGER_RIDE{
        ride = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: currentUserRideId ?? 0)
        }
    }
    
    func isTaxiIDFromTransction() {
        guard let rideBillingDetails = rideBillingDetails, !rideBillingDetails.isEmpty else { return }
        if (rideBillingDetails.last?.toUserId ?? 0) > 20 && (rideBillingDetails.last?.toUserId ?? 0) < 40 {
            isFromPastTranction = true
        }else {
            isFromPastTranction = false
        }
    }
    
    func checkAndDisplayUserFeedBack(vc:UIViewController, completionHandler: @escaping(_ result: Bool)->()) {
        var rideId = 0.0
        if String(rideBillingDetails?.last?.toUserId ?? 0) != QRSessionManager.sharedInstance?.getUserId() {
            rideId = Double(rideBillingDetails?.last?.refId ?? "") ?? 0
        } else {
            rideId = Double(rideBillingDetails?.last?.sourceRefId ?? "") ?? 0
        }
        UserRestClient.getUserFeedbacks(feedbackBy: Double(QRSessionManager.getInstance()!.getUserId())!, rideId: rideId , viewContrller: vc, responseHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let feedBackDetailsOfUsers = Mapper<UserFeedback>().mapArray(JSONObject:responseObject!["resultData"])!
                self.userFeedBackList = feedBackDetailsOfUsers
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        })
    }
    
    func getTaxiShareRideForTaxiPool(completionHandler: @escaping(_ result: Bool)->()) {
        let passengerRide = ride as? PassengerRide
        var taxiRideID = 0.0
        if isFromPastTranction {
            taxiRideID = Double(rideBillingDetails?.first?.refId ?? "" ) ?? 0
        } else {
            taxiRideID = passengerRide?.taxiRideId ?? 0.0
        }
        if taxiRideID == 0.0 { return }
        TaxiPoolRestClient.getTaxiShareRide(id: taxiRideID) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.taxiShareInfoForInvoice = Mapper<TaxiShareInfoForInvoice>().map(JSONObject: responseObject!["resultData"])
                completionHandler(true)
            }
        }
    }
    
    //MARK:FeedBackData
    func getFeedBackData(completionHandler: @escaping(_ result: Bool)->()) {
        let passengerRide = ride as? PassengerRide
        var taxiRideID = 0.0
        if isFromPastTranction {
            taxiRideID = Double(rideBillingDetails?.first?.refId ?? "" ) ?? 0
        } else {
            taxiRideID = passengerRide?.taxiRideId ?? 0.0
        }
        if taxiRideID == 0.0 { return }
        TaxiPoolRestClient.getTaxiPoolRating(taxiRideId: taxiRideID) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let response = responseObject!["resultData"] as! [String: Any]
                if response["rating"] != nil  {
                    if response["rating"] as? Double != 0.0 {
                        self.ratingForTaxiPool = response["rating"] as? Double ?? 0.0
                        self.feedBackForTaxiPool = response["feedBack"] as? String ?? ""
                        self.isFeedBackAlreadyGivenForTaxiPool = true
                    }
                }
                completionHandler(true)
            }
        }
    }
    
    func getTaxiRideId() -> Double {
        if let passengerRide = ride as? PassengerRide {
            if isFromPastTranction {
               return Double(rideBillingDetails?.first?.refId ?? "" ) ?? 0
            } else {
                return passengerRide.taxiRideId ?? 0.0
            }
        } else {
            return 0.0
        }
    }
    
    //MARK: SendInvoice
    func sendInvoice(vc: UIViewController) {
        let userProfile = UserDataCache.getInstance()!.userProfile
        var toastMsg : String?
        if (userProfile!.emailForCommunication != nil && userProfile!.emailForCommunication!.isEmpty == false) {
            toastMsg = String(format: Strings.invoice_sent_to_communication_mail, userProfile!.emailForCommunication!)
        }else{
            toastMsg = String(format: Strings.invoice_sent_to_communication_mail, userProfile!.email!)
        }
        if rideType == Ride.RIDER_RIDE {
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.sendRiderTripReportMailForRide(rideId: Double(rideBillingDetails?.last?.sourceRefId ?? "" ) ?? 0, actualEndTime: DateUtils.getNSDateFromTimeStamp(timeStamp: Double(rideBillingDetails?.last?.actualEndTimeMs ?? 0)),startTime: DateUtils.getNSDateFromTimeStamp(timeStamp: Double(rideBillingDetails?.last?.startTimeMs ?? 0))!,fromLocation: rideBillingDetails?.first?.startLocation ?? "", toLocation: rideBillingDetails?.first?.endLocation ?? "", riderId: Double(rideBillingDetails?.first?.sourceRefId ?? "") ?? 0, viewContrller: vc, responseHandler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    UIApplication.shared.keyWindow?.makeToast( toastMsg!)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: vc, handler: nil)
                }
            })
        } else {
            if currentUserRideId == nil{
                UIApplication.shared.keyWindow?.makeToast( "Insufficient data,Please try later")
                return
            }
            if  let rideBillingDetails = rideBillingDetails, !rideBillingDetails.isEmpty,
                let riderRideId = rideBillingDetails.first?.sourceRefId, let riderRideIdDbl = Double(riderRideId),
                let passengerId = rideBillingDetails.first?.refId, let passengerIdDbl = Double(passengerId) {
                QuickRideProgressSpinner.startSpinner()
                UserRestClient.sendPassengerTripReportMailForRide(riderRideId: riderRideIdDbl, passengerRideId: passengerIdDbl, viewContrller: vc, responseHandler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        UIApplication.shared.keyWindow?.makeToast( toastMsg!)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: vc, handler: nil)
                    }
                })
            }
        }
    }
    
    func completeRefundAfterPointsSelction(points: String,vc: UIViewController,delegate: RefundRequestDelegate){
        if rideType == Ride.RIDER_RIDE{
            
            if let rideBillingDetails = rideBillingDetails,!rideBillingDetails.isEmpty,
               let rideId = rideBillingDetails.first?.sourceRefId, let rideIdDbl = Double(rideId),
               let invoiceId = rideBillingDetails.first?.rideInvoiceNo{
                QuickRideProgressSpinner.startSpinner()
                AccountRestClient.riderRefundToPassenger(accountTransactionId: nil, points: points, rideId: rideIdDbl, invoiceId: String(invoiceId), viewController: vc, completionHandler: { (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        UIApplication.shared.keyWindow?.makeToast( Strings.refund_successful)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: vc, handler: nil)
                    }
                })
            }
        } else {
            
            QuickRideProgressSpinner.startSpinner()
            refundRequestToRider(points: Double(points),reason: Strings.i_didnt_take_ride, remindAgain: false, viewController: nil) {
             delegate.refundRequestSuccessHandler()
         }
            
        }
    }
    
    func saveUserFeedBackDetails(riderDetails: RideParticipant,rating: Int,vc: UIViewController) {
        var userFeedback: UserFeedback?
        if userFeedBackList.isEmpty{
            userFeedback = UserFeedback(rideid: rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(riderDetails.userId), rating: Float(rating), extrainfo: "", feebBackToName: riderDetails.name ?? "",feebBackToImageURI : riderDetails.imageURI ?? "",feedBackToUserGender : riderDetails.gender ?? "", feedBackCommentIds: nil)
        } else {
            for data in userFeedBackList{
                if data.feedbacktophonenumber == riderDetails.userId{
                    userFeedback = data
                    userFeedback?.rating = Float(rating)
                }
            }
            userFeedback = UserFeedback(rideid: rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(riderDetails.userId), rating: Float(rating), extrainfo: "", feebBackToName: riderDetails.name ?? "",feebBackToImageURI : riderDetails.imageURI ?? "",feedBackToUserGender : riderDetails.gender ?? "", feedBackCommentIds: nil)
        }
        UserRestClient.saveUserDirectFeedback(targetViewController: vc, body: userFeedback!.getParams(), completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: vc, handler: nil)
            }
        })
    }
    
    func updateAutoConfirmData(rideParticipant: RideParticipant,vc: UIViewController) {
        let AutoData = AutoConfirmPartner.init(enableAutoConfirm: AutoConfirmPartner.AUTO_CONFIRM_STATUS_ENABLE, userId: Double(QRSessionManager.getInstance()!.getUserId()) ?? 0, partnerId: String(rideParticipant.userId), partnerName: rideParticipant.name ?? "", partnerGender: rideParticipant.gender ?? "", imageURI: rideParticipant.imageURI ?? "", partnerType: Contact.RIDE_PARTNER)
        let AutoDataArray = [AutoData]
        guard let autoData = try? JSONSerialization.data(withJSONObject: AutoDataArray.toJSON(), options: []) else { return }
        let autoDataString = String(data: autoData, encoding: String.Encoding.utf8)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updateAutoConfirmPartnerStatus(userId: Double(QRSessionManager.getInstance()!.getUserId()) ?? 0, partners: autoDataString ?? "", viewController: vc,completionHandler: { responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                for ridePartner in UserDataCache.getInstance()?.getRidePartnerContacts() ?? []{
                    if ridePartner.contactId! == StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId){
                        ridePartner.autoConfirmStatus =  Contact.AUTOCONFIRM_FAVOURITE
                        UserDataCache.getInstance()?.storeRidePartnerContact(contact: ridePartner)
                    }
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: vc, handler: nil)
            }
        })
    }
    func setTripReportOptionData() {
        if SharedPreferenceHelper.getTripReportOptionShownIndex() == 3 {
          SharedPreferenceHelper.setTripReportOptionShownIndex(index: 0)
        }else{
            SharedPreferenceHelper.setTripReportOptionShownIndex(index: SharedPreferenceHelper.getTripReportOptionShownIndex()+1)
        }
    }
    
    func setOfferIndexShown() {
        guard let offersList =  ConfigurationCache.getInstance()?.offersList else { return }
        let offersData = filterOffers(offerList : offersList)
        
        if SharedPreferenceHelper.getTripReportOfferShownIndex() == ((offersData?.count ?? 1)-1) {
            SharedPreferenceHelper.setTripReportOfferShownIndex(index: 0)
        }else{
            SharedPreferenceHelper.setTripReportOfferShownIndex(index: SharedPreferenceHelper.getTripReportOfferShownIndex()+1)
        }
    }
    
    func filterOffers(offerList: [Offer]) -> [Offer]?{
        var filterList = [Offer]()
        for offer in offerList{
            if (offer.displayType == Strings.displaytype_both || offer.displayType == Strings.displaytype_offerscreen)  && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false
            {
                filterList.append(offer)
            }
        }
        
        if filterList.isEmpty {
            return nil
        }
        var finalOfferList = [Offer]()
        for offer in filterList {
            let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
            if userProfile != nil && (UserProfile.PREFERRED_ROLE_PASSENGER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == userProfile!.roleAtSignup && offer.targetRole == Strings.targetrole_rider) {
                finalOfferList.append(offer)
            } else if offer.targetRole == Strings.targetrole_both {
                finalOfferList.append(offer)
            }
        }
        return finalOfferList
    }
    
     func setTripReportOptionsWithValidations() {
        switch SharedPreferenceHelper.getTripReportOptionShownIndex() {
        case 0:
           let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
            if let preference = ridePreference {
                if preference.autoConfirmEnabled {
                    SharedPreferenceHelper.setTripReportOptionShownIndex(index: 1)
                    setTripReportOptionsWithValidations()
                }
                return
            }
            return
        case 1:
            if let _ =  SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(), let _ = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification() {
                return
            }else{
                 SharedPreferenceHelper.setTripReportOptionShownIndex(index: 2)
                return
            }
        case 3:
            if let offersList =  ConfigurationCache.getInstance()?.offersList , let offerData = filterOffers(offerList : offersList) ,
                SharedPreferenceHelper.getTripReportOfferShownIndex() <= offerData.count-1, (offerData[SharedPreferenceHelper.getTripReportOfferShownIndex()].offerScreenImageUri != nil) {
                    return
            }else{
               SharedPreferenceHelper.setTripReportOfferShownIndex(index: 0)
               SharedPreferenceHelper.setTripReportOptionShownIndex(index: 0)
               setTripReportOptionsWithValidations()
            }
        default:
            return
        }
    }
    
    func checkCurrentRideIsValidForRecurringRide() -> Bool {
        var ride: Ride?
        if rideType == Ride.RIDER_RIDE{
            ride = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: currentUserRideId ?? 0)
        } else if rideType == Ride.PASSENGER_RIDE{
            ride = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: currentUserRideId ?? 0)
        }
        guard let currentRide = ride else { return false }
        let regularRide : RegularRide?
        if ride!.rideType == Ride.RIDER_RIDE {
            regularRide = RegularRiderRide(ride: currentRide)
        }else {
            regularRide = RegularPassengerRide(ride: currentRide)
        }
        if RecurringRideUtils().isValidDistance(ride: ride!){
            return false
        }else if MyRegularRidesCache.getInstance().checkForDuplicate(regularRide: regularRide!){
            return false
        }else{
            return true
        }
    }
    func prepareOfferListAndUpdateUI() {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        ReferAndRewardsTermsAndConditionDetailsParser.getInstance().getRewardsTermsAndConditionElement{ (rewardsTermsAndConditions) in
            for termsAndCondtion in rewardsTermsAndConditions!.referAndRewardsTermsAndConditions!{
                self.rewardsTermsAndConditions.updateValue(termsAndCondtion.terms_and_conditions!, forKey: termsAndCondtion.type!)
            }
            if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                self.shareAndEarnOffers.append(ShareAndEarnOffer(type: RewardsTermsAndConditions.REFER_FRIENDS, title:String(format: Strings.refer_and_earn_title, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), rewardDetailIamge: UIImage(named: "refer_earn_image")!, backGroundColor: [UIColor(netHex: 0xF50364)], buttonText: Strings.refer_now, termsAndCondition: self.rewardsTermsAndConditions[RewardsTermsAndConditions.REFER_FRIENDS]!, stepOneTitle: String(format: Strings.refer_earn_title1, arguments: [String(pointsAfterVerification)]), stepTwoTitle: String(format: Strings.refer_earn_title2, arguments: [String(pointsAfterFirstRide)]), stepThreeTitle: String(format: Strings.refer_earn_title3, arguments: [String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), stepOneText: Strings.refer_earn_desc1, stepThreeText: Strings.refer_earn_desc3, referralCode: true, sampleEmail: false,stepTwoText: Strings.refer_earn_desc2))
            }
        }
    }
    //MARK: UNjoined Ride takers and Passengers
    func getUnjonedUsersFromThisRide(delegate: GetUnjoinedMembersFromThisRide){
        BillRestClient.getRideCancellationReport(userId: UserDataCache.getInstance()?.userId ?? "", rideId: currentUserRideId ?? 0, rideType: rideType ?? "", targetViewController: nil, completionHandler:  {(responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.rideCancellationReports = Mapper<RideCancellationReport>().mapArray(JSONObject: responseObject!["resultData"]) ?? [RideCancellationReport]()
                if !self.rideCancellationReports.isEmpty{
                    self.getInvoiceForCancelledRide(delegate: delegate)
                    self.getUserBasicInfo(delegate: delegate)
                }
            }
        })
    }
    
    private func getInvoiceForCancelledRide(delegate: GetUnjoinedMembersFromThisRide){
        BillRestClient.getRideCancellationInvoice(userId: UserDataCache.getInstance()?.userId ?? "", rideId: currentUserRideId ?? 0, rideType: rideType ?? "", completionHandler: {(responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.invoices = Mapper<Invoice>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Invoice]()
                self.checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: delegate)
            }
        })
    }
    
    private func getInvoiceForCancelReport(passengerRideId: Int) -> Invoice?{
        for invoice in invoices{
            if Int(invoice.refId ?? "") == passengerRideId{
                return invoice
            }
        }
        return nil
    }
    private func getUserBasicInfo(delegate: GetUnjoinedMembersFromThisRide){
        var reports = 0
        for report in rideCancellationReports{
            var userId = 0.0
            if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                userId = Double(report.cancelledFromUserId ?? 0)
            }else{
                userId = Double(report.cancelledUserId ?? 0)
            }
            UserRestClient.getUserBasicInfo(userId: userId, viewController: nil) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    if let userBasicInfo = Mapper<UserBasicInfo>().map(JSONObject: responseObject!["resultData"]){
                        self.userBasicInfos.append(userBasicInfo)
                        reports += 1
                        if reports == self.rideCancellationReports.count{
                            self.checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: delegate)
                        }
                    }
                }
            }
        }
    }
    
    private func checkCancellationFeesOnCurrentUserOrOppositeUser(delegate: GetUnjoinedMembersFromThisRide){
        oppositeUsers.removeAll()
        for report in rideCancellationReports{
            var userId = 0.0
            if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                userId = Double(report.cancelledFromUserId ?? 0)
            }else{
                userId = Double(report.cancelledUserId ?? 0)
            }
            var user: UserBasicInfo?
            for userBasicInfo in userBasicInfos{
                if userBasicInfo.userId == userId{
                    user = userBasicInfo
                }
            }
            var cancellationFeeType: String?
            var color = UIColor.black.withAlphaComponent(0.6)
            if rideType == Ride.RIDER_RIDE{
                if report.waveOff == RideCancellationReport.WAVEOFF_BY_SYSTEM || report.waveOff == Ride.PASSENGER_RIDE || report.waveOff == Ride.RIDER_RIDE{
                    cancellationFeeType = Strings.waived_off
                    color = UIColor(netHex: 0x00b557)
                }else if report.compensationCanBeApplied == true && report.waveOff == RideCancellationReport.WAVEOFF_BY_FREE_CANCELLATIONS{
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = Strings.lost_free_cancel
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }
                        }else{
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }
                        }
                    }
                }else if report.compensationCanBeApplied && report.waveOff == nil{
                    let invoice = getInvoiceForCancelReport(passengerRideId: report.passengerRideId ?? 0)
                    var amount = ""
                    if invoice != nil{
                        if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.amount)
                        }else{
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.netAmountPaid)
                        }
                    }
                    
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = String(format: Strings.charged_points, arguments: [amount])
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        cancellationFeeType = String(format: Strings.got_points, arguments: [amount])
                    }
                }else{
                    compensetionNotApplied = true
                }
                if !compensetionNotApplied{
                   oppositeUsers.append(OppositeUser(name: user?.name, imageUrl: user?.imageURI, gender: user?.gender, type: "Unjoined", feeType: cancellationFeeType, color: color))
                }
            }else{
                if report.waveOff == RideCancellationReport.WAVEOFF_BY_SYSTEM{
                    cancellationFeeType = Strings.waived_off
                    color = UIColor(netHex: 0x00b557)
                }else if report.waveOff == Ride.PASSENGER_RIDE || report.waveOff == Ride.RIDER_RIDE{
                    cancellationFeeType = String(format: Strings.waived_off_opposite, arguments: [(user?.name ?? "")])
                    color = UIColor(netHex: 0x00b557)
                }else if report.compensationCanBeApplied == true && report.waveOff == RideCancellationReport.WAVEOFF_BY_FREE_CANCELLATIONS{
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = Strings.lost_free_cancel
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        if report.cancelledUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }
                        }else{
                            if report.cancelledRideType == Ride.RIDER_RIDE{
                                cancellationFeeType = Strings.rt_lost_free_cancellation
                            }else{
                                cancellationFeeType = Strings.rg_lost_free_cancellation
                            }
                        }
                    }
                }else if report.compensationCanBeApplied && report.waveOff == nil{
                    let invoice = getInvoiceForCancelReport(passengerRideId: report.passengerRideId ?? 0)
                    var amount = ""
                    if invoice != nil{
                        if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.amount)
                        }else{
                            amount = StringUtils.getStringFromDouble(decimalNumber: invoice?.netAmountPaid)
                        }
                    }
                    
                    if report.compensationPaidUserId == Int(UserDataCache.getInstance()?.userId ?? ""){
                        cancellationFeeType = String(format: Strings.charged_points, arguments: [amount])
                        color = UIColor(netHex: 0xE20000)
                    }else{
                        cancellationFeeType = String(format: Strings.got_points, arguments: [amount])
                    }
                }else{
                    compensetionNotApplied = true
                }
                if !compensetionNotApplied{
                    oppositeUsers.append(OppositeUser(name: String(format: Strings.ride_cancelled_With, arguments: [(user?.name ?? "")]), imageUrl: user?.imageURI, gender: user?.gender, type: "Unjoined", feeType: cancellationFeeType, color: color))
                }
            }
        }
        delegate.preparedUnjoinedMembers()
    }
        
    func refundRequestToRider(points: Double?,reason: String,remindAgain: Bool,viewController: UIViewController?, handler : ()->Void){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.sendRefundRequestToRider(userId: UserDataCache.getInstance()!.currentUser!.phoneNumber,points: StringUtils.getStringFromDouble(decimalNumber: points), passengerRideId: currentUserRideId!, riderId: rideBillingDetails?[0].toUserId ?? 0, pickupAddress:  rideBillingDetails?[0].startLocation ,dropAddress: rideBillingDetails?[0].endLocation ,pickupTime: Double(rideBillingDetails?[0].startTimeMs ?? 0),viewController: viewController, remindAgain: remindAgain, reason: reason, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
              UIApplication.shared.keyWindow?.makeToast( Strings.refund_requested)
                let refundRequest = RefundRequest(refId: String(UserDataCache.getCurrentUserId()), sourceRefId: self.rideBillingDetails?[0].sourceRefId ?? "" , invoiceId: self.rideBillingDetails?[0].rideInvoiceNo ?? 0, fromUserId: Int(UserDataCache.getInstance()?.userId ?? "") ?? 0, fromUserName: "", toUserId: 0, reason: reason, points: Int(points ?? 0), requestTime: DateUtils.getCurrentTimeInMillis())
                self.rideBillingDetails?[0].refundRequest = refundRequest
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                
             ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
}
//MARK: Job Promotion Visibility
extension BillViewModel {
    func getJobPromotionAd(delegate: JobPromotionDataDelegate) {
        JobPromotionUtils.getJobPromotionDataBasedOnScreen(screenName: ImpressionAudit.TripReport) {(jobPromotionData) in
            self.jobPromotionData = jobPromotionData
            delegate.jobPromotionalDataReceived()
        }
    }
}
