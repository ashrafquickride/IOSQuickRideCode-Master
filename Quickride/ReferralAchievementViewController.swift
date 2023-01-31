//
//  ReferralAchievementViewController.swift
//  Quickride
//
//  Created by Halesh on 30/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferralAchievementViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var quickRideLogo: UIImageView!
    @IBOutlet weak var feelingProudHeightConstraint: NSLayoutConstraint!
    
    private var referralStats: ReferralStats?
    
    func initializeView(referralStats: ReferralStats){
        self.referralStats = referralStats
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGradientBackground()
    }
    
    private func setUpUi(){
        userNameLabel.text = UserDataCache.getInstance()?.getUserName()
        levelLabel.text = String(format: Strings.category_level, arguments: [String(referralStats?.level ?? 0)])
        if let gender = UserDataCache.getInstance()?.userProfile?.gender{
            ImageCache.getInstance().setImageToView(imageView: userImage, imageUrl: UserDataCache.getInstance()?.userProfile?.imageURI, gender: gender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            userImage.image = ImageCache.getInstance().getDefaultUserImage(gender: "U")
        }
        messageLabel.text = String(format: Strings.referral_achievement_msg, arguments: [String(referralStats?.totalReferralCount ?? 0),String(referralStats?.noOfVehicleRemovedFromRoad ?? 0),StringUtils.getStringFromDouble(decimalNumber: referralStats?.co2SavedFromReferral)])
        if referralStats?.noOfVehicleRemovedFromRoad == 0 || referralStats?.co2SavedFromReferral == 0{
            feelingProudHeightConstraint.constant = 0
        }else{
            feelingProudHeightConstraint.constant = 24
        }
    }
    
    @IBAction func shareBtnClicked(_ sender: Any) {
        backButton.isHidden = true
        quickRideLogo.isHidden = false
        self.perform(#selector(ReferralAchievementViewController.takeScreenShotAndShare), with: nil, afterDelay: 0.5)
    }
    
    func setGradientBackground() {
        let colorTop = UIColor(netHex: 0xECF7FF).cgColor
        let colorBottom = UIColor.white.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    @objc func takeScreenShotAndShare(){
        let screen = self.view
        
        if let window = UIApplication.shared.keyWindow {
            
            QuickRideProgressSpinner.startSpinner()
            UIGraphicsBeginImageContextWithOptions(CGSize(width: screen?.frame.width ?? 414,height: 510 ), false, 0);
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
                self.backButton.isHidden = false
                self.quickRideLogo.isHidden = true
            }
            QuickRideProgressSpinner.stopSpinner()
            self.present(avc, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
