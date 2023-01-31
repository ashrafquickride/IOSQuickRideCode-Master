//
//  AddMoneyViewController.swift
//  Quickride
//
//  Created by Halesh on 31/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

enum AddMoneyAction{
    case addMoney
    case selected
    case changePayment
    case close
}
 typealias addMoneyComplitionHandler = (_ result: AddMoneyAction) -> Void

class AddMoneyViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var walletImage: UIImageView!
    @IBOutlet weak var requiresPointsLabel: UILabel!
    @IBOutlet weak var addMoneyButton: UIButton!
    @IBOutlet weak var wallet1Image: UIImageView!
    @IBOutlet weak var wallet2Image: UIImageView!
    @IBOutlet weak var wallet3Image: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var otherPaymentMethodsButton: UIButton!
    @IBOutlet weak var amountErrorLbl: NSLayoutConstraint!
    @IBOutlet weak var submitButtonBotomConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    private var errorMsg: String?
    private var isKeyBoardVisible : Bool = false
    private var handler: addMoneyComplitionHandler?
    static let CHANGE_PAYMENT_METHOD = "CHANGE_PAYMENT_METHOD"
    
    func initializeView(errorMsg: String,handler: addMoneyComplitionHandler?){
        self.errorMsg = errorMsg
        self.handler = handler
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        setImage()
        getAvailableWalletsAndShowCount()
        requiresPointsLabel.text = errorMsg
        amountTextField.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(AddMoneyViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddMoneyViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setImage(){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            walletImage.image = UIImage(named : "paytm_logo_with_text")
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
            walletImage.image = UIImage(named : "mobikwik_logo_with_text")
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
            walletImage.image = UIImage(named : "frecharge_with_text")
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
            walletImage.image = UIImage(named : "amazon_pay")
        }
    }
    
    private func getAvailableWalletsAndShowCount(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        var availableWallets = AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availableWalletOptions)
        availableWallets.append(contentsOf: AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availablePayLaterOptions))
        availableWallets.append(contentsOf: AccountUtils().checkAvailableUPIWalletValidOrNot(linkWallets: clientConfiguration.availableUpiOptions))
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if let type = linkedWallet?.type,let index = availableWallets.index(of: type) {
            availableWallets.remove(at: index)
        }
        otherPaymentMethodsButton.setTitle(String(format: Strings.pluse_count_more, arguments: [String(availableWallets.count - 3)]), for: .normal)
        setImageToAvailableWallets(linkedWallets: availableWallets)
    }

    private func setImageToAvailableWallets(linkedWallets: [String]){
        if linkedWallets.count < 1{
            return
        }
        switch linkedWallets[0]{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            wallet1Image.image = UIImage(named : "Paytm-1")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            wallet1Image.image = UIImage(named : "amazon_pay")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            wallet1Image.image = UIImage(named : "frecharge_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            wallet1Image.image = UIImage(named : "tmw_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            wallet1Image.image = UIImage(named : "simpl_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            wallet1Image.image = UIImage(named : "lazypay_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            wallet1Image.image = UIImage(named : "mobikwik_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            wallet1Image.image = UIImage(named : "UPI_Image")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            wallet1Image.image = UIImage(named : "gpay_icon")
        default: break
        }
        if linkedWallets.count < 2{
            return
        }
        switch linkedWallets[1]{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            wallet2Image.image = UIImage(named : "Paytm-1")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            wallet2Image.image = UIImage(named : "amazon_pay")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            wallet2Image.image = UIImage(named : "frecharge_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            wallet2Image.image = UIImage(named : "tmw_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            wallet2Image.image = UIImage(named : "simpl_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            wallet2Image.image = UIImage(named : "lazypay_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            wallet2Image.image = UIImage(named : "mobikwik_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            wallet2Image.image = UIImage(named : "UPI_Image")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            wallet2Image.image = UIImage(named : "gpay_icon")
        default: break
        }
        if linkedWallets.count < 3{
            return
        }
        switch linkedWallets[2]{
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            wallet3Image.image = UIImage(named : "Paytm-1")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            wallet3Image.image = UIImage(named : "amazon_pay")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            wallet3Image.image = UIImage(named : "frecharge_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            wallet3Image.image = UIImage(named : "tmw_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            wallet3Image.image = UIImage(named : "simpl_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            wallet3Image.image = UIImage(named : "lazypay_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            wallet3Image.image = UIImage(named : "mobikwik_logo_with_text")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            wallet3Image.image = UIImage(named : "UPI_Image")
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            wallet3Image.image = UIImage(named : "gpay_icon")
        default: break
        }
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            submitButtonBotomConstraint.constant = keyBoardSize.height - 30
            
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        submitButtonBotomConstraint.constant = 20
    }

    @IBAction func addMoneyTapped(_ sender: Any) {
        self.view.endEditing(false)
        if amountTextField.text!.isEmpty{
            amountErrorLbl.constant = 20
        }else{
            let addMoneyWebViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyWebViewController") as! AddMoneyWebViewController
            addMoneyWebViewController.initializeData(amount: amountTextField.text!){
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.dismiss(animated: false, completion: nil)
                self.handler?(.addMoney)
            }
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: addMoneyWebViewController, animated: false)
        }
    }
    
    @IBAction func changePaymentMethodTapped(_ sender: Any) {
        closeView()
        self.handler?(.changePayment)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.dismiss(animated: false, completion: nil)
        }
        if let handler = handler{
            handler(.close)
        }
    }
}
//MARK: UITextFieldDelegate
extension AddMoneyViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountErrorLbl.constant = 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == amountTextField{
            threshold = 6
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        amountTextField.resignFirstResponder()
        return true
    }
}
