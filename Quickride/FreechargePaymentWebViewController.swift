//
//  FreechargePaymentWebViewController.swift
//  Quickride
//
//  Created by rakesh on 7/3/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Alamofire
import UIKit
import WebKit

typealias freeChargePaymentSuccessReponseHandler = ()->Void

class FreechargePaymentWebViewController : UIViewController, WKNavigationDelegate{
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var params = [String : String]()
    var rechargeAmount : Int?
    var orderId : String?
    var handler : freeChargePaymentSuccessReponseHandler?
  
   
    func initializeDataBeforePresenting(rechargeAmount : Int,orderId : String,handler : @escaping freeChargePaymentSuccessReponseHandler){
      self.rechargeAmount = rechargeAmount
      self.orderId = orderId
      self.handler = handler
    }
   
    override func viewDidLoad() {
     
        self.validateCheckSumResponseAndLoadWebviewOnSuccess(rechargeAmount: rechargeAmount!, orderId: orderId!)
    }
    
    func setupWebView() {
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug("\(String(describing: urlString))")
        if urlString != nil && urlString == self.params["surl"] {
            self.navigationController?.popViewController(animated: false)
            handler!()
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug( "webViewDidFinish: \(String(describing: webView.url))")
        if webView.url != nil && params["surl"] != nil && webView.url == URL(string: params["surl"]!) {
            handler!()
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        QuickRideProgressSpinner.startSpinner()
        AppDelegate.getAppDelegate().log.debug("webViewDidFail \(String(describing: webView.url))")
    }
    
   @IBAction func backButtonClicked(_ sender: Any) {
    MessageDisplay.displayErrorAlertWithAction(title: Strings.oops, isDismissViewRequired : false, message1: Strings.do_you_really_want_cancel_transaction, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
        if Strings.yes_caps == result{
          self.navigationController?.popViewController(animated: false)
        }
    })
    
    }

    func getPostParams(params : [String : String]) -> String? {
       
        var json = String()
        for key in params.keys{
            if params[key] != nil {
                json += "\(key)"
                json += "="
                json += params[key]!
                json += "&"
            }
        }
        if json.count > 2 {
            if let subRange = Range<String.Index>(NSRange(location: json.count - 1, length: 1), in: json) { json.removeSubrange(subRange) }
        }
        return json
    }
    
    func validateCheckSumResponseAndLoadWebviewOnSuccess(rechargeAmount : Int,orderId : String){
        
        let surl : String?
        let furl : String?
        
        if AppConfiguration.useProductionServerForPG{
            surl = AppConfiguration.FREECHARGE_PRODUCTION_SURL
            furl = AppConfiguration.FREECHARGE_PRODUCTION_FURL
        }else{
            surl = AppConfiguration.FREECHARGE_TEST_SURL
            furl = AppConfiguration.FREECHARGE_TEST_FURL
        }
          let freechargeRequest = FreeChargeRequest(amount: String(rechargeAmount), channel: AppConfiguration.FREECHARGE_CHANNEL_ID, furl: furl!, merchantId: AppConfiguration.FREECHARGE_MERCHANT_ID, merchantTxnId: orderId, metadata : QRSessionManager.getInstance()!.getUserId(),mobile:  QRSessionManager.getInstance()!.getCurrentSession().contactNo, productInfo: AppConfiguration.FREECHARGE_PRODUCT_INFO, surl: surl!)
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getChecksSumForFreeCharge(merchantRequest: freechargeRequest, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let checksum = responseObject!["resultData"] as! String
                self.params = freechargeRequest.getParams(checksum: checksum)
                let urlString : String?
                if AppConfiguration.useProductionServerForPG{
                    urlString = AppConfiguration.FREECHARGE_PRODUCTION_URL
                }else{
                    urlString = AppConfiguration.FREECHARGE_SANDBOX_URL
                }
                let url = URL(string: urlString!)
                let urlBody = self.getPostParams(params: self.params)
                self.setupWebView()
                var request = URLRequest(url: url! as URL)
                request.httpMethod = HTTPMethod.post.rawValue
                request.httpBody = urlBody!.data(using: .utf8)
                QuickRideProgressSpinner.startSpinner()
                self.webView.load(request)
                
            }else{
                 self.navigationController?.popViewController(animated: false)
                 ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
}
