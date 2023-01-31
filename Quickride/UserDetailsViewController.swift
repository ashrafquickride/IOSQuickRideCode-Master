//
//  UserDetailsViewController.swift
//  Quickride
//
//  Created by Admin on 22/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI


class UserDetailsViewController : UIViewController,UserBlockReceiver,UserUnBlockReceiver,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var vehicleDetailsView: UIView!
    
    @IBOutlet weak var ratingsViewTitle: UILabel!
    
    @IBOutlet weak var ratingsLbl: UILabel!
    
    @IBOutlet weak var noOfReviewsLbl: UILabel!
    
    @IBOutlet weak var seatsOrOnTimeImageView: UIImageView!
    
    @IBOutlet weak var seatsOrOntimePercentageLbl: UILabel!
    
    @IBOutlet weak var seatsOrOnTimeTxtLbl: UILabel!
    
    @IBOutlet weak var vehicleDetailsViewHeightConstra: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleDetailsViewTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vehicleModelLbl: UILabel!
    
    @IBOutlet weak var vehicleNumberLbl: UILabel!
    
    @IBOutlet weak var vehicleImageLbl: UIImageView!
    
    @IBOutlet weak var rideNotesView: UIView!
    
    @IBOutlet weak var rideNotesViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideNotesLbl: UILabel!
    
    @IBOutlet weak var rideEtiquitesImage: UIImageView!
    
    @IBOutlet weak var rateAUserLbl: UILabel!
    
    @IBOutlet weak var blockAUserLbl: UILabel!

    @IBOutlet weak var rateUserView: UIView!
    
    @IBOutlet weak var reportProfileView: UIView!
    
    @IBOutlet weak var blockUserView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var actionView: UIView!
   
    @IBOutlet weak var rideNotesViewTopSpaceConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var ecometerView: UIView!
    
    
    var matchedUser : MatchedUser?
    
    func initializeDataBeforePresenting(matchedUser : MatchedUser){
        self.matchedUser = matchedUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleRatingsView()
        handleOnTimeOrSeatsView()
        handleVehicleDetailsView()
        handleRideNotesView()
        rateAUserLbl.text = Strings.rate + " " + (matchedUser!.name ?? "")
        handleSettingTitleForBlockView()
        rateUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.rateAUserViewClicked(_:))))
        blockUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.blockUserClicked(_:))))
        reportProfileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.reportProfileClicked(_:))))
        ecometerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.ecoMeterViewClicked(_:))))
          self.automaticallyAdjustsScrollViewInsets = false
    }
      override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 50)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: rateUserView, cornerRadius: 8.0, corner1: .topLeft, corner2: .topRight)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: blockUserView, cornerRadius: 8.0, corner1: .bottomLeft, corner2: .bottomRight)
        actionView.dropShadow(color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 5.0, scale: true, cornerRadius: 8.0)
      }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func handleRatingsView(){
        if self.matchedUser?.userRole == MatchedUser.RIDER{
           ratingsViewTitle.text = Strings.ratings_onTime
           
        }else{
          ratingsViewTitle.text = Strings.ratings_seats
        }
        
        if matchedUser!.rating != nil{
           ratingsLbl.text =  String(matchedUser!.rating!)
           noOfReviewsLbl.text = "(" + String(matchedUser!.noOfReviews) + ")"
        }else{
          ratingsLbl.text =  Strings.NA
          noOfReviewsLbl.text = ""
        }
     }
    
    func handleOnTimeOrSeatsView(){
        if (self.matchedUser?.userRole == MatchedUser.RIDER || matchedUser?.userRole == MatchedUser.REGULAR_RIDER){
          
            if (matchedUser?.userOnTimeComplianceRating != nil && matchedUser?.userOnTimeComplianceRating?.isEmpty == false){
                
                seatsOrOnTimeImageView.image = UIImage(named: "alarm")
               seatsOrOntimePercentageLbl.text = matchedUser!.userOnTimeComplianceRating! + " " + Strings.percentage_symbol
               seatsOrOnTimeTxtLbl.text = Strings.onTime
            }else{
                seatsOrOntimePercentageLbl.text = Strings.NA
                seatsOrOnTimeTxtLbl.text = ""
            }
        }else{
            seatsOrOnTimeTxtLbl.text = Strings.seats
            seatsOrOnTimeImageView.image = UIImage(named: "seats")
            if matchedUser?.userRole == MatchedUser.PASSENGER{
                seatsOrOntimePercentageLbl.text = String((matchedUser as! MatchedPassenger).requiredSeats)
            }else{
                seatsOrOntimePercentageLbl.text = String((matchedUser as! MatchedRegularPassenger).noOfSeats)
            }
        }
    }
    
    func handleVehicleDetailsView(){
        if matchedUser?.userRole == MatchedUser.RIDER || matchedUser?.userRole == MatchedUser.REGULAR_RIDER{
            vehicleDetailsView.isHidden = false
            vehicleDetailsViewHeightConstra.constant = 100
            vehicleDetailsViewTopSpaceConstraint.constant = 20
            var vehicleType: String?
            if matchedUser?.userRole == MatchedUser.RIDER {
                if let model = (matchedUser as! MatchedRider).model {
                    vehicleModelLbl.text = model
                } else if let vehicleNumber = (matchedUser as! MatchedRider).vehicleNumber {
                    vehicleNumberLbl.text = vehicleNumber
                } else if let type = (matchedUser as! MatchedRider).vehicleType {
                    vehicleType = type
                }
            }else{
                if let model = (matchedUser as! MatchedRegularRider).model {
                    vehicleModelLbl.text = model
                } else if let vehicleNumber = (matchedUser as! MatchedRegularRider).vehicleNumber {
                    vehicleNumberLbl.text = vehicleNumber
                } else if let type = (matchedUser as! MatchedRegularRider).vehicleType {
                    vehicleType = type
                }
            }
            checkVehicleTypeAndSetImageVehicle(vehicleType: vehicleType)
        }else{
            vehicleDetailsView.isHidden = true
            vehicleDetailsViewHeightConstra.constant = 0
            vehicleDetailsViewTopSpaceConstraint.constant = 0
        }
    }
    
    func checkVehicleTypeAndSetImageVehicle(vehicleType: String?){
        if vehicleType == Vehicle.VEHICLE_TYPE_CAR{
           vehicleImageLbl.image = UIImage(named: "car_new")
        } else if vehicleType == Vehicle.VEHICLE_TYPE_BIKE {
           vehicleImageLbl.image = UIImage(named: "vehicle_type_bike_grey")
        }
    }
    
    func handleRideNotesView(){
        if matchedUser!.rideNotes != nil && !matchedUser!.rideNotes!.isEmpty{
            rideNotesView.isHidden = false
            rideNotesViewHeightConstraint.constant = 140
            rideNotesViewTopSpaceConstraint.constant = 20
            rideNotesLbl.text = matchedUser!.rideNotes!
        }else{
            rideNotesView.isHidden = true
            rideNotesViewHeightConstraint.constant = 0
            rideNotesViewTopSpaceConstraint.constant = 0
            
        }
    }
    
    @objc func rateAUserViewClicked(_ gesture : UITapGestureRecognizer){
        let viewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
        viewController.initializeDataAndPresent(name: matchedUser!.name!,imageURI: matchedUser!.imageURI,gender: matchedUser!.gender!,userId: matchedUser!.userid!, rideId: nil)
        self.view.addSubview(viewController.view)
        self.addChild(viewController)
    }
    @objc func reportProfileClicked(_ gesture : UITapGestureRecognizer){
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        let userProfile = UserDataCache.getInstance()?.userProfile
        var subject = ""
        if userProfile?.userName != nil{
            subject = subject+(userProfile?.userName)!
        }
        if userProfile?.userId != nil{
            subject = subject + "(\(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId)))" + "-" + "found something wrong with "
        }
        
      subject = subject + matchedUser!.name! + "'s " + "(" + String(matchedUser!.userid!) + ")" + "profile :"
 
        
        
        HelpUtils.sendEmailToSupportWithSubject(delegate: self, viewController: self, messageBody: nil, image: image, listOfIssueTypes: Strings.list_of_report_profile_types, subject: subject, reciepients: nil)
    }
    @objc func blockUserClicked(_ gesture : UITapGestureRecognizer){
        if blockAUserLbl.text == Strings.block + " " + matchedUser!.name!
        {
            let textViewAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "TextViewAlertController") as! TextViewAlertController
            textViewAlertController.initializeDataBeforePresentingView(title: Strings.confirm_block + " " + matchedUser!.name!+" ?", positiveBtnTitle: Strings.no_caps, negativeBtnTitle: Strings.yes_caps, placeHolder: Strings.placeholder_reason, textAlignment: NSTextAlignment.left, isCapitalTextRequired: false, isDropDownRequired: true, dropDownReasons: Strings.block_reason_list, existingMessage: nil,viewController: self, handler: { (text, result) in
                if Strings.yes_caps == result
                {
                    let reason = text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if reason!.count == 0{
                        MessageDisplay.displayAlert(messageString: Strings.suspend_reason,  viewController: self,handler: nil)
                        return
                    }
                    UserBlockTask.blockUser(phoneNumber: self.matchedUser!.userid!, viewController : self, receiver: self, isContactNumber : false, reason: text)
                }
            })
             self.view.addSubview(textViewAlertController.view!)
             self.addChild(textViewAlertController)
        }
        else if blockAUserLbl.text == Strings.unblock + " " + matchedUser!.name!
        {
            UserUnBlockTask.unBlockUser(phoneNumber:  matchedUser!.userid!,viewController : self, receiver: self)
        }
    }
    
    func handleSettingTitleForBlockView(){
        blockUserView.isHidden = false
        let blockedUserList  = UserDataCache.getInstance()!.getAllBlockedUsers()
        
        var isUserBlocked = false
        for blockedUser in blockedUserList
        {
            if(blockedUser.blockedUserId == self.matchedUser!.userid)
            {
                isUserBlocked = true
            }
        }
        if(isUserBlocked)
        {
            blockAUserLbl.text = Strings.unblock + " " + matchedUser!.name!
        }
        else
        {
            blockAUserLbl.text = Strings.block + " " + matchedUser!.name!
         }
    }
    
    func userUnBlocked() {
        handleSettingTitleForBlockView()
    }
    
    func userBlocked() {
         handleSettingTitleForBlockView()
    }
    
    func userBlockingFailed(responseError: ResponseError) {
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: nil, viewController: self)
    }
    
    @IBAction func arrowBtnClicked(_ sender: Any) {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    @objc func ecoMeterViewClicked(_ gesture : UITapGestureRecognizer){
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        let ecoMeterVC : NewEcoMeterViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewEcoMeterViewController") as! NewEcoMeterViewController
        ecoMeterVC.initializeDataBeforePresenting(userId: String(matchedUser!.userid!), userName: matchedUser!.name!,imageUrl: matchedUser?.imageURI, gender: matchedUser!.gender!)
        self.navigationController?.pushViewController(ecoMeterVC, animated: false)
    }
    
}
