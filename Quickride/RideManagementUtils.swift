//
//  RideManagementUtils.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 19/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
//import AVFoundation
import SimplZeroClick

protocol RideActionComplete{
    func rideActionCompleted(status : String)
    func rideActionFailed(status : String, error : ResponseError?)
}

class RideManagementUtils {
    
    static func completeRiderRide(riderRideId : Double, targetViewController : UIViewController?,rideActionCompletionDelegate : RideActionComplete?){
        AppDelegate.getAppDelegate().log.debug("completeRiderRide() \(riderRideId)")
        BillViewController.COMPLETED_RIDE_TYPE = Ride.RIDER_RIDE
        BillViewController.COMPLETED_RIDE_ID = riderRideId
        
        let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId)
        if (riderRide == nil) {
            if let closedRide = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: riderRideId), closedRide.status == Ride.RIDE_STATUS_COMPLETED {
                completeRide(riderRide: closedRide, targetViewController: targetViewController, rideActionCompletionDelegate: rideActionCompletionDelegate)
                return
            }
            targetViewController?.navigationController?.popViewController(animated: false)
            return
        }
        var params = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: riderRideId)
        QuickRideProgressSpinner.startSpinner()
        RideCompletionClient.putRiderCompleteTheRideWithBody(targetViewController: targetViewController, body: params, completionHandler:{ (responseObject, error) -> Void in
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                completeRide(riderRide: riderRide!, targetViewController: targetViewController, rideActionCompletionDelegate: rideActionCompletionDelegate)
                
            }else{
                QuickRideProgressSpinner.stopSpinner()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: targetViewController, handler: nil)
                return
            }
        })
    }
    
    private static func completeRide(riderRide: RiderRide, targetViewController: UIViewController?, rideActionCompletionDelegate: RideActionComplete?){
        let rideStatus : RideStatus = RideStatus(rideId: riderRide.rideId, userId: riderRide.userId, status: Ride.RIDE_STATUS_COMPLETED, rideType: Ride.RIDER_RIDE)
        ClearRideDataAsync().clearRideData(rideStatus: rideStatus)
        MyActiveRidesCache.singleCacheInstance?.updateRideStatus(newRideStatus: rideStatus)
        rideActionCompletionDelegate?.rideActionCompleted(status: Ride.RIDE_STATUS_COMPLETED)
        getRiderBill(riderRide: riderRide,targetViewController: targetViewController)
        SharedPreferenceHelper.storeShownAutoInviteUserId(rideId: riderRide.rideId, list: nil)
    }
    
    private static func getRiderBill(riderRide : RiderRide , targetViewController : UIViewController?){
        AppDelegate.getAppDelegate().log.debug("getRiderBill()")
        QuickRideProgressSpinner.startSpinner()
        
        BillRestClient.getRiderRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber:
                                                                                        riderRide.rideId), userId: String(describing: NSNumber(value:riderRide.userId))) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["resultData"] == nil{
                moveToRideCreationScreen(viewController: targetViewController)
                return
            }
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let rideBillingDetailslist = Mapper<RideBillingDetails>().mapArray(JSONObject: responseObject!["resultData"])!
                refreshUserCoupons()
                if rideBillingDetailslist == nil || rideBillingDetailslist.isEmpty {
                    moveToRideCompletionWithEmptySeatView(riderRide: riderRide)
                }else{
                    moveRiderBill( rideBillingDetails: rideBillingDetailslist, targetViewController: targetViewController)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: targetViewController, handler: nil)
                return
            }
        }
    }
    static func moveToRideCompletionWithEmptySeatView(riderRide: RiderRide) {
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.rideCompletionWithEmptySeatViewController) as! RideCompletionWithEmptySeatViewController
        viewController.initialiseData(riderRide: riderRide,isFromRideHistory: false)
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewController, animated: false)
    }
    
    static func moveToRideCreationScreen(viewController : UIViewController?){
        
        AppDelegate.getAppDelegate().log.debug("moveToRideCreationScreen()")
        ContainerTabBarViewController.fromPopRooController = true
        ContainerTabBarViewController.isRideCompleted = true
        if viewController != nil && viewController!.navigationController != nil{
            ContainerTabBarViewController.indexToSelect = 1
        viewController!.navigationController?.popToRootViewController(animated: false)
        }else{

            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
             ContainerTabBarViewController.fromPopRooController = true
              ContainerTabBarViewController.isRideCompleted = true
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: routeViewController, animated: false)
        }
    }
    
    private static func moveRiderBill(rideBillingDetails: [RideBillingDetails]?,  targetViewController:UIViewController?){
        AppDelegate.getAppDelegate().log.debug("moveRiderBill()")
            let BillVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        BillVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails,isFromClosedRidesOrTransaction: false,rideType: Ride.RIDER_RIDE,currentUserRideId: Double(rideBillingDetails?.last?.sourceRefId ?? "") ?? 0)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: BillVC, animated: false)
    }
    
    static func completePassengerRide( riderRideId : Double,  passengerRideId : Double, userId : Double, targetViewController : UIViewController?,rideCompletionActionDelegate: RideActionComplete? ){
        AppDelegate.getAppDelegate().log.debug("completePassengerRide() \(riderRideId) \(passengerRideId)  \(userId)")
        BillViewController.COMPLETED_RIDE_ID = passengerRideId
        BillViewController.COMPLETED_RIDE_TYPE = Ride.PASSENGER_RIDE
        var params : [String : String] = [String : String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        QuickRideProgressSpinner.startSpinner()
        RideCompletionClient.putPassengerCompleteTheRideWithBody(targetViewController: targetViewController, body: params) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: targetViewController, handler: nil)
            }else {
                SharedPreferenceHelper.storeShownAutoInviteUserId(rideId: passengerRideId, list: nil)
                let rideStatus : RideStatus = RideStatus(rideId: passengerRideId, userId: userId, status: Ride.RIDE_STATUS_COMPLETED, rideType: Ride.PASSENGER_RIDE,joinedRideId:riderRideId, joinedRideStatus: nil)
                MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
                ClearRideDataAsync().clearRideData(rideStatus: rideStatus)
                rideCompletionActionDelegate?.rideActionCompleted(status: Ride.RIDE_STATUS_COMPLETED)
                
                getPassengerBill(riderRideId: riderRideId, passengerRideId: passengerRideId, userId: userId, targetViewController: targetViewController, rideCompletionActionDelegate: rideCompletionActionDelegate)
            }
        }
    }
    
    static func getPassengerBill(riderRideId: Double, passengerRideId: Double, userId: Double, targetViewController: UIViewController?, rideCompletionActionDelegate: RideActionComplete?) {
        
        BillRestClient.getPassengerRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber: passengerRideId), userId: QRSessionManager.getInstance()!.getUserId(), completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: nil, handler: nil)
            }else {
                let rideBillingDetails = Mapper<RideBillingDetails>().map(JSONObject: responseObject!["resultData"])!
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                let billPassengerViewController  = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
                billPassengerViewController.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetailslist, isFromClosedRidesOrTransaction: false,rideType: Ride.PASSENGER_RIDE,currentUserRideId: passengerRideId)
                ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: billPassengerViewController, animated: false)
            }
        })
    }
    
    static func startRiderRide(rideId : Double , rideComplteAction : RideActionComplete?, viewController:UIViewController? ){
        AppDelegate.getAppDelegate().log.debug(" startRiderRide() \(rideId)")
        
        let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId)
        if (riderRide == nil) {
            if (viewController != nil) {
                MessageDisplay.displayAlert(messageString: Strings.ride_completed_or_cancelled_msg, viewController: viewController!,handler: nil)
            }
            return
        }
        else if (riderRide?.status == Ride.RIDE_STATUS_STARTED) {
            if (viewController != nil) {
                
                MessageDisplay.displayAlert(messageString: Strings.ride_started_msg, viewController: viewController!,handler: nil)
            }
            rideComplteAction?.rideActionCompleted(status: Ride.RIDE_STATUS_STARTED)
            return
        }
        
        let params = ["\(Ride.FLD_ID)":"\(NSNumber(value: rideId))",
            "\(Ride.FLD_STATUS)":Ride.RIDE_STATUS_STARTED] as Dictionary<String, String>
        QuickRideProgressSpinner.startSpinner()
        RideBeginClient.putRiderStartTheRideWithBody(targetViewController: nil, body: params, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if(responseObject != nil &&  responseObject!["result"] as! String == "SUCCESS"){
                if QRSessionManager.getInstance()?.getUserId() == nil || QRSessionManager.getInstance()?.getUserId().isEmpty == true{
                    return
                }
                let userId : Double = Double((QRSessionManager.getInstance()?.getUserId())!)!
                let rideStatus : RideStatus =  RideStatus(rideId: rideId, userId: userId, status: Ride.RIDE_STATUS_STARTED, rideType: Ride.RIDER_RIDE)
                MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus)
                LocationChangeListener.getInstance().pushCurrentLocationToTopic(rideId: rideId)
                NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_RIDER_RIDE,groupValue: String(rideId).components(separatedBy: ".")[0])
                
                if rideComplteAction == nil{
                    return
                }
                let notificationSettings = UserDataCache.getInstance()?.getLoggedInUserNotificationSettings()
                if notificationSettings != nil && notificationSettings!.playVoiceForNotifications == true{
//                    let speechSynthesizer = AVSpeechSynthesizer()
//                    let speechUtterance = AVSpeechUtterance(string: Strings.seat_belt_alert)
                    //speechUtterance.rate = 0.25
//                    speechSynthesizer.speak(speechUtterance)
                }
                
                rideComplteAction!.rideActionCompleted(status: Ride.RIDE_STATUS_STARTED)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
    
    static func startPassengerRide(passengerRideId : Double , riderRideId : Double,rideCompleteAction : RideActionComplete? ,viewController:UIViewController?){
        AppDelegate.getAppDelegate().log.debug(" startPassengerRide() \(passengerRideId) \(riderRideId)")
        let pssengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: passengerRideId)
        
        if (pssengerRide == nil) {
            if (viewController != nil) {
                MessageDisplay.displayAlert(messageString: Strings.ride_completed_or_cancelled_msg, viewController: viewController!,handler: nil)
            }
            return
        }
        else if (pssengerRide?.status == Ride.RIDE_STATUS_STARTED) {
            if (viewController != nil) {
                MessageDisplay.displayAlert(messageString: Strings.psgr_ride_started_msg, viewController: viewController!,handler: nil)
            }
            rideCompleteAction!.rideActionCompleted(status: Ride.RIDE_STATUS_STARTED)
            return
        }
        
        let params = ["\(Ride.FLD_ID)":"\(NSNumber(value: passengerRideId))",
            "\(Ride.FLD_RIDER_RIDE_ID)":"\(NSNumber(value: riderRideId))",
            "\(Ride.FLD_USERID)":"\((QRSessionManager.getInstance()?.getUserId())!)".components(separatedBy: ".")[0],
            "\(Ride.FLD_STATUS)":Ride.RIDE_STATUS_STARTED,"\(Ride.FLD_DEVICE)":"ios"] as Dictionary<String, String>
        QuickRideProgressSpinner.startSpinner()
        RideBeginClient.putPassengerCheckInTheRideWithBody(targetViewController: nil, body: params, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject == nil{
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: viewController, handler: nil)
            }else {
                
                if responseObject!["result"] as! String == "FAILURE"{
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    if responseError?.errorCode == RideValidationUtils.UPI_TRANSACTION_PENDING_ERROR{
                        QuickRideProgressSpinner.startSpinner()
                        AccountRestClient.getOpenLinkedWalletTransactions(userId: (QRSessionManager.getInstance()?.getUserId())!, rideId: passengerRideId, viewController: viewController, handler: { (responseObject, error) in
                            QuickRideProgressSpinner.stopSpinner()
                            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                                let pendingLinkedWalletTransactions = Mapper<LinkedWalletPendingTransaction>().mapArray(JSONObject: responseObject!["resultData"])
                                self.openCurrentRidePendingTransactionViewController(pendingLinkedWalletTransactions: pendingLinkedWalletTransactions!)
                                
                            }
                            
                        })
                    }else{
                        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: viewController)
                    }
                    
                }else{
                    let userId : Double = Double((QRSessionManager.getInstance()?.getUserId())!)!
                    let rideStatus : RideStatus =  RideStatus(rideId: passengerRideId, userId: userId, status: Ride.RIDE_STATUS_STARTED, rideType: Ride.PASSENGER_RIDE,joinedRideId: riderRideId,joinedRideStatus: nil)
                    MyActiveRidesCache.getRidesCacheInstance()?.updateRideStatus(newRideStatus: rideStatus);
                    
                    LocationChangeListener.getInstance().pushCurrentLocationToTopic(rideId: riderRideId)
                    NotificationStore.getInstance().removeOldNotificationOfSameGroupValue(groupName: UserNotification.NOT_GRP_PASSENGER_RIDE,groupValue: String(passengerRideId).components(separatedBy: ".")[0])
                    
                    if rideCompleteAction == nil{
                        return
                    }
                    rideCompleteAction?.rideActionCompleted(status: Ride.RIDE_STATUS_STARTED)
                }
                
                
            }
        })
    }
    
    static func checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: Bool, viewController: UIViewController?, handler: DialogDismissCompletionHandler?){
        AppDelegate.getAppDelegate().log.debug("checkAnyRideEtiquetteToDisplayAndNavigate()")

        if let jobURl = SharedPreferenceHelper.getQuickJobUrl(){
            QuickJobsURLHandler.showPerticularJobInQuickJobPortal(jobUrl: jobURl)
        }else if let url = SharedPreferenceHelper.getProductUrl(),let type = SharedPreferenceHelper.getProductUrlType(){
            QuickShareUrlHandler.showProductInQuickShare(productId: url, needType: type, viewController: viewController)
        }else if let rideId = SharedPreferenceHelper.getJoinMyRideRideId(),let riderId = SharedPreferenceHelper.getJoinMyRideRiderId(){
            JoinMyRidePassengerSideHandler().getComplateRiderRideThroughRideId(rideId: rideId, riderId: riderId, isFromSignUpFlow: true, viewController: viewController)
        }else{
            if isFromSignupFlow{
                NavigateToRespectivePage(oldViewController: viewController, handler: handler)
            }
            else{
                    getPendingRefundRequestsAndShow(viewController: viewController)
                getPendingDuesAndShow(viewController: viewController)
                if QRReachability.isConnectedToNetwork() == false{
                    NavigateToRespectivePage(oldViewController: viewController, handler: handler)
                    return
                }
                let rideEtiquette = SharedPreferenceHelper.getRideEtiquette()
                if rideEtiquette != nil && rideEtiquette!.imageUri != nil && !rideEtiquette!.imageUri!.isEmpty{
                    let rideEtiquetteVc = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideEtiquetteViewController") as! RideEtiquetteViewController
                    rideEtiquetteVc.initializeView(rideEtiquette: rideEtiquette!, isFromSignUpFlow: isFromSignupFlow)
                    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: rideEtiquetteVc, animated: false)
                }
                else{
                   NavigateToRespectivePage(oldViewController: viewController, handler: handler)
                }
                getAndStoreRideEtiquetteIfAny()
            }
        }
        getSystemCouponsForReferralAndRole(viewController: viewController)
    }
    
    static func getAndStoreRideEtiquetteIfAny(){
        UserRestClient.getDisplayableRideEtiquette(userId: QRSessionManager.getInstance()?.getUserId(), targetViewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS"{
                let rideEtiquette = Mapper<RideEtiquette>().map(JSONObject: responseObject!["resultData"])
                if rideEtiquette != nil && rideEtiquette!.imageUri != nil && !rideEtiquette!.imageUri!.isEmpty{
                    SharedPreferenceHelper.storeRideEtiquette(rideEtiquette: rideEtiquette)
                }
            }
        }
    }
    
   
    static func NavigateToRespectivePage( oldViewController: UIViewController?, handler: DialogDismissCompletionHandler?){
        handler?()
        ViewControllerUtils.finishViewController(viewController: oldViewController)
        if AppDelegate.getAppDelegate().isNotificationNavigationRequired{
            moveToRecentTabBar()
            return
        }
        let recentRide = MyActiveRidesCache.getRidesCacheInstance()?.getNextRecentRideOfUser()
        let recentTaxiRide = MyActiveTaxiRideCache.getInstance().getNextRecentTaxiRidePassenger()
        if let carpoolNextRide = recentRide,let taxiNextRide = recentTaxiRide{
            if carpoolNextRide.startTime < taxiNextRide.pickupTimeMs ?? 0{
                if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: carpoolNextRide.startTime, time2: NSDate().getTimeStamp())/60 < 12{ // before 12 hours
                    moveToRideViewViewController(ride: carpoolNextRide)
                }else{
                    moveToRecentTabBar()
                }
            }else{
                if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: taxiNextRide.pickupTimeMs, time2: NSDate().getTimeStamp())/60 < 12{ // before 12 hours
                    moveToTaxiLiveRide(taxiRideId: taxiNextRide.id ?? 0)
                }else{
                    moveToRecentTabBar()
                }
            }
        }else if let carpoolNextRide = recentRide,DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: carpoolNextRide.startTime, time2: NSDate().getTimeStamp())/60 < 12{
            moveToRideViewViewController(ride: carpoolNextRide)
        }else if let taxiNextRide = recentTaxiRide, DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: taxiNextRide.pickupTimeMs, time2: NSDate().getTimeStamp())/60 < 12{
            moveToTaxiLiveRide(taxiRideId: taxiNextRide.id ?? 0)
        }else{
            moveToRecentTabBar()
        }
    }
    
    static func moveToTaxiLiveRide(taxiRideId: Double){
        let taxiLiveRide = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiLiveRideMapViewController") as! TaxiLiveRideMapViewController
        taxiLiveRide.initializeDataBeforePresenting(rideId: taxiRideId)
        ContainerTabBarViewController.indexToSelect = 0
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: taxiLiveRide, animated: false)
    }
    static func moveToRecentTabBar(){
        let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = SharedPreferenceHelper.getRecentTabBarIndex()
        let centerNavigationController = UINavigationController(rootViewController: routeViewController)
        AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
    }
    static func  getCurrentUserRideTypeBasedOnInvitingUserRideType(invitingUserRideType : String)-> String {
        var currentUserRideType : String?
        switch (invitingUserRideType) {
        case Ride.RIDER_RIDE:
            currentUserRideType = Ride.PASSENGER_RIDE
            break
        case Ride.PASSENGER_RIDE:
            currentUserRideType = Ride.RIDER_RIDE
            break;
        case Ride.REGULAR_RIDER_RIDE:
            currentUserRideType = Ride.REGULAR_PASSENGER_RIDE
            break
        case Ride.REGULAR_PASSENGER_RIDE:
            currentUserRideType = Ride.REGULAR_RIDER_RIDE
            break
        default:
            break
        }
        return currentUserRideType!
    }
    
    static func moveToRideViewViewController(ride : Ride){
        AppDelegate.getAppDelegate().log.debug(" moveToRideViewViewController()")
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ContainerTabBarViewController.indexToSelect = 1
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    static func getRiderRideStatusForPassenger(ride : PassengerRide) -> String?
    {
        let activeRidesCache = MyActiveRidesCache.getRidesCacheInstance();
        if (activeRidesCache == nil) {
            return nil
        }
        let rideDetailInfo : RideDetailInfo? = activeRidesCache!.getRideDetailInfoIfExist(riderRideId: ride.riderRideId)
        if ( rideDetailInfo == nil )
        {
            return nil
        }
        if(rideDetailInfo!.riderRide == nil)
        {
            return nil
        }
        return rideDetailInfo!.riderRide!.status
    }
    
    static func handleRiderInviteFailedException(errorResponse :ResponseError,
                                                  viewController: UIViewController,
                                                  addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComplitionHanler?){
        let errorCode = errorResponse.errorCode
        if RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == errorCode
            || RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE == errorCode ||
            RideValidationUtils.TRYING_TO_BOOK_TWO_SEATS_FOR_FREE_RIDE_ERROR == errorCode ||
            RideValidationUtils.BOKKING_MORE_THAN_ONE_SEAT_USING_PROMO_CODE_ERROR == errorCode ||
            RideValidationUtils.NOT_VERIFIED_USER_USING_FREE_RIDE_ERROR == errorCode ||
            RideValidationUtils.NOT_VEIRIFIED_USER_USING_PROMO_CODE_ERROR == errorCode ||
            RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == errorCode ||
            RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == errorCode{
            var description = errorResponse.userMessage
            if(RideValidationUtils.TRYING_TO_BOOK_TWO_SEATS_FOR_FREE_RIDE_ERROR == errorCode)
            {
                description = Strings.one_seat_for_free_ride
                handleUserSelectingTwoSeatsForFreeRideScenario(viewController: viewController, description: description!, addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
            }else if(RideValidationUtils.BOKKING_MORE_THAN_ONE_SEAT_USING_PROMO_CODE_ERROR == errorCode)
            {
                description = Strings.one_seat_for_promotional_ride
                handleUserSelectingTwoSeatsForFreeRideScenario(viewController: viewController, description: description!, addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
            }
            else if(RideValidationUtils.NOT_VERIFIED_USER_USING_FREE_RIDE_ERROR == errorCode)
            {
                description = Strings.not_verified_using_free_ride
                RideValidationUtils.handleBalanceInsufficientError(viewController: viewController, title: Strings.low_bal_in_account, errorMessage: description!,primaryAction: Strings.verify_now_caps,secondaryAction: Strings.i_dont_want_free_ride, addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
            }
            else if(RideValidationUtils.NOT_VEIRIFIED_USER_USING_PROMO_CODE_ERROR == errorCode)
            {
                description = Strings.not_verified_using_promotional_ride
                RideValidationUtils.handleBalanceInsufficientError(viewController: viewController, title: Strings.low_bal_in_account, errorMessage: description!,primaryAction: Strings.verify_now_caps,secondaryAction: Strings.i_dont_want_promotion_ride, addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
            }
            else if(RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE  == errorCode
                || RideValidationUtils.PASSENGER_INSUFFICIENT_BALANCE == errorCode || RideValidationUtils.REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR == errorCode || RideValidationUtils.REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR == errorCode){
                RideValidationUtils.handleBalanceInsufficientError(viewController: viewController, title: Strings.low_bal_in_account, errorMessage: description!, primaryAction: Strings.recharge_caps, secondaryAction: nil, addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
            }
            else{
                MessageDisplay.displayErrorAlert(responseError: errorResponse, targetViewController: viewController,handler: nil)
            }
        }else if RideValidationUtils.SIMPL_PAYMENT_ERROR == errorCode || RideValidationUtils.SIMPL_PAYMENT_INSUFFICIENT_CREDIT == errorCode{
            if let developerMsg = errorResponse.developerMessage{
                MessageDisplay.displayErrorAlertWithAction(title: errorResponse.userMessage, isDismissViewRequired: true, message1: errorResponse.hintForCorrection, message2: nil, positiveActnTitle: Strings.pay_now_caps, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, viewController: nil) { (actionText) in
                    GSManager.shared().openRedirectionURL(developerMsg) {
                        (response, error) in
                        if error != nil {
                            MessageDisplay.displayErrorAlertWithAction(title: Strings.payment_completion_failure_msg, isDismissViewRequired: true, message1: Strings.please_try_again, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: nil, handler: nil)
                        }
                    }
                }
            }else{
                MessageDisplay.displayErrorAlertWithAction(title: errorResponse.userMessage, isDismissViewRequired: true, message1: errorResponse.hintForCorrection, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: nil, handler: nil)
            }
            
        }else if RideValidationUtils.LAZYPAY_EXPIRED_ERROR == errorCode{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.lazypay_expire_error, message2: nil, positiveActnTitle: Strings.link_caps, negativeActionTitle : Strings.not_now_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if result == Strings.link_caps{
                    AccountUtils().lazyPayRequestOTP(linkExternalWalletReceiver: nil)
                }
          })
        }else if RideValidationUtils.UPI_TRANSACTION_PENDING_ERROR == errorCode{
            
            getPendingDuesAndShow(viewController: viewController)
            
        }else if RideValidationUtils.LINKED_WALLET_EXPIRY_ERROR == errorCode{
            AccountUtils().showLinkedWalletExpiredAlert(viewController: viewController, linkExternalWalletReceiver: nil)
        }else{
            MessageDisplay.displayErrorAlert(responseError: errorResponse, targetViewController: viewController,handler: nil)
        }
    }
    
    static func handleUserSelectingTwoSeatsForFreeRideScenario(viewController :UIViewController, description : String,addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComplitionHanler?){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet == nil{
            AccountUtils().addLinkWalletSuggestionAlert(title: description, message: nil, viewController: viewController){ (walletAdded, walletType) in
                if walletAdded{
                    addMoneyOrWalletLinkedComlitionHanler?(.selected)
                }
            }
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
            let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
            addMoneyViewController.initializeView(errorMsg: description){ (result) in
                if result == .addMoney {
                    addMoneyOrWalletLinkedComlitionHanler?(result)
                }else if result == .changePayment{
                    let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
                    setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: nil) {(data) in }
                    ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: addMoneyViewController)
            
        }else{
            AccountUtils().showLinkedWalletBalanceInsufficientAlert(){ (result) in
                if result == .makeDefault || result == .selected{
                    addMoneyOrWalletLinkedComlitionHanler?(.selected)
                }
            }
        }
    }
    
    static func handleRideCreationFailureException(errorResponse :ResponseError, viewController: UIViewController){
        let errorCode = errorResponse.errorCode
        if RideValidationUtils.NOT_VERIFIED_USER_TRYING_TO_CREATE_RIDE_ERROR == errorCode
        {
            let description = errorResponse.userMessage
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: description, message2: nil, positiveActnTitle: Strings.verify_caps, negativeActionTitle : Strings.not_now_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                if result == Strings.verify_caps{
                    RideManagementUtils.navigateToProfile()
                }
            })
        }else{
            MessageDisplay.displayErrorAlert(responseError: errorResponse, targetViewController: viewController,handler: nil)
        }
    }
    
    static func navigateToProfile(){
        let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
        
        if(userProfile?.email == nil || userProfile?.email?.isEmpty == true){
            let destViewController  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
            destViewController.initializeDataBeforePresentingView(presentedFromActivationView: false)
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: destViewController, animated: false)
        }else if(userProfile?.companyName == nil || userProfile?.companyName?.isEmpty == true){
            let destViewController  = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: destViewController, animated: false)
        }else{
            let destViewController  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
            ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: destViewController, animated: false)
        }
    }
   
    static func getUserQualifiedToDisplayContact() -> Bool{
        guard let account = UserDataCache.getInstance()?.userAccount,  let user = UserDataCache.getInstance()?.currentUser , let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile() else {
            return true
        }
        
        if let wallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
            return true
        }
        if account.balance! >= 10.0{
            return true
        }
        if userProfile.verificationStatus != 0{
            return true
        }
        
        if user.creationDate != 0{
            let freeRideCoupon = RideManagementUtils.checkWhetherFreeRideCouponIsPresent()
            if freeRideCoupon != nil && freeRideCoupon!.activationTime != nil && freeRideCoupon!.expiryTime != nil{
                let difference = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: freeRideCoupon!.expiryTime!/1000))
                if  difference < 0{
                    return true
                }
            }
        }
        return false
    }
    
    static func getUserRoleBasedOnRide() -> UserRole{
        let ride = MyActiveRidesCache.getRidesCacheInstance()?.getNextRecentRideOfUser()
        if ride == nil{
            return UserRole.None
        }else if ride!.rideType == Ride.RIDER_RIDE{
            return UserRole.Rider
        }else if ride!.rideType == Ride.PASSENGER_RIDE{
            return UserRole.Passenger
        }
        else{
            return UserRole.None
        }
    }
    
    static func updateStatusAndNavigate(isFromSignupFlow: Bool, viewController: UIViewController?,handler : DialogDismissCompletionHandler?){
         BaseRouteViewController.isFromSignUpFlow = isFromSignupFlow
        if isFromSignupFlow{
            UserDataCache.getInstance()?.updateSignUpFlowTimeLineStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS, status: true)
            UserDataCache.getInstance()?.updateSignUpFlowTimeLineStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO, status: true)
            UserDataCache.getInstance()?.updateSignUpFlowTimeLineStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, status: true)
        }
        checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
//        checkIfUserConfirmedSafeAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
    }
    
    static func checkIfUserConfirmedSafeAndNavigate(isFromSignupFlow: Bool, viewController: UIViewController?, handler: DialogDismissCompletionHandler?) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                if clientConfiguration.showCovid19SelfAssessment {
            let userSelfAssessmentCovid = UserDataCache.getInstance()?.userSelfAssessmentCovid
            if userSelfAssessmentCovid == nil || (userSelfAssessmentCovid?.assessmentResult == UserSelfAssessmentCovid.FAIL) {
                moveToSafeKeeperConfirmationView(isFromSignupFlow: isFromSignupFlow, status: userSelfAssessmentCovid?.assessmentResult, viewController: viewController, handler: handler)
            } else {
                checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
            }
        }
        else{
            checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
        }
    }
    
    static func showSafeKeeperRejectedDailogue(expiryDate: Double, isFromSignupFlow: Bool, viewController: UIViewController?, handler: DialogDismissCompletionHandler?) {
        let date = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: expiryDate/1000), dateFormat: DateUtils.DATE_FORMAT_MMM_dd)
        let message = String(format: Strings.suggest_not_to_carpool, arguments: [(date ?? "")])
        MessageDisplay.displayInfoViewAlert(title: nil, titleColor: nil, message: message, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.ok_got_it) {
            checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
        }
    }
    
    static func moveToSafeKeeperConfirmationView(isFromSignupFlow: Bool, status: String?, viewController: UIViewController?, handler: DialogDismissCompletionHandler?) {
        let lastDisplayedTime = SharedPreferenceHelper.getSafeKepeerReconfirmViewDispalyTime()
        if lastDisplayedTime != nil && DateUtils.getTimeDifferenceInMins(date1: NSDate(), date2: lastDisplayedTime!) < 24*60
        {
            checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
            return
        }
        if status == UserSelfAssessmentCovid.FAIL {
            SharedPreferenceHelper.setSafeKepeerReconfirmViewDisplayTime(time: NSDate())
        }
        let safeKeeperConfirmationVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SafeKeeperConfirmationViewController") as! SafeKeeperConfirmationViewController
        safeKeeperConfirmationVC.initializeData(checkList: Strings.safe_keeper_check_list, status: status) { (action) in
            if action == Strings.im_safe {
                saveSafeKeeperStatus(status: UserSelfAssessmentCovid.PASS, isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
            } else if action == Strings.not_sure {
                showWarningMessage(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
            }
        }
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: safeKeeperConfirmationVC, animated: false)
    }
    
    static func showWarningMessage(isFromSignupFlow: Bool, viewController: UIViewController?, handler: DialogDismissCompletionHandler?) {
        MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: false, message1: Strings.not_sure_confirmation_message, message2: nil, positiveActnTitle: Strings.ok_sure, negativeActionTitle: Strings.go_back, linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, viewController: nil) { (action) in
            if action == Strings.ok_sure {
                saveSafeKeeperStatus(status: UserSelfAssessmentCovid.FAIL, isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
            }
        }
    }
    
    static func saveSafeKeeperStatus(status: String, isFromSignupFlow: Bool, viewController: UIViewController?, handler: DialogDismissCompletionHandler?) {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.saveSafeKeeperStatus(userId: QRSessionManager.getInstance()?.getUserId(), status: status) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
            let userSelfAssessmentCovid = Mapper<UserSelfAssessmentCovid>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserSelfAssessmentCovid(userSelfAssessmentCovid: userSelfAssessmentCovid)
                if userSelfAssessmentCovid?.assessmentResult == UserSelfAssessmentCovid.FAIL {
                    showSafeKeeperRejectedDailogue(expiryDate: userSelfAssessmentCovid?.expiryDate ?? 0, isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
                } else {
                    checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: isFromSignupFlow, viewController: viewController, handler: handler)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    static func checkWhetherFreeRideCouponIsPresent() -> UserCouponCode?{
        let configurationCache = ConfigurationCache.getInstance()
        
        if configurationCache != nil && !configurationCache!.userCoupons.isEmpty{
            
            for userCoupon in configurationCache!.userCoupons{
                if userCoupon.couponType == SystemCouponCode.COUPON_TYPE_FREE_RIDE && userCoupon.status == SystemCouponCode.COUPON_STATUS_ACTIVE && (userCoupon.maxAllowedTimes - userCoupon.usedTimes) > 0{
                  return userCoupon
                }
            }
        }
      return nil
    }
    
    static func refreshUserCoupons(){
        if ConfigurationCache.isCouponsRetrieved && (Int((UserDataCache.getInstance()?.userProfile?.numberOfRidesAsRider)!) + Int((UserDataCache.getInstance()?.userProfile?.numberOfRidesAsPassenger)!
            )) == 0 {
            ConfigurationCache.getInstance()?.getUserCoupons()
        }
    }
    
    static func getRideContributionForRide(rideId : String, viewController : UIViewController, handler: @escaping CompletionHandlers.rideContributionRetrievalCompletionHandler){
        RideServicesClient.getRideContributionForRide(rideId: rideId, viewController: viewController, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let rideContribution = Mapper<RideContribution>().map(JSONObject: responseObject!["resultData"])
                handler(rideContribution,nil)
            }
            else{
                handler(nil,nil)
            }
        })
    }
    
    static func isFeedbackMandatory(userFeedbackMap: [UserFeedback]) -> Bool{
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.enableFirstRideBonusPointsOffer{
            for userFeedback in userFeedbackMap{
                if retrieveCurrentUserAndCheckWhetherNewUser(){
                    if userFeedback.rating == 0{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    static func retrieveCurrentUserAndCheckWhetherNewUser() -> Bool{
        if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.getLoggedInUserProfile() != nil{
            let ridesTaken = UserDataCache.getInstance()!.getLoggedInUserProfile()!.numberOfRidesAsRider + UserDataCache.getInstance()!.getLoggedInUserProfile()!.numberOfRidesAsPassenger
            if Int(ridesTaken) <= 1 && UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0{
                return true
            }
        }
        return false
    }
    
    static func openCurrentRidePendingTransactionViewController(pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]){
        let pendingLinkedWalletTransactionVC = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PayBillForCurrentRideVIewController") as! PayBillForCurrentRideVIewController
        pendingLinkedWalletTransactionVC.initializeDataBeforePresenting(pendingLinkedWalletTransactions: pendingLinkedWalletTransactions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: pendingLinkedWalletTransactionVC)
    }
            
    static func getPendingRefundRequestsAndShow(viewController: UIViewController?){
        AccountRestClient.getPendingRefundRequest(userId: UserDataCache.getInstance()?.userId ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let refundRequests = Mapper<RefundRequest>().mapArray(JSONObject: responseObject!["resultData"])
                guard let pendingRefundRequests = refundRequests else { return }
                for refundRequest in pendingRefundRequests{
                    let refundRequestViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RefundRequestViewController") as! RefundRequestViewController
                    refundRequestViewController.initializerefundData(RefundRequest: refundRequest)
                    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: refundRequestViewController, animated: false)
                }
            }
        }
    }
    
    static func getPendingDuesAndShow(viewController: UIViewController?){
        AccountRestClient.getPendingDues(userId: UserDataCache.getInstance()?.userId ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let pendingDues = Mapper<PendingDue>().mapArray(JSONObject: responseObject!["resultData"]),!pendingDues.isEmpty{
                    let clearPendingBillsViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ClearPendingBillsViewController") as! ClearPendingBillsViewController
                    clearPendingBillsViewController.initialisePendingBills(pendingDues: pendingDues)
                    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: clearPendingBillsViewController, animated: false)
                }
            }
        }
    }
    
    static func getSystemCouponsForReferralAndRole(viewController: UIViewController?){
        UserRestClient.getCouponsForReferralAndRole(userId: UserDataCache.getInstance()?.userId ?? "", role: SystemCouponCode.COUPON_APPLICABLE_ROLE_TAXI_PASSENGER, scheme: SystemCouponCode.COUPON_APPLICABLE_REFERRAL, viewController: viewController) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let systemCoupons = Mapper<UserSystemCoupons>().map(JSONObject: responseObject?["resultData"])
                if let coupons = systemCoupons?.systemCouponCodeListForScheme {
                    var pointsFirstRideOfRefferedUser : Int?
                    var pointsAfterVerificationOfReferredUser : Int?
                    if let coupon = coupons.first(where: {$0.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_SHARE_RIDE}) {
                        pointsFirstRideOfRefferedUser = Int(coupon.cashDeposit)
                    }
                    if let coupon = coupons.first(where: {$0.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_VERIFIY_PROFILE}) {
                        pointsAfterVerificationOfReferredUser = Int(coupon.cashDeposit)
                    }
                    SharedPreferenceHelper.storeShareAndEarnPoints(pointsAfterVerificationOfReferredUser: pointsAfterVerificationOfReferredUser, pointsFirstRideOfRefferedUser: pointsFirstRideOfRefferedUser)
                }
                if let coupons = systemCoupons?.systemCouponCodeListForRole,!coupons.isEmpty{
                    if let coupon = coupons.first(where: {$0.applicableUserRole == SystemCouponCode.COUPON_APPLICABLE_ROLE_TAXI_PASSENGER}) {
                        SharedPreferenceHelper.setTaxiOfferCoupon(coupon: coupon)
                    }
                }else{
                    SharedPreferenceHelper.setTaxiOfferCoupon(coupon: nil)
                }
            }
        }
    }
}
