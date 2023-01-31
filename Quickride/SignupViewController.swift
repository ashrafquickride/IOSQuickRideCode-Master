//
//  SignupViewController.swift
//  Quickride
//
//  Created by KNM Rao on 18/09/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import Alamofire
import ObjectMapper
import Moscapsule

class SignupViewController: UIViewController{
    
    @IBOutlet weak var splashView: UIView!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var loginBtnTappedView: UIView!
    
    
    var delegate : RideParticipantLocationListener?
    let log = XCGLogger.default
    
    @IBOutlet weak var seperationView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var introScreenImageView: UIImageView!
    
    @IBOutlet weak var iboPageControl: UIPageControl!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var splashTitleLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var splashTitleLblTopSpaceConstraint: NSLayoutConstraint!
    
     @IBOutlet weak var splashTitleWidthConstraint: NSLayoutConstraint!
    
    var timer : Timer?
    let titleMessage = [Strings.splash_title_1,
                        Strings.splash_title_2,
                        Strings.splash_title_3,
                        Strings.splash_title_4,
                        Strings.splash_title_5]
    let infoMessage = [String(format: Strings.splash_msg_1, arguments: ["\u{20B9}","50"]),
                       Strings.splash_msg_2,
                       Strings.splash_msg_3,
                       Strings.splash_msg_4,
                       Strings.splash_msg_5]
   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    var pageWidth:CGFloat = 280.0
    var currentPage : Int = 0
    var cashDepositBonus = 0.0
    
   
    override func viewDidLoad()
    {
        
        AppDelegate.getAppDelegate().log.debug("")
        if !AppDelegate.gaiURLString.isEmpty{
            AppDelegate.getAppDelegate().log.debug(AppDelegate.gaiURLString)
        }
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        ViewCustomizationUtils.addCornerRadiusToView(view: signUpBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: seperationView, cornerRadius: 3.0)
        self.imageView.isHidden = true
        self.introScreenImageView.isHidden = false
        self.introScreenImageView.image = UIImage(named: "intro_image_view")
        self.iboPageControl.currentPage = 0
        self.titleLabel.text = self.titleMessage[self.currentPage]
        if let systemCoupons = SignUpStepsViewController.systemCoupons{
           computeBonusPointsFromSystemCouponAndSetText(systemCoupons: systemCoupons)
        }else{
           self.infoLabel.text = Strings.splash_msg
        }
        self.splashTitleLblHeightConstraint.constant = 60
        self.splashTitleLblTopSpaceConstraint.constant = 5
        self.splashTitleWidthConstraint.constant = 175
        
        // Schedule a timer to auto slide to next page
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SignupViewController.swiped(_:)))
        leftSwipe.direction = .left
        splashView.addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SignupViewController.swiped(_:)))
        rightSwipe.direction = .right
        splashView.addGestureRecognizer(rightSwipe)
        loginBtnTappedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SignupViewController.loginBtnTapped(_:))))
        SharedPreferenceHelper.setNotificationCount(notificationCount: -1)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if let topitem = self.navigationController?.navigationBar.topItem
        {
            topitem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    func computeBonusPointsFromSystemCouponAndSetText(systemCoupons : [SystemCouponCode]){
        for coupon in systemCoupons{
            if coupon.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_REGISTER || coupon.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_ADDED_VALID_COMPANY || coupon.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_ROUTE_DETAILS_ADDED || coupon.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_ADDED_PICTURE || coupon.usageContext == SystemCouponCode.COUPON_USUAGE_CONTEXT_ACTIVATED{
                cashDepositBonus += coupon.cashDeposit
            }
        }
        if cashDepositBonus == 0.0{
            self.infoLabel.text = Strings.splash_msg
        }else{
          self.infoLabel.text = String(format: Strings.splash_msg_1, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: cashDepositBonus)])
        }
        let attributedString = NSMutableAttributedString(string: self.infoLabel.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.5
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        if cashDepositBonus != 0.0{
         let range = NSRange(location: 21, length: StringUtils.getStringFromDouble(decimalNumber: self.cashDepositBonus).count + 1)
         attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x00B557), range: range)
        }
        self.infoLabel.attributedText = attributedString
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginBtn.backgroundColor = UIColor.white
        loginBtn.addTarget(self, action:#selector(SignupViewController.HoldLoginBtn(_:)), for: UIControl.Event.touchDown)
        loginBtn.addTarget(self, action:#selector(SignupViewController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
        CustomExtensionUtility.changeBtnColor(sender: self.signUpBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        self.seperationView.applyGradient(colours: [UIColor(netHex:0x74fb8f), UIColor(netHex:0x47c760)])
    }
    
    @objc func HoldLoginBtn(_ sender:UIButton)
    {
        loginBtn.backgroundColor = Colors.lightGrey
        ViewCustomizationUtils.addBorderToView(view: sender, borderWidth: 1.0, color: Colors.lightGrey)
        ViewCustomizationUtils.addCornerRadiusToView(view: sender, cornerRadius: 5.0)
        
    }
    @objc func HoldRelease(_ sender:UIButton){
        loginBtn.backgroundColor = UIColor.white
        loginBtn.layer.borderColor = UIColor.clear.cgColor
    }
    @objc func swiped(_ gesture : UISwipeGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("")
        if gesture.direction == .left{
            
            currentPage += 1
            if currentPage > titleMessage.count - 1{
                currentPage = titleMessage.count - 1
            }
        }else if gesture.direction == .right{
            currentPage -= 1
            if currentPage < 0{
                currentPage = 0
            }
        }
        changeImageView()
    }
    override func didReceiveMemoryWarning() {
        AppDelegate.getAppDelegate().log.debug("")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(SignupViewController.moveToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextPage (){
        if currentPage >= titleMessage.count - 1 || currentPage < 0{
            currentPage = 0
        }else{
            currentPage += 1
        }
        changeImageView()
    }
    func changeImageView(){
        
        switch self.currentPage {
        case 0:
            self.imageView.isHidden = true
            self.introScreenImageView.isHidden = false
            UIView.transition(with: self.introScreenImageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_1")},
                              completion: nil)
        case 1:
            self.imageView.isHidden = false
            self.introScreenImageView.isHidden = true
            UIView.transition(with: self.imageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_2")},
                              completion: nil)
        case 2:
            self.imageView.isHidden = false
            self.introScreenImageView.isHidden = true
            UIView.transition(with: self.imageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_3")},
                              completion: nil)
        case 3:
            self.imageView.isHidden = false
            self.introScreenImageView.isHidden = true
            UIView.transition(with: self.imageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_4")},
                              completion: nil)
        case 4:
            self.imageView.isHidden = false
            self.introScreenImageView.isHidden = true
            UIView.transition(with: self.imageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_5")},
                              completion: nil)
            
        default:
            self.imageView.isHidden = true
            self.introScreenImageView.isHidden = false
            UIView.transition(with: self.introScreenImageView,
                              duration:1,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = UIImage(named: "splash_icon_1")},
                              completion: nil)
        }
        UIView.transition(with: self.iboPageControl,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                             self.iboPageControl.currentPage = self.currentPage
        }, completion: nil)
        UIView.transition(with: self.titleLabel,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            if self.currentPage == 0{
                                self.splashTitleLblHeightConstraint.constant = 60
                                self.splashTitleLblTopSpaceConstraint.constant = 5
                                self.splashTitleWidthConstraint.constant = 175
                            }else{
                                self.splashTitleLblHeightConstraint.constant = 43
                                self.splashTitleLblTopSpaceConstraint.constant = 15
                                self.splashTitleWidthConstraint.constant = 220
                            }
                            
                            self.titleLabel.text = self.titleMessage[self.currentPage]
            }, completion: nil)
        UIView.transition(with: self.infoLabel,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            if self.currentPage == 0{
                                if self.cashDepositBonus != 0.0{
                                  self.infoLabel.text = String(format: Strings.splash_msg_1, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: self.cashDepositBonus)])
                                }else{
                                  self.infoLabel.text = Strings.splash_msg
                                }
                            }else{
                               self.infoLabel.text = self.infoMessage[self.currentPage]
                            }
                            let attributedString = NSMutableAttributedString(string: self.infoLabel.text!)
                            let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineSpacing = 2
                            paragraphStyle.lineHeightMultiple = 1.5
                            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                            
                            if self.currentPage == 0 && self.cashDepositBonus != 0.0{
                                let range = NSRange(location: 21, length: StringUtils.getStringFromDouble(decimalNumber: self.cashDepositBonus).count + 1)
                                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x00B557), range: range)
                            }
                       
                            self.infoLabel.attributedText = attributedString
        }, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    deinit{
        timer?.invalidate()
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any)
    {
        let registrationViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.registrationController) as! RegistrationBaseViewController
        registrationViewController.initializeDataBeforePresentingView(phone: nil, password: nil, phoneCode: nil, email: nil)
    navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
        
        self.navigationController?.pushViewController(registrationViewController, animated: false)
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        self.moveToLogin()
    }
    @objc func loginBtnTapped(_ sender : UITapGestureRecognizer)
    {
        self.moveToLogin()
    }
    func moveToLogin(){
        let loginController : LoginController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! LoginController
        loginController.initializeDataBeforePresentingView(phone: nil, password: nil)
        navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
        self.navigationController?.pushViewController(loginController, animated: false)
    }
    
}
