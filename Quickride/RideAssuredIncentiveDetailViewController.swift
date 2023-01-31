//
//  RideAssuredIncentiveDetailViewController.swift
//  Quickride
//
//  Created by Admin on 03/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideAssuredIncentiveDetailViewController : UIViewController,UIScrollViewDelegate{

    @IBOutlet weak var assuredAmountLbl: UILabel!
    
    @IBOutlet weak var activatedView: UIView!
    
    @IBOutlet weak var fromAddressLbl: UILabel!
    
    @IBOutlet weak var toAddressLbl: UILabel!
    
    @IBOutlet weak var activateBtn: UIButton!
    
    @IBOutlet weak var daysAndRidesLeftLbl: UILabel!
   
    @IBOutlet weak var daysAndRidesLeftLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var TermsAndConditionLbl: UILabel!
    
    @IBOutlet weak var StartTimeLbl: UILabel!
    
    @IBOutlet weak var leaveTimeLbl: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var daysAndRidesLeftImageView: UIImageView!
    
    @IBOutlet weak var rideAssuredImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createRideBtn: UIButton!
    
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonView: UIView!

    
    @IBOutlet weak var addressDesclbl1: UILabel!
    
    @IBOutlet weak var addressDesclbl2: UILabel!

    @IBOutlet weak var noOfDaysLbl: UILabel!
    
    var rideAssuredIncentive : RideAssuredIncentive?
    var handler : rideAssuredIncentiveActivationCompletionHandler?
    var termsAndCondtions = [String]()
    
    
    func initializeDataBeforePresenting(rideAssuredIncentive : RideAssuredIncentive?,handler : @escaping rideAssuredIncentiveActivationCompletionHandler){
        self.rideAssuredIncentive = rideAssuredIncentive
        self.handler = handler
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        scrollView.delegate = self
        fromAddressLbl.text = rideAssuredIncentive!.fromAddress
        toAddressLbl.text = rideAssuredIncentive!.toAddress
        StartTimeLbl.text = DateUtils.getLocalTimeFromUTC(date: rideAssuredIncentive!.startTime)
        leaveTimeLbl.text = DateUtils.getLocalTimeFromUTC(date: rideAssuredIncentive!.leaveTime)
        addressDesclbl1.text = Strings.onward_ride_assured_incentive
        addressDesclbl2.text = Strings.return_ride_assured_incentive
        noOfDaysLbl.text = String(DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: rideAssuredIncentive!.validTo/1000), date2: NSDate(timeIntervalSince1970: rideAssuredIncentive!.validFrom/1000)))+" "+Strings.days
        let homeLocation = UserDataCache.getInstance()!.getHomeLocation()
        let officeLocation = UserDataCache.getInstance()!.getOfficeLocation()
        if (homeLocation != nil && officeLocation != nil) {
            
            let homeDistanceToStart = LocationClientUtils.getDistance(fromLatitude: homeLocation!.latitude!, fromLongitude: homeLocation!.longitude!, toLatitude: rideAssuredIncentive!.fromLat, toLongitude: rideAssuredIncentive!.fromLng)
    
            let officeDistanceToEnd = LocationClientUtils.getDistance(fromLatitude: officeLocation!.latitude!, fromLongitude: officeLocation!.longitude!, toLatitude: rideAssuredIncentive!.toLat, toLongitude: rideAssuredIncentive!.toLng)
            
            if homeDistanceToStart <= 100 && officeDistanceToEnd <= 100 {
                
                addressDesclbl1.text = Strings.home_to_office
                addressDesclbl2.text = Strings.office_to_home
                fromAddressLbl.text = rideAssuredIncentive!.fromAddress
                toAddressLbl.text = rideAssuredIncentive!.toAddress
            }
            
            let homeDistanceToEnd = LocationClientUtils.getDistance(fromLatitude: homeLocation!.latitude!, fromLongitude: homeLocation!.longitude!, toLatitude: rideAssuredIncentive!.toLat, toLongitude: rideAssuredIncentive!.toLng)
    
            let officeDistanceToStart = LocationClientUtils.getDistance(fromLatitude: officeLocation!.latitude!, fromLongitude: officeLocation!.longitude!, toLatitude: rideAssuredIncentive!.fromLat, toLongitude: rideAssuredIncentive!.fromLng)
    
            if homeDistanceToEnd <= 100 && officeDistanceToStart <= 100 {
                addressDesclbl1.text = Strings.home_to_office
                addressDesclbl2.text = Strings.office_to_home
                fromAddressLbl.text = rideAssuredIncentive!.toAddress
                toAddressLbl.text = rideAssuredIncentive!.fromAddress
            }
        }
        initializeDaysAndRidesLeftView()
        assuredAmountLbl.text = String(format: Strings.assured_incentive_amount, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: rideAssuredIncentive!.amountAssured)])
        
        TermsAndConditionLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideAssuredIncentiveDetailViewController.termsAndConditionViewTapped(_:))))
    }
    
    func initializeDaysAndRidesLeftView(){
        if rideAssuredIncentive!.status == RideAssuredIncentive.INCENTIVE_STATUS_ACTIVE{
            self.activatedView.isHidden = false
            self.daysAndRidesLeftLbl.isHidden = false
            self.daysAndRidesLeftLblHeightConstraint.constant = 30

            let ridesLeft = rideAssuredIncentive!.totalRides - rideAssuredIncentive!.completedRides
            let daysLeft = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: rideAssuredIncentive!.validTo/1000), date2: NSDate())
           
            if ridesLeft <= 0{
                daysAndRidesLeftImageView.image = UIImage(named : "time_green")
                if daysLeft <= 0{
                   daysAndRidesLeftLbl.text = Strings.rides_completed_assured_incentive_no_days_left
                }else if daysLeft == 1{
                    daysAndRidesLeftLbl.text = String(format: Strings.one_day_left_and_rides_completed_assured_incentive, arguments: [String(daysLeft)])
                }else{
                    daysAndRidesLeftLbl.text = String(format: Strings.days_left_and_rides_completed_assured_incentive, arguments: [String(daysLeft)])
                }
                
                let attributedString = NSMutableAttributedString(string: daysAndRidesLeftLbl.text!)
                attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x00B557), textSize: 14), range: (daysAndRidesLeftLbl.text! as NSString).range(of: "Minimum Rides Completed"))
                daysAndRidesLeftLbl.attributedText = attributedString
                
            }else{
                daysAndRidesLeftImageView.image = UIImage(named : "time_red")
                if daysLeft <= 0{
                    if ridesLeft == 1{
                       daysAndRidesLeftLbl.text = String(format: Strings.days_not_left_one_ride_left_assured_incentive, arguments: [String(ridesLeft)])
                    }else{
                      daysAndRidesLeftLbl.text = String(format: Strings.days_not_left_rides_left_assured_incentive, arguments: [String(ridesLeft)])
                    }
                    
                }else if daysLeft == 1{
                    if ridesLeft == 1{
                        daysAndRidesLeftLbl.text = String(format: Strings.one_day_left_and_one_ride_left_assured_incentive, arguments: [String(ridesLeft),String(daysLeft)])
                    }else{
                        daysAndRidesLeftLbl.text = String(format: Strings.one_day_left_and_rides_left_assured_incentive, arguments: [String(ridesLeft),String(daysLeft)])
                    }
                    
                }else{
                    daysAndRidesLeftLbl.text = String(format: Strings.days_and_rides_left_assured_incentive, arguments: [String(ridesLeft),String(daysLeft)])
                }
                
            }
            
            self.activateBtn.isHidden = true
            self.activateBtn.isUserInteractionEnabled = false
            self.createRideBtn.isHidden = false
            self.createRideBtn.isUserInteractionEnabled = true
            self.rideAssuredImageViewHeightConstraint.constant = 290
            self.scrollViewHeightConstraint.constant = 265
        }else{
            self.activatedView.isHidden = true
            self.daysAndRidesLeftLbl.isHidden = true
            self.daysAndRidesLeftLblHeightConstraint.constant = 0
            self.activateBtn.isHidden = false
            self.activateBtn.isUserInteractionEnabled = true
            self.createRideBtn.isHidden = true
            self.createRideBtn.isUserInteractionEnabled = false
            self.rideAssuredImageViewHeightConstraint.constant = 250
            self.scrollViewHeightConstraint.constant = 305
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: activatedView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: activateBtn, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: createRideBtn, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: detailsView, cornerRadius: 20.0, corner1: .topLeft, corner2: .topRight)
        CustomExtensionUtility.changeBtnColor(sender: activateBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: createRideBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        self.automaticallyAdjustsScrollViewInsets = false
        buttonView.addShadow()
    }
    

    @IBAction func activateBtnClicked(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.subscribeForRideAssuredIncentive(rideAssuredIncentiveData: rideAssuredIncentive!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.rideAssuredIncentive = Mapper<RideAssuredIncentive>().map(JSONObject: responseObject!["resultData"])
                self.initializeDaysAndRidesLeftView()
                self.showActivatedAlert()
                self.handler?(self.rideAssuredIncentive!)
                SharedPreferenceHelper.storeRideAssuredIncentive(rideAssuredIncentive: nil)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
        
    }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func showActivatedAlert(){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: String(format: Strings.ride_assurance_incentive_offer_activated, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: rideAssuredIncentive!.amountAssured)]), isFromLinkedWallet: false, handler: nil)
        let centerController = ViewControllerUtils.getCenterViewController()
        if centerController.navigationController != nil{
            centerController.view.addSubview(animationAlertController.view!)
            centerController.navigationController!.addChild(animationAlertController)
        }else{
            centerController.view.addSubview(animationAlertController.view!)
            centerController.addChild(animationAlertController)
        }
        animationAlertController.view!.layoutIfNeeded()
    }
    
    @objc func termsAndConditionViewTapped(_ gesture : UITapGestureRecognizer){
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTermsAndConditionsViewController") as! ShowTermsAndConditionsViewController
        showTermsAndConditionsViewController.initializeDataBeforePresenting(termsAndConditions: prefereTermsAndConditions(), titleString: Strings.terms_and_conditions)
        let displayViewController  = ViewControllerUtils.getCenterViewController()
        
        if displayViewController.navigationController != nil {
            displayViewController.navigationController!.view.addSubview(showTermsAndConditionsViewController.view!)
            displayViewController.navigationController!.addChild(showTermsAndConditionsViewController)
        }
        else
        {
            displayViewController.view.addSubview(showTermsAndConditionsViewController.view)
            displayViewController.addChild(showTermsAndConditionsViewController)
        }
        showTermsAndConditionsViewController.view!.layoutIfNeeded()
        
    }
    
    @IBAction func createRidebtnClicked(_ sender: Any) {
            let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
            ContainerTabBarViewController.indexToSelect = 1
             let centerNavigationController = UINavigationController(rootViewController: routeViewController)
            AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController

    }
    func prefereTermsAndConditions() -> [String] {
        var fromAddress = String(rideAssuredIncentive!.fromAddress!.prefix(25))
        fromAddress.append("...")
        var toAddress = String(rideAssuredIncentive!.toAddress!.prefix(25))
        toAddress.append("...")
         let termsAndConditions = [String(format: Strings.ride_assured_incentive_condition1, arguments: [fromAddress,toAddress,DateUtils.getLocalTimeFromUTC(date: rideAssuredIncentive!.startTime),DateUtils.getLocalTimeFromUTC(date: rideAssuredIncentive!.leaveTime)]),String(format: Strings.ride_assured_incentive_condition2, arguments: [String(rideAssuredIncentive!.totalRides)]),Strings.ride_assured_incentive_condition3,Strings.ride_assured_incentive_condition4,Strings.ride_assured_incentive_condition5,Strings.ride_assured_incentive_condition6,Strings.ride_assured_incentive_condition7,Strings.ride_assured_incentive_condition8,Strings.ride_assured_incentive_condition9,Strings.ride_assured_incentive_condition10,Strings.ride_assured_incentive_condition11,Strings.ride_assured_incentive_condition12]
        return termsAndConditions
    }
    
}
