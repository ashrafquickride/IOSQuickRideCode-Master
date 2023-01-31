//
//  FuelCardDetailsViewController.swift
//  Quickride
//
//  Created by Halesh on 04/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

class FuelCardDetailsViewController: UIViewController,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var aboutView: UIView!
    
    @IBOutlet weak var aboutLbl: UILabel!
    
    @IBOutlet weak var clickHereBtn: UIButton!
    
    @IBOutlet weak var clickHereBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var howToApplyView: UIView!
    
    @IBOutlet weak var stepsTitleLbl: UILabel!
    
    @IBOutlet weak var stepsLbl: UILabel!
    
    @IBOutlet weak var contactNumberBtn: UIButton!
    
    @IBOutlet weak var emailBtn: UIButton!
    
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var applyBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backGroundView: UIView!
    

    var infoTitle: String?
    var aboutText: String?
    var stepsTitle: String?
    var stepsText: String?
    var contact: String?
    var email: String?
    var fuelCardRegistrationReceiver: fuelCardRegistrationReceiver?
    
    func initializeInfoView(title: String, aboutText: String, stepsTitle: String, stepsText: String, contact: String, email: String,fuelCardRegistrationReceiver:fuelCardRegistrationReceiver?){
        self.infoTitle = title
        self.aboutText = aboutText
        self.stepsTitle = stepsTitle
        self.stepsText = stepsText
        self.contact = contact
        self.email = email
        self.fuelCardRegistrationReceiver = fuelCardRegistrationReceiver
    }
    
    override func viewDidLoad(){
     
        if #available(iOS 11.0, *) {
            contentView.layer.cornerRadius = 20
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: contentView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        }
    
        titleLbl.text = infoTitle
        assignInfoAboutFuelCard()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FuelCardDetailsViewController.backGroundViewTapped(_:))))
        howToApplyView.isHidden = true
        if infoTitle == Strings.hp_fuel_card && fuelCardRegistrationReceiver != nil{
            segmentControl.selectedSegmentIndex = 1
            aboutView.isHidden = true
            howToApplyView.isHidden = false
            assignHowToApplyFuelCardSteps()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0{
            aboutView.isHidden = false
            howToApplyView.isHidden = true
            assignInfoAboutFuelCard()
        }else if segmentControl.selectedSegmentIndex == 1{
            aboutView.isHidden = true
            howToApplyView.isHidden = false
            assignHowToApplyFuelCardSteps()
           
            
        }
    }
    
    func assignInfoAboutFuelCard(){
        let attributedString = NSMutableAttributedString(string: aboutText!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        aboutLbl.attributedText = attributedString
        if infoTitle == Strings.sodexo{
            clickHereBtn.isHidden = false
            clickHereBtnHeightConstraint.constant = 25
        }else{
            clickHereBtn.isHidden = true
            clickHereBtnHeightConstraint.constant = 0
        }

    }
    
    func assignHowToApplyFuelCardSteps(){
        stepsTitleLbl.text = stepsTitle
        let attributedString = NSMutableAttributedString(string: stepsText!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        stepsLbl.attributedText = attributedString
        contactNumberBtn.setTitle(contact, for: .normal)
        emailBtn.setTitle(email, for: .normal)
        if infoTitle == Strings.hp_fuel_card && fuelCardRegistrationReceiver == nil{
            applyBtn.isHidden = true
            applyBtnHeightConstraint.constant = 0
        }else{
            applyBtn.isHidden = false
            applyBtnHeightConstraint.constant = 35
        }

    }
    
    @IBAction func clickHereTapped(_ sender: Any) {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.about_sodexo)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.sodexo, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func contactNumberTapped(_ sender: Any) {
        AppUtilConnect.dialNumber(phoneNumber: contact!, viewController: self)
        
    }
    
    @IBAction func emailTapped(_ sender: Any){
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: nil, toRecipients: [email!],ccRecipients: [],mailBody: "")
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
    @IBAction func applyBtnTapped(_ sender: Any) {
        if infoTitle == Strings.sodexo{
            let sodexoRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SodexoRegistrationViewController") as! SodexoRegistrationViewController
            ViewControllerUtils.displayViewController(currentViewController: ViewControllerUtils.getCenterViewController(), viewControllerToBeDisplayed: sodexoRegistrationViewController, animated: false)
        }else if infoTitle == Strings.shell_fuel_card{
            let firstEncashmentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FirstEncashmentViewController") as! FirstEncashmentViewController
            firstEncashmentViewController.initializeDataBeforePresentingView(preferredFuelCompany: RedemptionRequest.REDEMPTION_TYPE_SHELL_CARD, fuelCardRegistrationReceiver: fuelCardRegistrationReceiver!)
            ViewControllerUtils.addSubView(viewControllerToDisplay: firstEncashmentViewController)
        }else if infoTitle == Strings.hp_pay{
            let hPPayRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HPPayRegistrationViewController") as! HPPayRegistrationViewController
            hPPayRegistrationViewController.initializeDataBeforePresentingView(fuelCardRegistrationReceiver: fuelCardRegistrationReceiver!)
            self.navigationController?.pushViewController(hPPayRegistrationViewController, animated: false)
        }else if infoTitle == Strings.iocl_fuel_card {
           let registrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "IOCLRegistrationViewController") as! IOCLRegistrationViewController
            registrationViewController.initializeDataBeforePresentingView(fuelCardRegistrationReceiver: fuelCardRegistrationReceiver!)
           ViewControllerUtils.addSubView(viewControllerToDisplay: registrationViewController)
        } else if infoTitle == Strings.hp_fuel_card {
            fuelCardRegistrationReceiver?(true)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
