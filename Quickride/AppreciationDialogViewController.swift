//
//  AppreciationDialogViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 3/18/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

typealias rideCompletionDialogHandler = () -> Void

class AppreciationDialogViewController: ModelViewController,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var appreciationDialog: UIView!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var quickRideExpericenceDialgoue: UIView!
    
    @IBOutlet weak var quickRideExperieceNOButton: UIButton!
    
    @IBOutlet weak var quickRideExperienceYESButton: UIButton!
    
    @IBOutlet weak var appStoreReivewConfiramtionView: UIView!
    
    @IBOutlet weak var appStoreReivewOKButton: UIButton!
    
    @IBOutlet weak var appStoreReviewNotNowButton: UIButton!
    
    @IBOutlet weak var feebackView: UIView!
    
    @IBOutlet weak var feedbackOKButton: UIButton!
    
    @IBOutlet weak var feedbackNotNowButton: UIButton!
    
    @IBOutlet weak var appreciationDialogueWidth: NSLayoutConstraint!
  
    @IBOutlet weak var enjoyQuickrideLbl: UILabel!
   
    var rideCompletionDialogHandler : rideCompletionDialogHandler?
    var isSelected = false
    
    func initializeDataBeforePresenting(rideCompletionDialogHandler:rideCompletionDialogHandler?){
        self.rideCompletionDialogHandler = rideCompletionDialogHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enjoyQuickrideLbl.text = Strings.enjoy_ride
        ViewCustomizationUtils.addCornerRadiusToView(view: quickRideExperieceNOButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addBorderToView(view: quickRideExperieceNOButton, borderWidth: 1, color: Colors.mainButtonColor)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: quickRideExperienceYESButton, cornerRadius: 3.0)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: appStoreReviewNotNowButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addBorderToView(view: appStoreReviewNotNowButton, borderWidth: 1, color: Colors.mainButtonColor)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: appStoreReivewOKButton, cornerRadius: 3.0)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: feedbackNotNowButton, cornerRadius: 3.0)
        ViewCustomizationUtils.addBorderToView(view: feedbackNotNowButton, borderWidth: 1, color: Colors.mainButtonColor)
        
        ViewCustomizationUtils.addCornerRadiusToView(view: feedbackOKButton, cornerRadius: 3.0)
        
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AppreciationDialogViewController.backGroundViewTapped(_:))))
        appreciationDialogueWidth.constant  = UIApplication.shared.keyWindow!.frame.width*0.85
        quickRideExpericenceDialgoue.isHidden = false
        appStoreReivewConfiramtionView.isHidden = true
        feebackView.isHidden = true
      }
    
    @IBAction func positiveActnBtnTapped(_ sender: Any) {
        
        SharedPreferenceHelper.setAllowRateUsDialogStatus(flag: true)
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL)
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.rate_us_review_message)
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        else
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_launch_app_store)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
         rideCompletionDialogHandler?()
    }
    
    @IBAction func quickRideExpNoButtonAction(_ sender: Any) {//no
        if isSelected == true{
             self.view.removeFromSuperview()
             self.removeFromParent()
             rideCompletionDialogHandler?()
        }
            quickRideExpericenceDialgoue.isHidden = true
            appStoreReivewConfiramtionView.isHidden = true
            feebackView.isHidden = false
        
   
    }
    
    @IBAction func quickRideExpYESButtonAction(_ sender: Any){//no
        if isSelected == true{
            self.view.removeFromSuperview()
            self.removeFromParent()
            rideCompletionDialogHandler?()
        }
            if !SharedPreferenceHelper.getAllowRateUsDialogStatus(){
                quickRideExpericenceDialgoue.isHidden = true
                appStoreReivewConfiramtionView.isHidden = false
                feebackView.isHidden = true
            }else{
                self.view.removeFromSuperview()
                self.removeFromParent()
                rideCompletionDialogHandler?()
            }
    }
    
    @IBAction func appStoreReviewOKButtonAction(_ sender: Any){
        let url = NSURL(string: AppConfiguration.application_link)
        if url == nil || !UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_launch_app_store)
        }else{
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        
        self.view.removeFromSuperview()
        self.removeFromParent()
        rideCompletionDialogHandler?()
    }
    
    @IBAction func appStoreReviewNotNowButtonAction(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
         rideCompletionDialogHandler?()
    }
    
    @IBAction func feedbackOKAction(_ sender: Any) {
        HelpUtils.sendEmailToSupport(viewController: self, image: nil,listOfIssueTypes: Strings.list_of_issue_types)
     }
    
    @IBAction func feedackNotNowAction(_ sender: Any) { self.view.removeFromSuperview()
        self.removeFromParent()
        rideCompletionDialogHandler?()
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
        self.view.removeFromSuperview()
        self.removeFromParent()
        rideCompletionDialogHandler?()
    
   
  }
}
