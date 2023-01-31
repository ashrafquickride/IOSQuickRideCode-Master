//
//  RideUpdateAlertController.swift
//  Quickride
//
//  Created by Admin on 31/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import Lottie

typealias rideUpdateCompletionHandler = (_ matchedUser : MatchedUser) -> Void

class RideUpdateAlertController : UIViewController,SelectDateDelegate{
 
 @IBOutlet weak var rideUpdateView: UIView!

 @IBOutlet weak var animatedView: UIView!
    
 @IBOutlet weak var userImageView: UIImageView!
    
 @IBOutlet weak var userNameLbl: UILabel!
    
 @IBOutlet weak var verificationBadge: UIImageView!

 @IBOutlet weak var companyNameLbl: UILabel!
    
 @IBOutlet weak var fromLocationLbl: UILabel!
 
 @IBOutlet weak var toLocationLbl: UILabel!
 
 @IBOutlet weak var editTimeView: UIView!
    
 @IBOutlet weak var rideStartTimeLbl: UILabel!
    
 @IBOutlet weak var loadingAnimationView: AnimationView!
    
 @IBOutlet weak var alertView: UIView!
    
 @IBOutlet weak var backGroundView: UIView!
    
  @IBOutlet weak var rideUpdateBtn: UIButton!
    
 var matchedUser : MatchedUser?
 var rideUpdateCompletionHandler : rideUpdateCompletionHandler?
 var isRideStartTimeUpdated = false
 var ride : Ride?
    
    func initializeDataBeforePresenting(matchedUser : MatchedUser?,ride : Ride?, rideUpdateCompletionHandler : @escaping rideUpdateCompletionHandler){
     self.matchedUser = matchedUser
     self.rideUpdateCompletionHandler = rideUpdateCompletionHandler
     self.ride = ride
 }
    
 override func viewDidLoad() {
    super.viewDidLoad()
    setVerificationLabel()
    self.userNameLbl.text = matchedUser!.name
    self.fromLocationLbl.text = matchedUser!.fromLocationAddress
    self.toLocationLbl.text = matchedUser!.toLocationAddress
    setRideTime()
    ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: matchedUser!.imageURI, gender: matchedUser!.gender!,imageSize: ImageCache.DIMENTION_TINY)
    self.editTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideUpdateAlertController.editTimeViewTapped(_:))))
    ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10.0)
    self.backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideUpdateAlertController.backGroundViewTapped(_:))))
    ViewCustomizationUtils.addCornerRadiusToView(view: rideUpdateView, cornerRadius: 10.0)
    ViewCustomizationUtils.addCornerRadiusToView(view: animatedView, cornerRadius: 10.0)
 }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: self.rideUpdateBtn, cornerRadius: 10.0)
        CustomExtensionUtility.changeBtnColor(sender: self.rideUpdateBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }

    
 func setVerificationLabel(){
        AppDelegate.getAppDelegate().log.debug("setVerificationLabel()")
        companyNameLbl.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser?.profileVerificationData, companyName: matchedUser?.companyName?.capitalized)
        if companyNameLbl.text == Strings.not_verified {
            companyNameLbl.textColor = UIColor.black
        }else{
            companyNameLbl.textColor = UIColor(netHex: 0x24A647)
        }
        verificationBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser?.profileVerificationData)
        
 }
    
    @IBAction func updateRideBtnClicked(_ sender: Any) {
         rescheduleRide()
    }
    
    func rescheduleRide(){
     
        let rideToReschedule = self.ride
        rideToReschedule!.startTime = self.ride!.startTime
        let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: rideToReschedule!)
        if  redundantRide != nil{
            RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: self)
            
        }else{
            self.rideUpdateView.isHidden = true
            self.animatedView.isHidden = false
            loadingAnimationView.animation = Animation.named("loading_otp")
            loadingAnimationView.isHidden = false
            loadingAnimationView.play()
            loadingAnimationView.loopMode = .loop
            if rideToReschedule!.rideType == Ride.RIDER_RIDE{
                RiderRideRestClient.rescheduleRiderRide(riderRideId: ride!.rideId, startTime: rideToReschedule!.startTime, ViewController: self, completionHandler: { (responseObject, error) -> Void in
                    self.loadingAnimationView.stop()
                    self.loadingAnimationView.isHidden = true
                    if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                        self.rideUpdateView.isHidden = false
                        self.animatedView.isHidden = true
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self, handler: nil)
                    }else if responseObject!["result"] as! String == "SUCCESS"{
                 
                        let rideStatus : RideStatus = RideStatus(rideId :rideToReschedule!.rideId, userId:rideToReschedule!.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.RIDER_RIDE, scheduleTime : self.ride!.startTime , rescheduledTime :rideToReschedule!.startTime)
                        MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                        self.ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: self.ride!.rideId)
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                        self.rideUpdateCompletionHandler?(self.matchedUser!)
                    }
                })
            }else if rideToReschedule!.rideType == Ride.PASSENGER_RIDE{
                PassengerRideServiceClient.reschedulePassengerRide(passengerRideId: (ride?.rideId)!, startTime: rideToReschedule!.startTime, viewController: self, completionHandler: { (responseObject, error) -> Void in
                    self.loadingAnimationView.stop()
                    self.loadingAnimationView.isHidden = true
                    if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                        self.rideUpdateView.isHidden = false
                        self.animatedView.isHidden = true
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self, handler: nil)
                    }else{
                        let rideStatus : RideStatus = RideStatus(rideId :rideToReschedule!.rideId, userId:rideToReschedule!.userId,  status : Ride.RIDE_STATUS_RESCHEDULED, rideType : Ride.PASSENGER_RIDE, scheduleTime : self.ride!.startTime , rescheduledTime :rideToReschedule!.startTime)
                        MyActiveRidesCache.getRidesCacheInstance()?.rescheduleRide(rideStatus: rideStatus)
                        self.ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: self.ride!.rideId)
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                        self.rideUpdateCompletionHandler?(self.matchedUser!)
                    }
                })
            }
        }
    }
    
    @objc func editTimeViewTapped(_ gesture : UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        
        let selectDateTimeViewController :ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        
        selectDateTimeViewController.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970/1000,maxDate: nil, defaultDate: (ride?.startTime)!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        ViewControllerUtils.presentViewController(currentViewController: self, viewControllerToBeDisplayed: selectDateTimeViewController, animated: false, completion: nil)
    }
    
    func getTime(date: Double) {
        if ride!.startTime != date{
            isRideStartTimeUpdated = true
        }else{
            isRideStartTimeUpdated = false
        }
        ride!.startTime = date
        self.rideStartTimeLbl.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: ride!.startTime), format: DateUtils.DATE_FORMAT_EEE_dd_MMM_h_mm_a)
    }
    
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func setRideTime(){
        AppDelegate.getAppDelegate().log.debug("")
        
        if matchedUser!.isKind(of: MatchedPassenger.classForCoder())
        {
            var time = self.matchedUser!.passengerReachTimeTopickup
            if time == nil{
                time = self.matchedUser!.startDate
            }
            self.ride?.startTime = time!
            self.rideStartTimeLbl.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: time!/1000), format: DateUtils.DATE_FORMAT_EEE_dd_MMM_h_mm_a)
            
         
        }else{
           self.rideStartTimeLbl.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: matchedUser!.pickupTime!/1000), format: DateUtils.DATE_FORMAT_EEE_dd_MMM_h_mm_a)
           self.ride?.startTime = matchedUser!.pickupTime!
        }
    }
    
    
}
