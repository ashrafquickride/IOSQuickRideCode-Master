//
//  UPIWalletLinkingViewController.swift
//  Quickride
//
//  Created by Admin on 03/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UPIWalletLinkingViewController : UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var verifyBtn: UIButton!
    
    @IBOutlet weak var upiIdTextField: UITextField!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var alertViewVerticalAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var walletTypeImageView: UIImageView!
    
    var linkExternalWalletReceiver : linkExternalWalletReciever?
    var UPIType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        if UPIType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
            walletTypeImageView.image = UIImage(named : "gpay_icon")
        } else {
            walletTypeImageView.image = UIImage(named : "UPI_Image")
        }
        upiIdTextField.delegate = self
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UPIWalletLinkingViewController.backgroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: verifyBtn, cornerRadius: 5.0)
        upiIdTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(textField : UITextField){
           verifyActnColorChange()
    }
    func initializeDataBeforePresenting(type: String, linkExternalWalletReceiver : linkExternalWalletReciever?){
        self.UPIType = type
        self.linkExternalWalletReceiver = linkExternalWalletReceiver
    }
    
    override func viewDidAppear(_ animated: Bool) {
        verifyActnColorChange()
    }
    
    @IBAction func verifyBtnClicked(_ sender: Any) {
        self.view.endEditing(false)
        if upiIdTextField.text == nil || upiIdTextField.text!.isEmpty{
          MessageDisplay.displayAlert( messageString: Strings.fill_all_required_fields, viewController: self,handler: nil)
            return
        }
        if UPIType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
            let upiId = upiIdTextField.text!.components(separatedBy: "@")
            if upiId.count > 1 && !AccountUtils().isValidGpayUPIId(upiId: upiId[1]){
                MessageDisplay.displayAlert( messageString: Strings.enter_valid_gpay_id, viewController: self,handler: nil)
                return
            }
        }
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.linkUPIWallet(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", mobileNo: UserDataCache.getInstance()?.currentUser?.contactNo, email: UserDataCache.getInstance()?.getLoggedInUserProfile()?.emailForCommunication, vpaAddress: upiIdTextField.text!, type: UPIType, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                var type = linkedWallet!.type
                if linkedWallet!.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
                    type = Strings.gpay
                }
                AccountUtils().showActivatedAlert(walletType: type!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        verifyActnColorChange()
        alertViewVerticalAlignmentConstraint.constant = -100
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
        verifyActnColorChange()
        alertViewVerticalAlignmentConstraint.constant = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        alertViewVerticalAlignmentConstraint.constant = 0
        return true
    }
    func verifyActnColorChange(){
        if upiIdTextField.text != nil && !upiIdTextField.text!.isEmpty{
            CustomExtensionUtility.changeBtnColor(sender: self.verifyBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            verifyBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.verifyBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            verifyBtn.isUserInteractionEnabled = false
        }
    }
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
}
