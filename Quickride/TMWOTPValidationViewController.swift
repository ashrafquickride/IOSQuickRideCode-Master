//
//  TMWOTPValidationViewController.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class TMWOTPValidationViewController : UIViewController,UITextFieldDelegate{
    

    @IBOutlet weak var tmwOtpLabel: UILabel!
    
     @IBOutlet weak var OTPTextField: UITextField!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var negativeActionBtn: UIButton!
    
    @IBOutlet weak var positiveActionBtn: UIButton!
    
    var phoneNo : String?
    var linkWalletResponse : LinkWalletResponse?
    var linkExternalWalletReceiver : LinkExternalWalletReciever?
    
    func initializeDataBeforePresenting(phoneNo : String,linkWalletResponse : LinkWalletResponse,linkExternalWalletReceiver : LinkExternalWalletReciever?){
        self.phoneNo = phoneNo
        self.linkWalletResponse = linkWalletResponse
        self.linkExternalWalletReceiver = linkExternalWalletReceiver
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OTPTextField.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TMWOTPValidationViewController.backGroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 3.0)
        tmwOtpLabel.text = String(format: Strings.we_sent_otp, phoneNo!)
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveActionBtn, cornerRadius: 10.0)
        ViewCustomizationUtils.addBorderToView(view: negativeActionBtn, borderWidth: 1.0, color: UIColor(netHex:0xcdcdcd))
        ViewCustomizationUtils.addCornerRadiusToView(view: negativeActionBtn, cornerRadius: 10.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.positiveActionBtn.applyGradient(colours: [UIColor(netHex:0x00b557), UIColor(netHex:0x008a41)])
        self.negativeActionBtn.applyGradient(colours: [UIColor.white, UIColor.white])
    }
    
    func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    
    @IBAction func confirmBtnClicked(_ sender: Any) {
        
        if OTPTextField.text == nil || OTPTextField.text!.isEmpty{
            MessageDisplay.displayAlert(messageString:String(format: Strings.we_sent_otp, phoneNo!), viewController: self, handler: nil)
            return
        }
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingTMW(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!, otp: OTPTextField.text!, transactionId: self.linkWalletResponse!.state!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet)
                self.linkExternalWalletReceiver?.walletAdded()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController())
            }
        }
     }
    
    
}
