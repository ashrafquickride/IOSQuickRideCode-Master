//
//  EcoMeterViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 27/09/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import Social

class EcoMeterViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var categoryText: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var friendsMade: UILabel!
    
    @IBOutlet weak var badgeView: UIImageView!
    
    @IBOutlet weak var navigationBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var ecoMeterFriends: UIImageView!
    
    @IBOutlet weak var ecoMeterTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var categoryWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountCenteryConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var removedCo2CenteryConstraint: NSLayoutConstraint!
    
    // Branding Outlets
       
    @IBOutlet weak var noOfRidesShared: UILabel!
    
    @IBOutlet weak var totalDistanceShared: UILabel!

    @IBOutlet weak var amountOfCo2Removed: UILabel!
    
    @IBOutlet weak var amountSaved: UILabel!
    
    @IBOutlet weak var ecoviewButton: UIButton!
    
    @IBOutlet weak var ecoviewImage: UIImageView!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    static let TOTAL_NO_OF_RIDES_TODISPLAY_OFFERS = 50
    var rideSharingCommunityContribution : RideSharingCommunityContribution?
    var topViewController : PaymentViewController?
    var userId : String? = QRSessionManager.getInstance()?.getUserId()
    var userName : String? = UserDataCache.getInstance()?.getUserName()
    var imageURI : String? = UserDataCache.getInstance()?.getCurrentUserImageURI()
    var gender : String? = UserDataCache.getInstance()?.getCurrentUserGender()
    var imageHide : Bool = false
    
    static let REQUIRED_NO_OF_RIDES = 50
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        
        initializeUserImageAndName()
        callRideSharingCommunityContributionGettingTask()
        
        if(imageHide == false)
        {
            navigationBar.isHidden = true
            navigationBarHeightConstraint.constant = 0
            if ecoMeterTopConstraint != nil
            {
                ecoMeterTopConstraint.constant = 0
            }
        }else{
          navigationBar.isHidden = false
      }
        if userId == QRSessionManager.getInstance()?.getUserId()
        {
               ecoviewButton.isHidden = false
               ecoviewImage.isHidden = false
        }
        else
        {
            ecoviewButton.isHidden = true
            ecoviewImage.isHidden = true
        }
        
        
    }
    func offerToastDisplay(){
    if rideSharingCommunityContribution!.numberOfCarsRemovedFromRoad! >= EcoMeterViewController.TOTAL_NO_OF_RIDES_TODISPLAY_OFFERS{
    let modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
    modelLessDialogue.initializeViews(message: Strings.ecometer_msg, actionText: Strings.details_click_here)
    let position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height*2/3)
    self.view.showToast(toast: modelLessDialogue, duration: 4.0, position: position, completion: { (didTap) -> Void in
    if didTap == true{
        self.takeScreenShotAndShare()
     
    }
    })
    }
    }
    
    func initializeDataBeforePresenting(imageHide : Bool, userId : String, userName: String, imageURI : String?, gender : String){
        self.imageHide = imageHide
        self.userId = userId
        self.userName = userName
        self.imageURI = imageURI
        self.gender = gender
    }
    
    func initializeUserImageAndName() {
        nameLabel.text = userName!
        ImageCache.getInstance()?.setImageToView(imageView: self.imageView, imageUrl: imageURI, gender: gender!)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func callRideSharingCommunityContributionGettingTask()
    {
        QuickRideProgressSpinner.startSpinner()
        RideServicesClient.getUserRideSharingCommunityContribution(userId: Double(userId!)!, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                 self.rideSharingCommunityContribution = Mapper<RideSharingCommunityContribution>().map(JSONObject: responseObject!["resultData"])
                self.initialiseContributionDetails()
                
                if self.userId == QRSessionManager.getInstance()?.getUserId()
                {
                self.offerToastDisplay()
                }

            }
            else
            {
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self)
                self.ecoviewButton.isHidden = true
                self.ecoviewImage.isHidden = true
            }
        })
    }
    
    func initialiseContributionDetails()
    {
        checkAndHandleCategoryVisibility()
        
        if rideSharingCommunityContribution!.numberOfRidesShared! >= EcoMeterViewController.REQUIRED_NO_OF_RIDES{
            shareBtn.isHidden = false
            if topViewController?.selectedIndex == 3{
                 topViewController?.shareOnFbBtn.isHidden = false
            }else{
               topViewController?.shareOnFbBtn.isHidden = true
            }
        }else{
            shareBtn.isHidden = true
            topViewController?.shareOnFbBtn.isHidden = true
        }
        
  friendsMade.text = getFriendsMade(newFriendsMade: rideSharingCommunityContribution!.newFriendsMade!)
        
        
        totalDistanceShared.attributedText = getTotalDistanceSharedAttributedText(totalDistance: StringUtils.getStringFromDouble(decimalNumber: rideSharingCommunityContribution!.totalDistanceShared))
        
        amountOfCo2Removed.attributedText = getamountOfCo2ReducedAttributedText(co2reduced: StringUtils.getStringFromDouble(decimalNumber: rideSharingCommunityContribution!.co2Reduced))

        
        noOfRidesShared.attributedText = getNoOfRidesSharedAttributedText(noOfRides: String(rideSharingCommunityContribution!.numberOfCarsRemovedFromRoad!))
        
        var pointsSaved : Int = rideSharingCommunityContribution!.amountSaved!
        if(pointsSaved < 0 )
        {
            pointsSaved = 0
        }
        amountSaved.attributedText = getamountSavedAttributedText(amountSaved: String(pointsSaved))
        
        var pointsSavedForOthers : Int = rideSharingCommunityContribution!.amountSavedForOthers!
        
        if(pointsSavedForOthers < 0)
        {
            pointsSavedForOthers = 0
        }
        
    }
    func getFriendsMade(newFriendsMade : Int) -> String
    {
        if(newFriendsMade == 0)
        {
                return Strings.no_new_friends_yet
        }
        else
        {
            return "\(newFriendsMade) \(Strings.new_friends_made)"
        }
    }
    
    func checkAndHandleCategoryVisibility()
    {
        if(rideSharingCommunityContribution!.category == nil || rideSharingCommunityContribution!.category!.isEmpty)
        {
            categoryText.isHidden = true
            badgeView.isHidden = true
        }
        else
        {
            categoryText.isHidden = false
            badgeView.isHidden = false
            categoryText.text = rideSharingCommunityContribution!.category
            setCategoryWidthConstraint()
        }

    }
func setCategoryWidthConstraint()
{
    if categoryText.text == "PLATINUM" || categoryText.text == "DIAMOND"
    {
        categoryWidthConstraint.constant = 62
        
    }
    else if categoryText.text == "SILVER" || categoryText.text == "GOLD"
    {
        categoryWidthConstraint.constant = 40
    }
        
}
    func getNoOfRidesSharedAttributedText(noOfRides : String) -> NSAttributedString{
        let string = "\(noOfRides) Rides" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        #if WERIDE
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 18), range: string.rangeOfString(noOfRides))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 10), range: string.rangeOfString(" Rides"))
            
        #else
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 18), range: string.range(of: noOfRides))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 10), range: string.range(of: " Rides"))
        #endif
        return attributedString
    }

    func getTotalDistanceSharedAttributedText(totalDistance : String) -> NSAttributedString{
        let string = "\(totalDistance) KM" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        #if WERIDE
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 18), range: string.rangeOfString(totalDistance))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 10), range: string.rangeOfString(" KM"))

        #else
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 18), range: string.range(of: totalDistance))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 10), range: string.range(of: " KM"))
        #endif
        return attributedString
    }
    
    func getamountOfCo2ReducedAttributedText(co2reduced : String) -> NSAttributedString
    {
        let string = "\(co2reduced) KG" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        #if WERIDE
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 18), range: string.rangeOfString(co2reduced))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 10), range: string.rangeOfString(" \(Strings.kg)"))
        #else
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 18), range: string.range(of: co2reduced))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 10), range: string.range(of: " \(Strings.kg)"))
        #endif
        return attributedString
    }
    
    func getamountSavedAttributedText(amountSaved : String) -> NSAttributedString
    {
        
        let string = "\(amountSaved) \(Strings.inr)" as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String)
        #if WERIDE
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 18), range: string.rangeOfString(amountSaved))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeForWeRide(UIColor(netHex:0x454545), textSize: 10), range: string.rangeOfString(" \(Strings.inr)"))

        #else
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 18), range: string.range(of: amountSaved))
            
            attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x65A624), textSize: 10), range: string.range(of: " \(Strings.inr)"))
        #endif
        
        return attributedString
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
      dismiss(animated: false, completion: nil)
    }
    
    @IBAction func ecoviewButtonTapped(_ sender: Any) {
        if rideSharingCommunityContribution != nil{
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewEcoMeterViewController") as! NewEcoMeterViewController
        destViewController.initializeDataBeforePresentingView(rideSharingCommunityContribution: rideSharingCommunityContribution)
      present(destViewController, animated: false, completion: nil)
        }
        else{
            UIApplication.shared.keyWindow?.makeToast(message: Strings.rideshare_info_not_available)
            return
        }
    }
    
    
    func takeScreenShotAndShare(){
        let screen = UIScreen.main
        if let window = UIApplication.shared.keyWindow {
             QuickRideProgressSpinner.startSpinner()
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            let activityItem: [AnyObject] = [image as AnyObject]
            let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
            avc.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.assignToContact,UIActivityType.copyToPasteboard,UIActivityType.addToReadingList,UIActivityType.saveToCameraRoll,UIActivityType.print]
            if #available(iOS 11.0, *) {
                avc.excludedActivityTypes = [UIActivityType.markupAsPDF,UIActivityType.openInIBooks]
            }
            QuickRideProgressSpinner.stopSpinner()
            self.present(avc, animated: true, completion: nil)
      
        }
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        
        takeScreenShotAndShare()
    }
}
