//
//  RideJoinConfirmationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 4/19/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import Lottie

class RideJoinConfirmationViewController: ModelViewController {
   
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var rideConfirmedTextView: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var pickUpAddressLabel: UILabel!
    
    @IBOutlet weak var autoConfirmLabel: UILabel!
    
    @IBOutlet weak var pickUpLabel: UILabel!
    
    @IBOutlet weak var forgroundView: UIView!
    
    @IBOutlet weak var vehicleNameOrNoOFSeats: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var newUserLbl: UILabel!
    
    @IBOutlet weak var foregroundViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seatsLabel: UILabel!
    
    @IBOutlet weak var autoConfirmView: UIView!
    
    @IBOutlet weak var autoConfirmViewHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var autoConfirmViewTopConstraint: NSLayoutConstraint!
    
    
    var rideId : Double?
    var rideType : String?
    var viewController : UIViewController?
    var riderVehicle : Vehicle?
    var currentPage = 0
    var timer : Timer?
    var joinedParticipants = [RideParticipant]()
    var currentUser : RideParticipant?
    var animationView : AnimationView?
    var ridePreferences : RidePreferences?
    
    static var rideConfirmationDialogue :RideJoinConfirmationViewController?
    
    func initializeDataBeforePresenting(rideId : Double, rideType : String, currentUser : RideParticipant?,joinedParticipant : RideParticipant,riderVehicle : Vehicle?, viewController : UIViewController?)
    {
        self.rideId = rideId
        self.rideType = rideType
        self.riderVehicle = riderVehicle
        self.viewController = viewController
        self.currentUser = currentUser
        joinedParticipants.append(joinedParticipant)
        RideJoinConfirmationViewController.rideConfirmationDialogue = self
    }
    
    func appendNewParticipant(rideParticipant : RideParticipant){
        joinedParticipants.append(rideParticipant)
        self.checkRideTypeAndInitializeData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().log.debug("loadView()")
        self.pageControl.currentPage = 0
        
        ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences
        
        ViewCustomizationUtils.addCornerRadiusToView(view: forgroundView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: autoConfirmView, cornerRadius: 10.0)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideJoinConfirmationViewController.backGroundViewTapped(_:))))
        self.checkRideTypeAndInitializeData()
        autoConfirmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:
            #selector(RideJoinConfirmationViewController.autoConfirmTextTapped(_:))))
        self.checkRideTypeAndInitializeData()
        let attributedString = NSMutableAttributedString(string: Strings.auto_confirm_rides_text)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x2196f3), textSize: 14), range: (Strings.auto_confirm_rides_text as NSString).range(of: "Auto Confirm Rides"))
        autoConfirmLabel.attributedText = attributedString
    }
    func checkRideTypeAndInitializeData(){
        if (Ride.PASSENGER_RIDE == rideType)
        {
            initiliazeViewForPassenger()
        }
        else if Ride.RIDER_RIDE == rideType{
            initializeViewForRider()
        }
    }
    func initiliazeViewForPassenger(){
        
        self.pageControl.isHidden = true
        self.pageControlHeightConstraint.constant = 0
        if joinedParticipants.isEmpty{
            
            return
        }
        let riderInfo = joinedParticipants[0]
        if currentUser != nil && (currentUser!.autoConfirm == rideType || currentUser!.autoConfirm == UserProfile.PREFERRED_ROLE_BOTH){
            self.autoConfirmView.isHidden = false
            self.autoConfirmViewTopConstraint.constant = 10
            self.autoConfirmViewHeightConstraint.constant = 70
        }else{
            self.autoConfirmViewTopConstraint.constant = 0
            self.autoConfirmViewHeightConstraint.constant = 0
            self.autoConfirmView.isHidden = true
        }
        handleVisibilityOfNewUserTextView(rideParticipant: riderInfo)
        self.rideConfirmedTextView.text = "You have joined \(riderInfo.name!)'s ride"

        self.pickUpLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: riderInfo.pickUpTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        self.pointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: ceil(riderInfo.points!)) + " " + Strings.pts
        var vehicleInfo = self.riderVehicle?.registrationNumber
        if vehicleInfo == nil || vehicleInfo!.isEmpty
        {
            vehicleInfo = self.riderVehicle?.makeAndCategory
        }
        
        if vehicleInfo == nil || vehicleInfo!.isEmpty
        {
            vehicleInfo = self.riderVehicle?.vehicleModel
        }
        self.vehicleNameOrNoOFSeats.text = vehicleInfo
        self.seatsLabel.text = ""
        self.pickUpAddressLabel.text = riderInfo.startAddress
    }
    
    func initializeViewForRider(){
        
        let joinedParticipants = RideJoinConfirmationViewController.rideConfirmationDialogue!.joinedParticipants
        if joinedParticipants.isEmpty{
            
            return
        }
        if joinedParticipants.count > 1{
            self.pageControl.isHidden = false
            self.pageControlHeightConstraint.constant = 15
            self.pageControl.numberOfPages = joinedParticipants.count
        }else{
            self.pageControl.isHidden = true
            self.pageControlHeightConstraint.constant = 0
        }
        currentPage = joinedParticipants.count - 1
        initializeViewBasedOnCurrentPage()
    }
    @objc func moveToNextPage (){
        initializeViewBasedOnCurrentPage()
        currentPage += 1
        if currentPage > joinedParticipants.count - 1 || currentPage < 0 {
            currentPage = 0
        }
    }
    
    func handleVisibilityOfNewUserTextView(rideParticipant : RideParticipant){
        
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if animationView != nil{
            animationView!.stop()
            animationView!.isHidden = true
        }
        animationView = AnimationView(name: "signup_congrats")
        animationView!.isHidden = false
        animationView!.contentMode = .scaleAspectFit
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        if clientConfiguration!.enableFirstRideBonusPointsOffer && UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && rideParticipant.noOfRidesShared == 0{
            animationView!.frame = CGRect(x: self.view.center.x - 30, y: self.view.center.y - 160 - statusBarHeight, width: 60, height: 60)
            self.view.addSubview(animationView!)
            animationView!.play()
            animationView!.loopMode = .playOnce
            newUserLbl.isHidden = false
            if pageControl.isHidden{
            foregroundViewHeightConstraint.constant = 390
            }else{
            foregroundViewHeightConstraint.constant = 400
            }
             newUserLbl.text = String(format: Strings.new_user_text, arguments: [rideParticipant.name!,rideParticipant.name!,StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.firstRideBonusPoints)])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.5
            let attributedString = NSMutableAttributedString(string: newUserLbl.text!)

            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 12.0), range: NSMakeRange(0, attributedString.length))
            newUserLbl.attributedText = attributedString

        }else{
            animationView!.frame = CGRect(x: self.view.center.x - 30, y: self.view.center.y - 125 - statusBarHeight, width: 60, height: 60)
            self.view.addSubview(animationView!)
            animationView!.play()
            animationView!.loopMode = .playOnce
            newUserLbl.isHidden = true
            foregroundViewHeightConstraint.constant = 320
            newUserLbl.text = ""
        }
            if !autoConfirmView.isHidden{
            foregroundViewHeightConstraint.constant = foregroundViewHeightConstraint.constant + autoConfirmViewHeightConstraint.constant
            animationView!.frame = CGRect(x: self.view.center.x - 30, y: self.view.center.y - 155 - statusBarHeight, width: 60, height: 60)
            }
        
    }
    
    func initializeViewBasedOnCurrentPage(){
        self.pageControl.currentPage = currentPage
        if joinedParticipants[currentPage].autoConfirm == rideType || joinedParticipants[currentPage].autoConfirm == UserProfile.PREFERRED_ROLE_BOTH{
            self.autoConfirmView.isHidden = false
            self.autoConfirmViewTopConstraint.constant = 10
            self.autoConfirmViewHeightConstraint.constant = 70
        }else{
            self.autoConfirmViewTopConstraint.constant = 0
            self.autoConfirmViewHeightConstraint.constant = 0
            self.autoConfirmView.isHidden = true
        }
        handleVisibilityOfNewUserTextView(rideParticipant: joinedParticipants[currentPage])
        self.rideConfirmedTextView.text = "\(joinedParticipants[currentPage].name!) joined your ride"
        self.pickUpLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: joinedParticipants[currentPage].pickUpTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        
        self.vehicleNameOrNoOFSeats.text = String(joinedParticipants[currentPage].noOfSeats)
        self.seatsLabel.text = "Seat(s)"
        self.pointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: joinedParticipants[currentPage].points!) + " " + Strings.pts
        if joinedParticipants[currentPage].startAddress != nil{
            self.pickUpAddressLabel.text = joinedParticipants[currentPage].startAddress
        }
        if timer == nil{
            if joinedParticipants.count > 1{
              timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(RideJoinConfirmationViewController.moveToNextPage), userInfo: nil, repeats: true)
            }
        }
    }
    @objc func autoConfirmTextTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
        
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: ridePreferences!)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideAutoConfirmationSettingViewController, animated: false)
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        timer?.invalidate()
        self.moveToLiveRideView()
        self.view.removeFromSuperview()
        self.removeFromParent()
        animationView!.stop()
        animationView!.isHidden = true
        RideJoinConfirmationViewController.rideConfirmationDialogue = nil
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        timer?.invalidate()
        self.moveToLiveRideView()
        self.view.removeFromSuperview()
        self.removeFromParent()
        animationView!.stop()
        animationView!.isHidden = true
        RideJoinConfirmationViewController.rideConfirmationDialogue = nil
    }
    
    
    func moveToLiveRideView()
    {
        var isFreezeRideRequired = false
        if Ride.RIDER_RIDE == rideType{
            if MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId!)?.availableSeats == 0
            {
                isFreezeRideRequired = true
            }
        }
        var navigationController : UINavigationController?
        if self.navigationController == nil {
             let centerViewController = ViewControllerUtils.getCenterViewController()
             if centerViewController.navigationController != nil{
                 navigationController = centerViewController.navigationController
             }else{
                 navigationController = (centerViewController as? ContainerTabBarViewController)?.centerNavigationController
             }
         } else {
             navigationController = self.navigationController
         }
        
        navigationController?.popToRootViewController(animated: false)
        ContainerTabBarViewController.indexToSelect = 1
        
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: rideId!, rideObj: nil, isFromRideCreation: false, isFreezeRideRequired: isFreezeRideRequired, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    
    @IBAction func rideEtiquttesButtonClicked(_ sender: Any) {
    
        self.view.removeFromSuperview()
        animationView!.stop()
        animationView!.isHidden = true
        let rideEtiqutteviewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EtiquttesViewController") as! EtiquttesViewController
        rideEtiqutteviewController.initializeDataBeforePresentingView(rideType: rideType!)
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideEtiqutteviewController)
        ViewControllerUtils.getCenterViewController().view.layoutIfNeeded()
    }
    
}
