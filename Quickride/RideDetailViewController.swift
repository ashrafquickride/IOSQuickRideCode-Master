//
//  RideDetailViewController
//  Quickride
//
//  Created by QuickRide on 11/14/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper
import Polyline



class RideDetailViewController: BaseRideDetailViewController{
    
    @IBOutlet var routeMatchPercentage: UILabel!
    
    @IBOutlet var connectedPassengersViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lastResponseTimeLabel: UILabel!
    
    @IBOutlet weak var lastResponseImageView: UIImageView!
    
    @IBOutlet weak var lastResponseImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftView: UIView!
   
    @IBOutlet weak var rightView: UIView!

    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var safeKeeperButton: UIButton!
    
    var displayedToast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if matchedUsersList.count > 1{
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RideDetailViewController.swiped(_:)))
            leftSwipe.direction = .left
            userDetailView.addGestureRecognizer(leftSwipe)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RideDetailViewController.swiped(_:)))
            rightSwipe.direction = .right
            userDetailView.addGestureRecognizer(rightSwipe)
            leftView.isHidden = false
            rightView.isHidden = false
         }else{
            leftView.isHidden = true
            rightView.isHidden = true
        }
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideDetailViewController.bottomViewClicked(_:))))
        lastResponseImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideDetailViewController.displayLastResponseAlert(_:))))
        lastResponseTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideDetailViewController.displayLastResponseAlert(_:))))
    }

        func setDataToViewBasedOnSelectedIndex(){
           
            if selectedIndex == 0{
                leftView.isHidden = true
           
            }else{
                leftView.isHidden = false
            }
            
            if selectedIndex == matchedUsersList.count - 1{
                rightView.isHidden = true
            }else{
                rightView.isHidden = false
            }
            
            
            let matchedUser = matchedUsersList[selectedIndex]
            if  matchedUser.enableChatAndCall == false{
                chatButton.isHidden = true
            }else if (matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER)  && !RideManagementUtils.getUserQualifiedToDisplayContact(){
                chatButton.isHidden = true
                if !displayedToast{
                    displayedToast = true
                    let modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
                    modelLessDialogue.initializeViews(message: Strings.no_balance_reacharge_toast, actionText: Strings.link_caps)
                    let position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height*2/3)
                    self.view.showToast(toast: modelLessDialogue, duration: 10.0, position: position, completion: { (didTap) -> Void in
                        if didTap == true{
                            ContainerTabBarViewController.indexToSelect = 3
                            self.navigationController?.popToRootViewController(animated: false)
                        }
                    })
                }
            }else{
                chatButton.isHidden = false
            }
            
            checkAndSetActionButtonTitle()
            
            if matchedUsersList[selectedIndex].lastResponseTime == 0{
               self.lastResponseImageView.isHidden = true
               self.lastResponseTimeLabel.isHidden = true
               self.lastResponseImageHeightConstraint.constant = 0
            }
            else{
                self.lastResponseImageView.isHidden = false
                self.lastResponseTimeLabel.isHidden = false
                self.lastResponseImageHeightConstraint.constant = 15
                let days = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: NSDate(timeIntervalSince1970: matchedUsersList[selectedIndex].lastResponseTime/1000))
                if days == 0 {
                    self.lastResponseTimeLabel.text = "Today"
                } else if days == 1 {
                    self.lastResponseTimeLabel.text = "1 day ago"
                } else{
                    self.lastResponseTimeLabel.text = "\(days)" + " days ago"
                }
            }

            checkAndSetMatchingPercentage(matchedUser: matchedUsersList[selectedIndex], ride: ride!)
            setWidthToRideDetailViews()
            setMatchedPercentage()
            checkAndSetPickUpAndDropAddress()
            checkAndSetPickupTimeText(matchedUser: matchedUsersList[selectedIndex], ride: ride)
            if FareChangeUtils.isFareChangeApplicable(matchedUser: matchedUsersList[selectedIndex]){
                
                self.matchedUserPoints.textColor = Colors.editRouteBtnColor
                self.fareLabelHeading.textColor = Colors.editRouteBtnColor
                self.fareView.isUserInteractionEnabled = true
                self.fareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideDetailViewController.fareChangeTapped(_:))))
            }else{
                self.fareView.isUserInteractionEnabled = false
                self.matchedUserPoints.textColor = UIColor.black
                self.fareLabelHeading.textColor = UIColor(netHex:0x000000)
            }
            checkAndSetPointsText()
            
            ImageCache.getInstance().setImageToView(imageView: matchedUserImage, imageUrl: matchedUsersList[selectedIndex].imageURI, gender: (matchedUsersList[selectedIndex].gender)!,imageSize: ImageCache.DIMENTION_TINY)
            matchedUserImage.isUserInteractionEnabled = true
            matchedUserImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseRideDetailViewController.ibaTakeToProfile(_:))))
            matchedUserName.text = matchedUsersList[selectedIndex].name
            if matchedUsersList[selectedIndex].userRole == Ride.RIDER_RIDE && (matchedUsersList[selectedIndex] as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                bikeImageOnUserImage.isHidden = false
            }else{
                bikeImageOnUserImage.isHidden = true
            }
            
            let currentDateDayString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM)
            let scheduleDateDayString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUsersList[selectedIndex].startDate!, timeFormat: DateUtils.DATE_FORMAT_dd_MMM)
            
            
            if currentDateDayString == scheduleDateDayString{
                startTimeViewWidthConstraint.constant = 120
                matchedUserStartTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUsersList[selectedIndex].startDate!, timeFormat:  DateUtils.TIME_FORMAT_hhmm_a)
            }else{
                startTimeViewWidthConstraint.constant = 160
                matchedUserStartTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUsersList[selectedIndex].startDate!, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_H_mm)
            }
            
        
            checkAndSetPointsText()
            checkForRideStatusStartedAndSetStatusLabel()
            checkAndDisplayGuideLineScreen()
            checkAndDisplayMatchedPassengers()
            setVerificationLabel()
            
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: matchedUsersList[selectedIndex].userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                self.isRidePartner = true
            }
            if matchedUsersList[selectedIndex].userRole == MatchedUser.RIDER || matchedUsersList[selectedIndex].userRole == MatchedUser.REGULAR_RIDER{
                checkForRidePresentLocation()
            }
            drawRouteOnMap()
            handleModeratorView()
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil {
                clientConfiguration = ClientConfigurtion()
            }
            if clientConfiguration!.showCovid19SelfAssessment ?? false && matchedUsersList[selectedIndex].hasSafeKeeperBadge {
                safeKeeperButton.isHidden = false
            } else {
                safeKeeperButton.isHidden = true
            }
        }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ViewCustomizationUtils.addCornerRadiusToView(view: changePickupDropButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: joinButton, cornerRadius: 3.0)
        userDetailView.addShadow()
        connectedPassengersView.addShadow()
        leftView.addShadow()
        rightView.addShadow()
        chatButton.addShadow()
        rejectButton.addShadow()
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: bottomView, cornerRadius: 10.0, corner1: .topLeft, corner2: .topRight)
        ViewCustomizationUtils.addCornerRadiusToView(view: connectedPassengersView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: userDetailView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: startTimeView, cornerRadius: 3)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: leftView, cornerRadius: 10.0, corner1: .bottomRight, corner2: .topRight)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: rightView, cornerRadius: 10.0, corner1: .topLeft, corner2: .bottomLeft)
        setDataToViewBasedOnSelectedIndex()
        ViewCustomizationUtils.addCornerRadiusToView(view: self.joinButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.rejectButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.chatButton, cornerRadius: 5.0)
        
        setGradient()
    }

    private func handleModeratorView() {
        if let rideUserId = ride?.userId, rideUserId != 0, let currentUserId = Double(QRSessionManager.getInstance()?.getUserId() ?? "0"), currentUserId != 0, rideUserId != currentUserId {
            self.fareView.isUserInteractionEnabled = false
            self.matchedUserPoints.textColor = UIColor.black
            self.fareLabelHeading.textColor = UIColor(netHex:0x000000)
            changePickupDropButton.isHidden = true
        }
    }
    override func handleJoinButtonHeight(height : Int){
        joinButtonHeightConstraint.constant = CGFloat(height)
        setMatchedUserDetailsHeight()
    }
    @objc func swiped(_ gesture : UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("swiped()")
        if gesture.direction == .left{
           
            if selectedIndex != matchedUsersList.count - 1{
                userDetailView.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
            selectedIndex += 1
            if selectedIndex > matchedUsersList.count - 1{
                selectedIndex = matchedUsersList.count - 1
            }
        }else if gesture.direction == .right{
           
            if selectedIndex != 0{
                userDetailView.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
            selectedIndex -= 1
            if selectedIndex < 0{
                selectedIndex = 0
            }
        }
        
        setDataToViewBasedOnSelectedIndex()
    }
    
    override func setMatchedUserDetailsHeight(){
        
        if joinButton.isHidden && rejectButton.isHidden{
            joinButtonHeightConstraint.constant = 0
            contactBtnWidthConstraint.constant = userDetailView.frame.width - 35
            chatButton.bounds.size.width = userDetailView.frame.width - 35
        }
        
       if joinButton.isHidden && chatButton.isHidden{
            joinButtonHeightConstraint.constant = 0
            if self.lastResponseImageView.isHidden{
                userDetailsViewHeight.constant = 130
            }
            else{
                userDetailsViewHeight.constant = 140
            }
        }else if connectedPassengersView.isHidden  {
            connectedPassengersViewHeight.constant = 0
            UserDetailsTopSpaceConstraint.constant = 0
            joinButtonHeightConstraint.constant = 35
            if self.lastResponseImageView.isHidden{
                userDetailsViewHeight.constant = 145
            }
            else{
                userDetailsViewHeight.constant = 160
            }
            
        }
        else{
            connectedPassengersViewHeight.constant = 90
            UserDetailsTopSpaceConstraint.constant = 10
            joinButtonHeightConstraint.constant = 35
            if self.lastResponseImageView.isHidden{
                userDetailsViewHeight.constant = 150
            }
            else{
                userDetailsViewHeight.constant = 160
            }
        }
    }
    override func setMatchedPercentage() {
        let matchedPercentage = "\(matchedUsersList[selectedIndex].matchPercentage!)"

        if(matchedUsersList[selectedIndex].userRole == MatchedUser.PASSENGER && matchedUsersList[selectedIndex].matchPercentageOnMatchingUserRoute != 0){
            self.routeMatchPercentage.text = matchedPercentage + "(" + String(describing: matchedUsersList[selectedIndex].matchPercentageOnMatchingUserRoute) + ")" + Strings.percentage_symbol + " " + Strings.route_match
        }else{
            self.routeMatchPercentage.text = matchedPercentage + Strings.percentage_symbol + " " + Strings.route_match
        }
    }
    
    @objc func bottomViewClicked(_ gesture : UITapGestureRecognizer){
        let userDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        userDetailsViewController.initializeDataBeforePresenting(matchedUser: matchedUsersList[selectedIndex])
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(userDetailsViewController, animated: false)
    }
    
    @objc func displayLastResponseAlert(_ gesture : UITapGestureRecognizer){
        let lastResponseAlertView = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LastResponseAlertView") as! LastResponseAlertView
        self.navigationController?.view.addSubview(lastResponseAlertView.view)
        self.navigationController?.addChild(lastResponseAlertView)
    }
    
}
