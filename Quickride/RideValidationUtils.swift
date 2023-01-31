//
//  RideValidationUtils.swift
//  Quickride
//
//  Created by QuickRideMac on 09/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps

typealias addMoneyOrWalletLinkedComplitionHanler = (_ result: AddMoneyAction) -> Void

class RideValidationUtils {
    static let PASSENGER_INSUFFICIENT_BALANCE = 2640
    static let INSUFFICIENT_SEATS_ERROR = 2629
    static let PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE = 2641
    static let PASSENGER_ALREADY_JOINED_THIS_RIDE = 2635
    static let PASSENGER_ENGAGED_IN_OTHER_RIDE = 2631
    static let TRYING_TO_BOOK_TWO_SEATS_FOR_FREE_RIDE_ERROR = 2652
    static let NOT_VERIFIED_USER_USING_FREE_RIDE_ERROR = 2656
    static let REQUIRED_MORE_POINTS_THAN_FREE_RIDE_ERROR = 2657
  
    static let NOT_VEIRIFIED_USER_USING_PROMO_CODE_ERROR = 2658
    static let BOKKING_MORE_THAN_ONE_SEAT_USING_PROMO_CODE_ERROR = 2659
    static let REQUIRED_POINTS_MORE_THAN_PROMO_CODE_ERROR = 2660
    static let NOT_VERIFIED_USER_TRYING_TO_CREATE_RIDE_ERROR = 2662
    static let MAXIMUM_DISTANCE_TO_CREATE_RIDE_IN_KM : String = "1000"
    static let REGULAR_RIDE_CREATION_RESTRICTION_ERROR = 2696
    static let RIDE_NOT_FOUND = 2601
    static let RIDE_ALREADY_COMPLETED = 2633
    static let RIDE_CLOSED_ERROR = 2649
    static let SIMPL_PAYMENT_INSUFFICIENT_CREDIT = 3951
    static let SIMPL_PAYMENT_ERROR = 3952
    static let TMW_WALLET_NOT_PRESENT = 3853
    static let LAZYPAY_EXPIRED_ERROR = 4053
    static let RIDE_NOT_MATCHING_ERROR = 2694
    static let UPI_TRANSACTION_PENDING_ERROR = 1251
    static let LINKED_WALLET_EXPIRY_ERROR = 1250
    static let RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR = 2704
    static let RIDER_PICKED_UP_ERROR = 1252
    static let PAY_TO_REQUEST_RIDE_ERROR = 1402
    static let INSUFFICIENT_BALANCE_FOR_BUY_OR_RENT = 1201
    
    static let RIDES_DONT_MATCH_ANYMORE = 2694;

  
    static func validateDestinationLocation(ride : Ride,locationName : String) -> Bool{
      AppDelegate.getAppDelegate().log.debug("validateDestinationLocation() \(locationName)")
        if ride.endLatitude == 0 || ride.endLongitude == 0 || ride.endAddress.isEmpty || locationName.isEmpty {
            return false
        }else{
            return true
        }
    }
    static func validateSourceLocation(ride : Ride,locationName : String) -> Bool{
      AppDelegate.getAppDelegate().log.debug("validateSourceLocation() \(locationName)")
        if ride.startLatitude == 0 || ride.startLongitude == 0 || ride.startAddress.isEmpty || locationName.isEmpty{
            return false
        }else{
            return true
        }
    }
    static func handleRiderInvitationFailedException(error : ResponseError,viewController : UIViewController,addMoneyOrWalletLinkedComlitionHanler: @escaping addMoneyOrWalletLinkedComplitionHanler){
      AppDelegate.getAppDelegate().log.debug("handleRiderInvitationFailedException()")
        if error.errorCode == PASSENGER_INSUFFICIENT_BALANCE || error.errorCode == PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE{
            RideValidationUtils.handleBalanceInsufficientError(viewController: viewController,title: Strings.invite_failed,errorMessage: error.userMessage!,primaryAction: Strings.recharge_caps,secondaryAction:nil,addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComlitionHanler)
        }else{
            MessageDisplay.displayAlert(messageString: Strings.invite_failed+error.userMessage!, viewController: viewController,handler: nil)
        }
    }
    
    static func handleBalanceInsufficientError(viewController : UIViewController?,title : String, errorMessage: String,primaryAction :String,secondaryAction : String?,addMoneyOrWalletLinkedComlitionHanler: addMoneyOrWalletLinkedComplitionHanler?){
        
        AppDelegate.getAppDelegate().log.debug("handleBalanceInsufficientError() \(errorMessage)")
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet == nil{
            AccountUtils().addLinkWalletSuggestionAlert(title: errorMessage, message: nil, viewController: viewController){ (walletAdded, walletType) in
                if walletAdded{
                    addMoneyOrWalletLinkedComlitionHanler?(.selected)
                }
            }
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
            let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
            addMoneyViewController.initializeView(errorMsg: errorMessage){ (result) in
                if result == .addMoney {
                    addMoneyOrWalletLinkedComlitionHanler?(.addMoney)
                } else if result == .changePayment {
                    self.showPaymentDrawer()
                }
            }
            addMoneyViewController.modalPresentationStyle = .overFullScreen
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: addMoneyViewController, animated: true, completion: nil)
        }else{
            AccountUtils().showLinkedWalletBalanceInsufficientAlert(){ (result) in
                if result == .makeDefault || result == .selected {
                    addMoneyOrWalletLinkedComlitionHanler?(.selected)
                }
            }
        }
    }
    
   static func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
       setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: nil) {(data) in }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    static func isRegularRide(rideType : String) -> Bool{
      AppDelegate.getAppDelegate().log.debug("isRegularRide()")
        if Ride.REGULAR_RIDER_RIDE == rideType || Ride.REGULAR_PASSENGER_RIDE == rideType{
            return true
        }else{
            return false
        }
    }
    
    static func isStartAndEndAddressAreSame(ride : Ride) -> Bool{
      AppDelegate.getAppDelegate().log.debug("isStartAndEndAddressAreSame()")
      if ride.distance != nil && ride.distance!*1000 > MyActiveRidesCache.THRESHOLD_DISTANCE_FOR_ACTUAL_RIDE_DISTANCE_IN_METRES{
        return false
      }
        let startPoint = CLLocation(latitude : ride.startLatitude, longitude: ride.startLongitude)
        let endPoint = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        return startPoint.distance(from: endPoint) <= MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES
    }
    static func displayRedundentRideAlert(ride: Ride, viewController : UIViewController){
      AppDelegate.getAppDelegate().log.debug("displayRedundentRideAlert()")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: String(format: Strings.ride_duplicate_alert, arguments: [DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)!]), message2: nil, positiveActnTitle: Strings.view_scheduled_ride, negativeActionTitle: nil, linkButtonText: nil, viewController: viewController, handler: { (result) -> Void in
            if result == Strings.view_scheduled_ride {
                let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
                mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
                let myRides = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: myRides, animated: false)
                ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
            }
        })
    }
    static func validatePreconditionsForCreatingRide(ride : Ride, vehicle : Vehicle?, fromLocation : String?, toLocation : String?,viewController : UIViewController) -> Bool{
        AppDelegate.getAppDelegate().log.debug("validatePreconditionsForCreatingRide()")
        if RideValidationUtils.validateDestinationLocation(ride: ride,locationName: toLocation!) == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.destinationLocationNotAvailable, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-300), title: nil, image: nil, completion: nil)
            return true
        }
        if RideValidationUtils.validateSourceLocation(ride: ride, locationName: fromLocation!) == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.sourceLocationNotAvailable, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-300), title: nil, image: nil, completion: nil)
            return true
        }
        if RideValidationUtils.isStartAndEndAddressAreSame(ride: ride){
            UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-300), title: nil, image: nil, completion: nil)
            return true
        }
        if ride.rideType == Ride.RIDER_RIDE{
            
            if(Vehicle.isOfferedSeatsValid(offeredSeats: String(vehicle!.capacity)) == false) {
                UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_vehicle_capacity)
                return true
            }
            
            if (vehicle!.vehicleType == Vehicle.VEHICLE_TYPE_BIKE) {
                if (vehicle!.capacity  > Vehicle.BIKE_MAX_CAPACITY) {
                    UIApplication.shared.keyWindow?.makeToast( Strings.bike_capacity_exceeds_max_value)
                    return true
                }
            }
            
            if (Vehicle.isVehicleFareValid(selectedFare: String(vehicle!.fare)) == false) {
                var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
                if clientConfiguration == nil{
                    clientConfiguration = ClientConfigurtion()
                }
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.enter_valid_vehicle_fare, arguments: [StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.vehicleMaxFare)]))
                return true
            }
        }
        return false
    }
    static func validateRideDistance(ride: Ride) -> Bool{
        if let distance = ride.distance, distance > Double(RideValidationUtils.MAXIMUM_DISTANCE_TO_CREATE_RIDE_IN_KM) ?? 0{
            return true
        }
        return false
    }
    static func validateResponseErrorCodeAndReturnStatus(responseError : ResponseError) -> Bool{
         if responseError.errorCode == RideValidationUtils.RIDE_NOT_FOUND || responseError.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR || responseError.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE{
            return true
        }
      return false
    }
    
    static func checkUserJoinedInUpCommingRide(userId: Double) -> Bool{
        if let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.riderRideDetailInfo?.values{
            for rideDetail in rideDetailInfo{
                if rideDetail.rideParticipants == nil {
                    continue
                }
                for rideParticipant in rideDetail.rideParticipants! {
                    if rideParticipant.userId == userId{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    static func getRideTimeInString(rideTime: Double) -> String?{
        let rideDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let todaytDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getCurrentTimeInMillis(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        let tomorrowDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.addMinutesToTimeStamp(time: DateUtils.getCurrentTimeInMillis(), minutesToAdd: 1440), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        if rideDate == todaytDate{
            if let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a){
                return "Today, "+rideTime
            }
        }else if rideDate == tomorrowDate{
            if let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a){
                return "Tomorrow, "+rideTime
            }
        }else{
            let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.WR_DATE_FORMAT_dd_MMM_hh_mm_aaa)
            return rideTime
        }
        return nil
    }
}
