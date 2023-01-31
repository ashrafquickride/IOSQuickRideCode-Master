//
//  AddMoneyWebViewController.swift
//  Quickride
//
//  Created by Vinutha on 7/16/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import WebKit
import PWAINSilentPayiOSSDK

typealias paymentSuccessResponseHandler = ()->Void

class AddMoneyWebViewController: UIViewController, WKNavigationDelegate {
    
    //MARK: WebView Adding
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var amount = 0.00
    var handler : paymentSuccessResponseHandler?
    var linkedWallet : LinkedWallet?
    var url: URL?
    
    func initializeData(amount : String,handler: @escaping paymentSuccessResponseHandler){
        self.amount = Double(amount)!
        self.handler = handler
    }
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        setupWebView()
        if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
            self.linkedWallet = linkedWallet
            if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
                url = URL(string:getPaytmURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
                getMobikwikURL()
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
                url = URL(string:getFreechargeURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
                getAmazonURL()
            }
        }
        if url != nil{
            let request = URLRequest(url:url! as URL)
            QuickRideProgressSpinner.startSpinner()
            webView.load(request)
        }
    }
    
    private func setupWebView() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.rightAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    func getMobikwikURL(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getMobiquickURLToAddMoney(userId: (QRSessionManager.getInstance()?.getUserId())!, amount: amount, viewController: self) {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let urlString = responseObject!["resultData"] as? String
                self.url = URL(string:urlString! .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                let request = URLRequest(url:self.url! as URL)
                QuickRideProgressSpinner.startSpinner()
                self.webView.load(request)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func getPaytmURL() -> String{
        let appStartUpData = SharedPreferenceHelper.getAppStartUpData()
        if let token = linkedWallet?.token,let custId = linkedWallet?.custId,let mobileNo = linkedWallet?.mobileNo,let emailForCommunication = UserDataCache.getInstance()?.getLoggedInUserProfile()?.emailForCommunication,let paytmAddMoneyURL = appStartUpData?.paytmAddMoneyURL{
            return "\(paytmAddMoneyURL)SSO_TOKEN=\(token)&ORDER_ID=\(generateOrderIDWithPrefix())&CUST_ID=\(Int(custId)!)&MOBILE_NO=\(mobileNo)&EMAIL=\(emailForCommunication)&TXN_AMOUNT=\(amount)"
        }else{
          MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.error_msg_for_add_money, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: nil)
            return String()
        }
    }
    func getFreechargeURL() -> String{
        let appStartUpData = SharedPreferenceHelper.getAppStartUpData()
        if let token = linkedWallet?.token, let userId = QRSessionManager.getInstance()?.getUserId(),let freechargeAddMoneyURL = appStartUpData?.freechargeAddMoneyURL, let freechargeAddMoneyCallbackURL = appStartUpData?.freechargeAddMoneyCallbackURL{
                return "\(freechargeAddMoneyURL)loginToken=\(token)&amount=\(amount)&callbackUrl=\(freechargeAddMoneyCallbackURL)&metadata=\(userId)"
        }else{
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.error_msg_for_add_money, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: nil)
            return String()
        }
    }
    
    func getAmazonURL(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getAmazonURLToAddMoney(userId: (QRSessionManager.getInstance()?.getUserId())!, amount: amount, viewController: self) {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let urlString = responseObject!["resultData"] as? String
                let request = APayChargeRequest.build({ builder in
                builder?.withPayURL(urlString)
                    builder?.withRequestId(self.generateOrderIDWithPrefix())
                })
                AmazonPay.sharedInstance().charge(request,apayChargeCallback: self)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func generateOrderIDWithPrefix () -> String{
        AppDelegate.getAppDelegate().log.debug("generateOrderIDWithPrefix()")
        return QRSessionManager.getInstance()!.getUserId()+DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)!
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = webView.url
        AppDelegate.getAppDelegate().log.debug("decidePolicyFor: \(String(describing: url))")
        checkAddMoneyFlowIsCompleted()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        QuickRideProgressSpinner.stopSpinner()
        let url = webView.url
        AppDelegate.getAppDelegate().log.debug( "didFinish: \(String(describing: url))")
        checkAddMoneyFlowIsCompleted()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate( ).log.debug("webViewDidFail \(String(describing: webView.url))")
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("backButtonAction()")
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.handler!()
                self.navigationController?.popViewController(animated: false)
            }
        })
    }
    
    func showSuccessAlert(walletType: String){
        let animationAlertController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimationAlertController") as! AnimationAlertController
        animationAlertController.initializeDataBeforePresenting(activatedMessage: String(format: Strings.add_money_success_msg, arguments: [walletType]), isFromLinkedWallet: true, handler: nil)
        animationAlertController.view!.layoutIfNeeded()
    }
    private func checkAddMoneyFlowIsCompleted(){
       if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            webView.evaluateJavaScript("document.documentElement.outerHTML") { (result, error) in
                if result != nil && (result! as AnyObject).contains(Strings.paytm_Add_money_success){
                    self.handler!()
                    self.navigationController?.popViewController(animated: false)
                    self.showSuccessAlert(walletType: self.linkedWallet!.type!)
                }
            }
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
        webView.evaluateJavaScript("document.documentElement.outerHTML") { (result, error) in
            if result != nil && (result! as AnyObject).contains(Strings.mobikwick_Add_money_success){
                self.handler!()
                self.navigationController?.popViewController(animated: false)
                self.showSuccessAlert(walletType: self.linkedWallet!.type!)
            }
        }
        }else if linkedWallet?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
        webView.evaluateJavaScript("document.documentElement.outerHTML") { (result, error) in
            if result != nil && (result! as AnyObject).contains(Strings.freecharge_Add_money_success){
                self.handler!()
                self.navigationController?.popViewController(animated: false)
                self.showSuccessAlert(walletType: self.linkedWallet!.type!)
            }
        }
        }
    }
}
//MARK: APayChargeCallbackDelegate
extension AddMoneyWebViewController: APayChargeCallbackDelegate{
    func onSuccess(_ response: APayChargeResponse!) {
        self.handler!()
        self.navigationController?.popViewController(animated: false)
        self.showSuccessAlert(walletType: self.linkedWallet!.type!)
    }
    
    func onFailure(_ error: Error!) {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : nil,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.handler!()
                self.navigationController?.popViewController(animated: false)
            }
        })
    }
    
    func onMobileSDKError(_ error: Error!) {
        //mobile sdk specific error
    }
    
    func onNetworkUnavailable() {
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
    }
    
    func onCancel() {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.handler!()
                self.navigationController?.popViewController(animated: false)
            }
        })
    }
    
}



