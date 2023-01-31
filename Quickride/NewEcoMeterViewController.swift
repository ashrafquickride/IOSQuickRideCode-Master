//
//  NewEcoMeterViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/01/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import  UIKit
import ObjectMapper
class NewEcoMeterViewController : UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var friendsMade: UILabel!
    
    @IBOutlet weak var noOfRidesShared: UILabel!
    
    @IBOutlet weak var ridesSharedLblTxt: UILabel!
   
    @IBOutlet weak var amountOfCo2Removed: UILabel!
    
    @IBOutlet weak var distanceSharedLblText: UILabel!
   
    @IBOutlet weak var totalDistanceShared: UILabel!

    @IBOutlet weak var friendsMadeLblText: UILabel!
    
    
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var moreBtnImageView: UIButton!
    
    @IBOutlet weak var amountSavedViewHeightConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var categoryText: UILabel!
   
    @IBOutlet weak var amountSavedView: UIView!
    
    @IBOutlet weak var moreBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    @IBOutlet weak var spreadTheWordLbl: UILabel!
    
    @IBOutlet weak var makeADiffTxtLbl: UILabel!
    
    
    @IBOutlet weak var categoryBanyanImage: UIImageView!
    
    
    @IBOutlet weak var amountSavedLblTxt: UILabel!
    
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var amountSavedViewTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var quickrideLogoView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var shareBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var spreadLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var diffLblHeightConstrainty: NSLayoutConstraint!
    
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var leavesImageView: UIImageView!
    
    @IBOutlet weak var userImageView: CircularImageView!
    
    @IBOutlet weak var userImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userNameLblLeadingSpaceConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var ecometerTitleLbl: UILabel!
    
    
    static let TOTAL_NO_OF_RIDES_TODISPLAY_OFFERS = 50
    static let REQUIRED_NO_OF_RIDES = 50
    
    var rideSharingCommunityContribution : RideSharingCommunityContribution?
    var userId : String? = QRSessionManager.getInstance()?.getUserId()
    var userName : String? = UserDataCache.getInstance()?.getUserName()
    var imageUrl : String?
    var showAmountSavedView = false
    var gender : String?
    private var  modelLessDialogue: ModelLessDialogue?

    func initializeDataBeforePresenting(userId : String, userName: String,imageUrl : String?,gender : String){
        self.userId = userId
        self.userName = userName
        self.imageUrl = imageUrl
        self.gender = gender
    }

    override func viewDidLoad() {
        definesPresentationContext = true
        if userId == QRSessionManager.getInstance()?.getUserId(){
           self.imageUrl = UserDataCache.getInstance()?.userProfile?.imageURI
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ECO_METER_VIEWED, params: ["userId": userId], uniqueField: User.FLD_USER_ID)
           self.gender = UserDataCache.getInstance()?.getLoggedInUserProfile()?.gender
        }
        nameLabel.text = self.userName
        amountOfCo2Removed.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewEcoMeterViewController.infoViewClicked(_:))))
        categoryText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewEcoMeterViewController.infoViewClicked(_:))))
        callRideSharingCommunityContributionGettingTask()
        amountSavedView.isHidden = true
        amountSavedViewHeightConstraint.constant = 0
        amountSavedViewTopSpaceConstraint.constant = 0
        self.quickrideLogoView.isHidden = true
        self.shareBtn.layer.shadowColor = UIColor.black.cgColor
        self.shareBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.shareBtn.layer.shadowOpacity = 0.3
        shareBtn.addTarget(self, action:#selector(NewEcoMeterViewController.HoldGotItBtn(_:)), for: UIControl.Event.touchDown)
        shareBtn.addTarget(self, action:#selector(NewEcoMeterViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func HoldGotItBtn(_ sender:UIButton)
    {
        if categoryText.text == Strings.category_level_bamboo{
           shareBtn.backgroundColor = UIColor.green
        }else{
          shareBtn.backgroundColor = UIColor.orange
        }
    }
    @objc func HoldRelease(_ sender:UIButton){
        
        if categoryText.text == Strings.category_level_bamboo{
            shareBtn.backgroundColor = UIColor(netHex: 0x00b557)
        }else{
            shareBtn.backgroundColor = UIColor(netHex: 0xf7aa3c)
        }
    }
    
    func setColorToViewsForCategoryNotPresent(){
           setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "down arrow")!, category : RideSharingCommunityContribution.USER_CATEGORY_SILVER)
            self.view.backgroundColor = UIColor.white
            self.nameLabel.textColor = UIColor(netHex: 0x333333)
            self.amountOfCo2Removed.textColor = UIColor(netHex: 0xbbc209)
            self.noOfRidesShared.textColor = UIColor(netHex: 0x333333)
            self.ridesSharedLblTxt.textColor = UIColor(netHex: 0x878a89)
            self.totalDistanceShared.textColor = UIColor(netHex: 0x333333)
            self.distanceSharedLblText.textColor = UIColor(netHex: 0x878a89)
            self.friendsMade.textColor = UIColor(netHex: 0x333333)
            self.friendsMadeLblText.textColor = UIColor(netHex: 0x878a89)
            self.amountLabel.textColor = UIColor(netHex: 0x333333)
            self.amountSavedLblTxt.textColor = UIColor(netHex: 0x878a89)
            self.backgroundImageView.isHidden = true
            self.categoryBanyanImage.isHidden = true
            self.leavesImageView.isHidden = false
            self.leavesImageView.image =  UIImage(named: "leaf")
            self.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x474747),
                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!]
            self.navigationBar.barTintColor = UIColor.white
   }

    
    
    
    
    func setColorAndImageBasedOnCategory(category : String){
        
        setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "down arrow")!, category : category)
        setColorToBtnBasedOnCategory(button: infoBtn, image: UIImage(named: "info_icon")!, category: category)
        
        if category == RideSharingCommunityContribution.USER_CATEGORY_SILVER{
            self.view.backgroundColor = UIColor.white
            self.nameLabel.textColor = UIColor(netHex: 0x00b557)
            self.amountOfCo2Removed.textColor = UIColor(netHex: 0x00b557)
            self.categoryText.textColor = UIColor(netHex: 0x00b557)
            self.noOfRidesShared.textColor = UIColor(netHex: 0x00b557)
            self.ridesSharedLblTxt.textColor = UIColor(netHex: 0x00b557)
            self.totalDistanceShared.textColor = UIColor(netHex: 0x00b557)
            self.distanceSharedLblText.textColor = UIColor(netHex: 0x00b557)
            self.friendsMade.textColor = UIColor(netHex: 0x00b557)
            self.friendsMadeLblText.textColor = UIColor(netHex: 0x00b557)
            self.amountLabel.textColor = UIColor(netHex: 0x00b557)
            self.amountSavedLblTxt.textColor = UIColor(netHex: 0x00b557)
            self.shareBtn.backgroundColor = UIColor(netHex: 0x00b557)
            self.shareBtn.setTitleColor(UIColor.white, for: .normal)
            self.spreadTheWordLbl.textColor = UIColor(netHex: 0x8d8d8d)
            self.makeADiffTxtLbl.textColor = UIColor(netHex: 0x8d8d8d)
            self.backgroundImageView.isHidden = false
            self.categoryBanyanImage.isHidden = true
            self.leavesImageView.isHidden = true
            self.backgroundImageView.image = UIImage(named: "bamboo")
            self.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x474747),
                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!]
            self.navigationBar.barTintColor = UIColor.white
            self.categoryText.text = Strings.category_level_bamboo
            self.ecometerTitleLbl.textColor = UIColor(netHex: 0x474747)
            
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_GOLD{
            self.view.backgroundColor = UIColor(netHex: 0x00aeb5)
            self.nameLabel.textColor = UIColor.white
            self.amountOfCo2Removed.textColor = UIColor(netHex: 0xe0f430)
            self.categoryText.textColor = UIColor.white
            self.noOfRidesShared.textColor = UIColor.white
            self.ridesSharedLblTxt.textColor = UIColor.white
            self.totalDistanceShared.textColor = UIColor.white
            self.distanceSharedLblText.textColor = UIColor.white
            self.friendsMade.textColor = UIColor.white
            self.friendsMadeLblText.textColor = UIColor.white
            self.amountLabel.textColor = UIColor.white
            self.amountSavedLblTxt.textColor = UIColor.white
            self.shareBtn.backgroundColor = UIColor(netHex: 0xf7aa3c)
            self.shareBtn.setTitleColor(UIColor(netHex: 0x4d4d4d), for: .normal)
            self.spreadTheWordLbl.textColor = UIColor(netHex: 0x8ad7f8)
            self.makeADiffTxtLbl.textColor = UIColor(netHex: 0x8ad7f8)
            self.backgroundImageView.isHidden = false
            self.categoryBanyanImage.isHidden = true
            self.leavesImageView.isHidden = true
            self.backgroundImageView.image = UIImage(named: "bonsai")
            self.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!]
            self.categoryText.text = Strings.category_level_bonsai
            self.navigationBar.barTintColor = UIColor(netHex: 0x00aeb5)
            self.ecometerTitleLbl.textColor = UIColor.white
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_DIAMOND{
            self.view.backgroundColor = UIColor(netHex: 0x00b59d)
            self.nameLabel.textColor = UIColor.white
            self.amountOfCo2Removed.textColor = UIColor(netHex: 0xe0f430)
            self.categoryText.textColor = UIColor.white
            self.noOfRidesShared.textColor = UIColor.white
            self.ridesSharedLblTxt.textColor = UIColor.white
            self.totalDistanceShared.textColor = UIColor.white
            self.distanceSharedLblText.textColor = UIColor.white
            self.friendsMade.textColor = UIColor.white
            self.friendsMadeLblText.textColor = UIColor.white
            self.amountLabel.textColor = UIColor.white
            self.amountSavedLblTxt.textColor = UIColor.white
            self.shareBtn.backgroundColor = UIColor(netHex: 0xf7aa3c)
            self.shareBtn.setTitleColor(UIColor(netHex: 0x515151), for: .normal)
            self.spreadTheWordLbl.textColor = UIColor(netHex: 0x91e3ec)
            self.makeADiffTxtLbl.textColor = UIColor(netHex: 0x91e3ec)
            self.backgroundImageView.isHidden = false
            self.categoryBanyanImage.isHidden = true
            self.leavesImageView.isHidden = true
            self.backgroundImageView.image = UIImage(named: "ashoka")
            self.categoryText.text = Strings.category_level_ashoka
            self.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!]
            self.navigationBar.barTintColor = UIColor(netHex: 0x00b59d)
            self.ecometerTitleLbl.textColor = UIColor.white
        }else if category == RideSharingCommunityContribution.USER_CATEGORY_PLATINUM{
            self.view.backgroundColor = UIColor(netHex: 0x00b557)
            self.nameLabel.textColor = UIColor.white
            self.amountOfCo2Removed.textColor = UIColor(netHex: 0xe0f430)
            self.categoryText.textColor = UIColor.white
            self.noOfRidesShared.textColor = UIColor.white
            self.ridesSharedLblTxt.textColor = UIColor.white
            self.totalDistanceShared.textColor = UIColor.white
            self.distanceSharedLblText.textColor = UIColor.white
            self.friendsMade.textColor = UIColor.white
            self.friendsMadeLblText.textColor = UIColor.white
            self.amountLabel.textColor = UIColor.white
            self.amountSavedLblTxt.textColor = UIColor.white
            self.shareBtn.backgroundColor = UIColor(netHex: 0xf7aa3c)
            self.shareBtn.setTitleColor(UIColor(netHex: 0x515151), for: .normal)
            self.spreadTheWordLbl.textColor = UIColor(netHex: 0xf1f1f1)
            self.makeADiffTxtLbl.textColor = UIColor(netHex: 0xf1f1f1)
            self.backgroundImageView.isHidden = true
            self.categoryBanyanImage.isHidden = false
            self.leavesImageView.isHidden = true
            self.categoryBanyanImage.image =  UIImage(named: "banyan")
            self.categoryText.text = Strings.category_level_banyan
            self.navigationBar.titleTextAttributes =
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 15)!]
            self.navigationBar.barTintColor = UIColor(netHex: 0x00b557)
            self.ecometerTitleLbl.textColor = UIColor.white
        }
    }
  
    func setColorToBtnBasedOnCategory(button : UIButton,image : UIImage,category : String){
        let tintedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        if category == RideSharingCommunityContribution.USER_CATEGORY_SILVER{
            button.setImage(tintedImage, for: .normal)
            button.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
        }else{
            button.setImage(tintedImage, for: .normal)
            button.imageView?.tintColor = UIColor.white
        }
    }
  func getFriendsMade(newFriendsMade : Int) -> String
    {
        if(newFriendsMade == 0)
        {
            return "0"
        }
        else
        {
            return "\(newFriendsMade)"
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
         dismiss(animated: false, completion: nil)
    }
    
    func callRideSharingCommunityContributionGettingTask()
    {
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.getUserRideSharingCommunityContribution(userId: Double(userId!)!, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.rideSharingCommunityContribution = Mapper<RideSharingCommunityContribution>().map(JSONObject: responseObject!["resultData"])
                self.initialiseContributionDetails()
                self.nameLabel.isHidden = false
                self.amountOfCo2Removed.isHidden = false
                self.ridesSharedLblTxt.isHidden = false
                self.distanceSharedLblText.isHidden = false
                self.amountSavedLblTxt.isHidden = false
                self.friendsMadeLblText.isHidden = false
                if QRSessionManager.getInstance()?.getUserId() == self.userId{
                    self.moreBtnImageView.isHidden = false
                    self.moreBtnHeightConstraint.constant = 30
                }
                else{
                    self.moreBtnImageView.isHidden = true
                    self.moreBtnHeightConstraint.constant = 0
                }
               
                if self.imageUrl != nil{
                    self.userImageView.isHidden = false
                    self.userImageViewWidthConstraint.constant = 60
                    self.userNameLblLeadingSpaceConstraint.constant = 10
                    ImageCache.getInstance().setImageToView(imageView: self.userImageView, imageUrl: self.imageUrl, gender: self.gender!,imageSize: ImageCache.DIMENTION_TINY)
                    ViewCustomizationUtils.addBorderToView(view: self.userImageView, borderWidth: 3.0, color: .white)
                }else{
                    self.userImageView.isHidden = true
                    self.userImageViewWidthConstraint.constant = 0
                    self.userNameLblLeadingSpaceConstraint.constant = 0
                }
            }
            else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
            }
        })
    }
    
    func offerToastDisplay(){
        if rideSharingCommunityContribution!.numberOfCarsRemovedFromRoad! >= NewEcoMeterViewController.TOTAL_NO_OF_RIDES_TODISPLAY_OFFERS{
            modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
            modelLessDialogue?.initializeViews(message: Strings.ecometer_msg, actionText: Strings.details_click_here)
            modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takeScreenShot(_:))))
            modelLessDialogue?.isUserInteractionEnabled = true
            modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
            self.view.addSubview(modelLessDialogue!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.removeModelLessDialogue()
            }
        }
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func takeScreenShot(_ recognizer: UITapGestureRecognizer) {
        self.takeScreenShotAndShare()
    }
    
    func initialiseContributionDetails()
    {
        checkAndHandleCategoryVisibility()
        if QRSessionManager.getInstance()?.getUserId() == self.userId && rideSharingCommunityContribution!.numberOfRidesShared! >= NewEcoMeterViewController.REQUIRED_NO_OF_RIDES{
            self.shareBtn.isHidden = false
            self.spreadTheWordLbl.isHidden = false
            self.makeADiffTxtLbl.isHidden = false
            ViewCustomizationUtils.addCornerRadiusToView(view: shareBtn, cornerRadius: 8.0)

        }else{
            self.shareBtn.isHidden = true
            self.spreadTheWordLbl.isHidden = true
            self.makeADiffTxtLbl.isHidden = true

        }
        moreBtnImageView.isHidden = false
        amountLabel.text = String(rideSharingCommunityContribution!.amountSaved!)+" "+Strings.inr
        friendsMade.text = getFriendsMade(newFriendsMade: rideSharingCommunityContribution!.newFriendsMade!)
        
        totalDistanceShared.text = StringUtils.getStringFromDouble(decimalNumber: rideSharingCommunityContribution!.totalDistanceShared!)+" "+Strings.KM
        
        amountOfCo2Removed.text = String(format: Strings.co2Reduced,arguments:  [StringUtils.getStringFromDouble(decimalNumber: rideSharingCommunityContribution!.co2Reduced)])
       
        noOfRidesShared.text = String(describing: rideSharingCommunityContribution!.numberOfRidesShared!)
    }
    
    func checkAndHandleCategoryVisibility()
    {
        if(rideSharingCommunityContribution!.category == nil || rideSharingCommunityContribution!.category!.isEmpty)
        {
            categoryText.isHidden = true
            infoBtn.isHidden = true
            setColorToViewsForCategoryNotPresent()
        }
        else
        {
            categoryText.isHidden = false
            infoBtn.isHidden = false
            categoryText.text = rideSharingCommunityContribution!.category
            setColorAndImageBasedOnCategory(category: rideSharingCommunityContribution!.category!)
        }
        
    }

    @objc func takeScreenShotAndShare(){
        
      
      let screen = self.view

        if let window = UIApplication.shared.keyWindow {

            QuickRideProgressSpinner.startSpinner()
            UIGraphicsBeginImageContextWithOptions(screen!.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            let activityItem: [AnyObject] = [image as AnyObject]
            let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
            avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
            if #available(iOS 11.0, *) {
                avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
            }
            avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    self.backBtn.isHidden = false
                    self.shareBtn.isHidden = false
                    self.spreadTheWordLbl.isHidden = false
                    self.makeADiffTxtLbl.isHidden = false
                    self.quickrideLogoView.isHidden = true
                    self.moreBtnImageView.isHidden = false
                    self.infoBtn.isHidden = false
                    self.shareBtnHeightConstraint.constant = 50
                    self.spreadLblHeightConstraint.constant = 20
                    self.diffLblHeightConstrainty.constant = 20
                    self.navigationBar.topItem?.title = Strings.ecometer_title
                    self.ecometerTitleLbl.isHidden = true
            }
            QuickRideProgressSpinner.stopSpinner()
            self.present(avc, animated: true, completion: nil)
            
        }
    }

    @IBAction func backBtnClicked(_ sender: Any) {
     self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        self.backBtn.isHidden = true
        self.shareBtn.isHidden = true
        self.shareBtnHeightConstraint.constant = 0
        self.spreadLblHeightConstraint.constant = 0
        self.diffLblHeightConstrainty.constant = 0
        self.spreadTheWordLbl.isHidden = true
        self.makeADiffTxtLbl.isHidden = true
        self.quickrideLogoView.isHidden = false
        self.moreBtnImageView.isHidden = true
        self.infoBtn.isHidden = true
        self.navigationBar.topItem?.title = ""
        self.ecometerTitleLbl.isHidden = false
        
        self.perform(#selector(NewEcoMeterViewController.takeScreenShotAndShare), with: nil, afterDelay: 0.5)

    }
    
    
    @IBAction func moreBtnClicked(_ sender: Any) {
      
        if showAmountSavedView == false{
            showAmountSavedView = true
            if rideSharingCommunityContribution!.category != nil && !rideSharingCommunityContribution!.category!.isEmpty{
               setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "up_arrow")!, category : rideSharingCommunityContribution!.category!)
            }else{
                 setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "up_arrow")!, category : RideSharingCommunityContribution.USER_CATEGORY_SILVER)
            }
           
            amountSavedViewHeightConstraint.constant = 70
            amountSavedViewTopSpaceConstraint.constant = 25
            amountSavedView.isHidden = false
        }else{
            showAmountSavedView = false
            if rideSharingCommunityContribution!.category != nil && !rideSharingCommunityContribution!.category!.isEmpty{
                setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "down arrow")!, category : rideSharingCommunityContribution!.category!)
            }else{
                setColorToBtnBasedOnCategory(button: moreBtnImageView, image: UIImage(named: "down arrow")!, category : RideSharingCommunityContribution.USER_CATEGORY_SILVER)
            }
            amountSavedViewHeightConstraint.constant = 0
            amountSavedViewTopSpaceConstraint.constant = 0
            amountSavedView.isHidden = true
        }
    }
    
    @IBAction func infoBtnTapped(_ sender: Any) {
    openCategoryView()
   }
    
    @objc func infoViewClicked(_ gesture : UITapGestureRecognizer){
        openCategoryView()
    }
    
    func openCategoryView(){
        let categoryInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EcoCategoryLevelInfoViewController") as! EcoCategoryLevelInfoViewController
        categoryInfoViewController.initializeDataBeforePresenting(category: rideSharingCommunityContribution!.category!)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: categoryInfoViewController, animated: false)
    }
    
}
