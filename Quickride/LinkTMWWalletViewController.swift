//
//  LinkTMWWalletViewController.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class LinkTMWWalletViewController : UIViewController,UITextFieldDelegate{
    

    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var negativeActionBtn: UIButton!
    @IBOutlet weak var positiveActionBtn: UIButton!
    
    var linkExternalWalletReciever : LinkExternalWalletReciever?
    
    func initializeDataBeforePresenting(linkExternalWalletReciever : LinkExternalWalletReciever?){
        self.linkExternalWalletReciever = linkExternalWalletReciever
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumberTextField.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LinkTMWWalletViewController.backGroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 3.0)
        let user = UserDataCache.getInstance()?.currentUser
        if user != nil && user!.contactNo != nil{
            mobileNumberTextField.text = StringUtils.getStringFromDouble(decimalNumber: user!.contactNo!)
        }
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
    

    @IBAction func requestOTPBtnClicked(_ sender: Any) {
        if mobileNumberTextField.text == nil || mobileNumberTextField.text!.isEmpty{
            MessageDisplay.displayAlert(messageString: Strings.enter_your_registered_tmw_number, viewController: self, handler: nil)
            return
        }
        
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.linkTMWAccountToQR(phone: mobileNumberTextField.text! , viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
             
               let linkWalletResponse = Mapper<LinkWalletResponse>().map(JSONObject: responseObject!["resultData"])
                
               let tmwOtpValidationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWOTPValidationViewController") as! TMWOTPValidationViewController
                tmwOtpValidationViewController.initializeDataBeforePresenting(phoneNo: self.mobileNumberTextField.text!, linkWalletResponse: linkWalletResponse!, linkExternalWalletReceiver: self.linkExternalWalletReciever!)
               
                self.navigationController?.view.addSubview(tmwOtpValidationViewController.view)
                self.navigationController?.addChildViewController(tmwOtpValidationViewController)
                tmwOtpValidationViewController.view.layoutIfNeeded()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self)
            }
        }
        
    
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    

    
}
