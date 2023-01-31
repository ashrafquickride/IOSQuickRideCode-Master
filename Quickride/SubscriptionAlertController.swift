//
//  SubscriptionAlertController.swift
//  Quickride
//
//  Created by rakesh on 5/24/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI
import ObjectMapper

class SubscriptionAlertController : UIViewController,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    

    @IBOutlet weak var subscriptionInfoLink: UILabel!
    
    var isDismissViewRequired = false
    
    func intializeDataBeforePresenting(isDismissViewRequired : Bool){
        self.isDismissViewRequired = isDismissViewRequired
    }
    
    override func viewDidLoad() {
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: subscribeButton, cornerRadius: 5.0)
        createAttributedString()
        if !isDismissViewRequired{
             self.backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubscriptionAlertController.backGroundViewClicked(_:))))
        }
        self.subscriptionInfoLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SubscriptionAlertController.subscriptionLinkClicked(_:))))
    }
    @objc func backGroundViewClicked(_ gesture : UITapGestureRecognizer){
            self.view.removeFromSuperview()
            self.removeFromParent()
       
    }
    
    func createAttributedString(){
       
        let subscriptionText = Strings.subscription_scheme + Strings.subscription_pay_criteria + String(ConfigurationCache.getObjectClientConfiguration().subscriptionAmount) + Strings.subscription_text
        let attributedString = NSMutableAttributedString(string: subscriptionText)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithUnderline(textColor: UIColor(netHex: 0x007AFF), textSize: 14), range: (subscriptionText as NSString).range(of: Strings.subscription_scheme))
        
       attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x000000), textSize: 14), range: (subscriptionText as NSString).range(of: Strings.subscription_pay_criteria + String(ConfigurationCache.getObjectClientConfiguration().subscriptionAmount) + Strings.subscription_text))
        
        subscriptionInfoLink.attributedText = attributedString

        
        
    }
    
    fileprivate func doRecharge() {
        self.view.removeFromSuperview()
        self.removeFromParent()
        let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: paymentViewController, animated: false)
    }
    
    
    @IBAction func subscribeBtnClicked(_ sender: Any) {
        
        MessageDisplay.displayErrorAlertWithAction(title: Strings.subscription_confirmation, isDismissViewRequired: false, message1: Strings.subs_message, message2: nil, positiveActnTitle: Strings.confirm_caps, negativeActionTitle: Strings.cancel_caps, linkButtonText: nil, viewController: self) { (result) in
            if result == Strings.confirm_caps{
                self.doSubscribe()
            }
        }
    }
    
    func doSubscribe(){
        let account = UserDataCache.getInstance()!.userAccount
        
        let subscriptionAmount = Double(ConfigurationCache.getObjectClientConfiguration().subscriptionAmount)
        if account != nil && (account!.balance! - account!.reserved!) < subscriptionAmount {
            doRecharge()
        }else{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.subscribeToCashTransaction(userId: QRSessionManager.getInstance()!.getUserId(), status: User.SUBS_STATUS_CURRENT,viewController: self, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil {
                    if responseObject!["result"] as! String == "SUCCESS"{
                        UserDataCache.SUBSCRIPTION_STATUS = false
                        UserDataCache.getInstance()?.refreshAccountInformationInCache()
                        self.view.removeFromSuperview()
                        self.removeFromParent()
                        UIApplication.shared.keyWindow?.makeToast( Strings.subscription_success_msg)
                    }else if responseObject!["result"] as! String == "FAILURE"{
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        if responseError != nil && responseError?.errorCode == AccountException.INSUFFICIENT_FUNDS_IN_ACCOUNT{
                            MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self, handler: { (result) in
                                self.doRecharge()
                            })
                        }else{
                            UserDataCache.SUBSCRIPTION_STATUS = true
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                        }
                    }else{
                        UserDataCache.SUBSCRIPTION_STATUS = true
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                    
                    
                }else{
                    UserDataCache.SUBSCRIPTION_STATUS = true
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
        
    }
    
    @IBAction func helpBtnClicked(_ sender: Any) {
        let userMail = UserDataCache.getInstance()!.getCurrentUserEmail()
        if userMail.isEmpty{
            HelpUtils.sendEmailToSupport(viewController: self, image: nil, listOfIssueTypes: Strings.list_of_issue_types)
        }
        if SharedPreferenceHelper.getSubscriptionMailSentStatus(){
           UIApplication.shared.keyWindow?.makeToast( String(format: Strings.support_mail_message,userMail))
           return
        }
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.sendSubscriptionMailFromSupport(userId: QRSessionManager.getInstance()!.getUserId(), viewController: self) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    
                    MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: nil, message2: String(format: Strings.support_mail_message,userMail), positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: nil)
                    SharedPreferenceHelper.setSubscriptionMailSent(status: true)
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
       
      
   }
    
    @objc func subscriptionLinkClicked(_ gesture : UITapGestureRecognizer){
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.subscription_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.quickride, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
