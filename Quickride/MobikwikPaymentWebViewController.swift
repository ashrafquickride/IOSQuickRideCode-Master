//
//  MobikwikPaymentWebViewController.swift
//  Quickride
//
//  Created by Vinutha on 7/16/18.
//  Copyright © 2018 iDisha. All rights reserved.
//

import Foundation
import UIKit

typealias mobikwikPaymentSuccessResponseHandler = ()->Void

class MobikwikPaymentWebViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    var amount : Int?
    var orderId : String?
    var userId : String?
    var isMobikwikWallet: Bool = true
    var handler : mobikwikPaymentSuccessResponseHandler?

    func initializeData(userId : String,amount : Int,orderId : String, isMobikwikWallet: Bool,handler: @escaping mobikwikPaymentSuccessResponseHandler){
        self.amount = amount
        self.orderId = orderId
        self.userId = userId
        self.isMobikwikWallet = isMobikwikWallet
        self.handler = handler
    }

    override func viewDidLoad() {
        var url: URL?
        if isMobikwikWallet{
           url = URL(string:getMobiqwikWalletURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        else{
           url = URL(string:getMobiqwikNetBankingURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        
        let request = URLRequest(url:url! as URL)
        webView.delegate = self
        QuickRideProgressSpinner.startSpinner()
        webView.loadRequest(request)

    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.scrollView.contentInset = UIEdgeInsets.zero
    }
    func getMobiqwikWalletURL() -> String{
        if AppConfiguration.useProductionServerForPG{
            return "\(AppConfiguration.MOBIQWIK_MERCHANT_URL_PRODUCTION)amount=\(amount!*100)&buyerEmail=\(UserDataCache.getInstance()!.getCurrentUserEmail())&currency=\(AppConfiguration.MOBIKWIK_CURRENCY)&merchantIdentifier=\(AppConfiguration.MOBIQWIK_MERCHANT_ID_PRODUCTION)&orderId=\(orderId!)&productDescription=Paying to Quick Ride&product1Description=\(userId!)&showMobile=1&returnUrl=\(AppConfiguration.MOBIQWIK_MERCHANT_RETURN_URL_PRODUCTION)&isAutoRedirect=true&debitorcredit=wallet&bankid=MW"
        }else{

            return  "\(AppConfiguration.MOBIQWIK_MERCHANT_URL_STAGGING)amount=\(amount!*100)&buyerEmail=\(UserDataCache.getInstance()!.getCurrentUserEmail())&currency=\(AppConfiguration.MOBIKWIK_CURRENCY)&merchantIdentifier=\(AppConfiguration.MOBIQWIK_MERCHANT_ID_STAGGING)&orderId=\(orderId!)&productDescription=Paying to Quick Ride&product1Description=\(userId!)&showMobile=1&returnUrl=\(AppConfiguration.MOBIKWIK_MERCHANT_RETURN_URL_STAGGING)&isAutoRedirect=true&debitorcredit=wallet&bankid=MW"
        }
    }
    func getMobiqwikNetBankingURL() -> String{
        if AppConfiguration.useProductionServerForPG{
            return "\(AppConfiguration.MOBIQWIK_MERCHANT_URL_PRODUCTION)amount=\(amount!*100)&buyerEmail=\(UserDataCache.getInstance()!.getCurrentUserEmail())&currency=\(AppConfiguration.MOBIKWIK_CURRENCY)&merchantIdentifier=\(AppConfiguration.MOBIQWIK_MERCHANT_ID_PRODUCTION)&orderId=\(orderId!)&productDescription=Paying to Quick Ride&product1Description=\(userId!)&showMobile=1&returnUrl=\(AppConfiguration.MOBIQWIK_MERCHANT_RETURN_URL_PRODUCTION)&txnType=12"
        }else{
            
            return  "\(AppConfiguration.MOBIQWIK_MERCHANT_URL_STAGGING)amount=\(amount!*100)&buyerEmail=\(UserDataCache.getInstance()!.getCurrentUserEmail())&currency=\(AppConfiguration.MOBIKWIK_CURRENCY)&merchantIdentifier=\(AppConfiguration.MOBIQWIK_MERCHANT_ID_STAGGING)&orderId=\(orderId!)&productDescription=Paying to Quick Ride&product1Description=\(userId!)&showMobile=1&returnUrl=\(AppConfiguration.MOBIKWIK_MERCHANT_RETURN_URL_STAGGING)&txnType=12"
        }
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let url = webView.request?.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug("shouldStartLoadWith \(url)")
        
        if !AppConfiguration.useProductionServerForPG && url ==  AppConfiguration.MOBIKWIK_MERCHANT_RETURN_URL_STAGGING{
            self.navigationController?.popViewController(animated: false)
            handler!()
        }
        else if url == AppConfiguration.MOBIQWIK_RETURN_URL_PRODUCTION{
            let content = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
            
            if content != nil && content!.contains(Strings.mobikwik_recharge_success_msg){
                self.navigationController?.popViewController(animated: false)
                handler!()
            }
        }
        return true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug("webViewDidFinishLoadWithError \(webView.request?.url?.absoluteString)")
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        AppDelegate.getAppDelegate().log.debug("webViewDidStartLoad : \(webView.request?.url?.absoluteString)")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        QuickRideProgressSpinner.stopSpinner()
        let url = webView.request?.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug( "webViewDidFinishLoad: \(url)")
        if !AppConfiguration.useProductionServerForPG && url == AppConfiguration.MOBIKWIK_MERCHANT_RETURN_URL_STAGGING{
            self.navigationController?.popViewController(animated: false)
            handler!()
        }
        else if url == AppConfiguration.MOBIQWIK_RETURN_URL_PRODUCTION{
            let content = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")

            if content != nil && content!.contains(Strings.mobikwik_recharge_success_msg){
                self.navigationController?.popViewController(animated: false)
                handler!()
            }
        }

    }

    @IBAction func backButtonAction(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("backButtonAction()")
            MessageDisplay.displayErrorAlertWithAction(title: Strings.oops, isDismissViewRequired : false, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.yes_caps == result{
                    self.navigationController?.popViewController(animated: false)
                }
            })
    }
}



