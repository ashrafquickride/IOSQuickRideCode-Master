//
//  TMWRegistrationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/27/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import MessageUI
import WebKit

class TMWRegistrationViewController : ModelViewController, WKNavigationDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var applyBtn: UIButton!
    
    @IBOutlet var clickHereBtn: UIButton!

    @IBOutlet weak var tmwTitleLabel: UILabel!
    
    @IBOutlet weak var tmwTitleLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tmwEarnedPointsLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tmwKnowMoreLabel: UILabel!
    
    @IBOutlet weak var knowMoreLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tmwSignUpStepsTextView: UILabel!
    
    @IBOutlet weak var signUpStepsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var webViewBackGround: UIView!
        
    @IBOutlet weak var supportLinkBtn: UIButton!
    
    @IBOutlet weak var supportNoBtn: UIButton!
    
    var clientConfiguration : ClientConfigurtion?
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
	definesPresentationContext = true
        self.clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if self.clientConfiguration == nil{
            self.clientConfiguration = ClientConfigurtion()
        }
        scrollView.isScrollEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        ViewCustomizationUtils.addCornerRadiusToView(view: applyBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: scrollView, cornerRadius: 10.0)
        tmwTitleLabel.text = Strings.tmw_title
        self.scrollViewWidthConstraint.constant = self.view.frame.size.width * 0.90
        tmwTitleLblHeightConstraint.constant = calculateAndReturnHeight(message: Strings.tmw_title, removableWidth: 40) + 5
        tmwEarnedPointsLblHeightConstraint.constant = calculateAndReturnHeight(message: Strings.tmw_earned_points_title, removableWidth: 40)
        knowMoreLblHeightConstraint.constant = calculateAndReturnHeight(message: Strings.tmw_know_more_lbl, removableWidth: 115)
        tmwSignUpStepsTextView.text = Strings.tmw_sign_up_steps
        signUpStepsHeightConstraint.constant = calculateAndReturnHeight(message: Strings.tmw_sign_up_steps, removableWidth: 40) + 25
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TMWRegistrationViewController.dismissTapped(_:))))
        supportLinkBtn.setTitle(clientConfiguration!.tmwSupportEmail, for: UIControl.State.normal)
        supportNoBtn.setTitle(clientConfiguration!.tmwSupportPhone, for: UIControl.State.normal)
    }
    
    private func setupWebView() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewBackGround.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: webViewBackGround.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: webViewBackGround.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: webViewBackGround.rightAnchor)
        ])
    }
    
    @objc func dismissTapped(_ gesture : UITapGestureRecognizer){
        webView.isHidden = true
        scrollView.isHidden = false
    }
    func calculateAndReturnHeight(message : String, removableWidth : CGFloat) -> CGFloat
    {
        let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 15)!]
        let rect = message.boundingRect(with: CGSize(width: self.scrollViewWidthConstraint.constant - removableWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.height
    }
    @IBAction func clickHereTapped(_ sender: Any) {
        let url = NSURL(string :  "https://themobilewallet.com/")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    @IBAction func applyBtnTapped(_ sender: Any) {
        AccountRestClient.createProbableTMWUser(userId: QRSessionManager.getInstance()!.getUserId(), targetViewController: self, completionHandler: { (responseObject, error) in
        })
        setupWebView()
        webView.isHidden = false
        scrollView.isHidden = true
        let url = URL(string:getTMWRegURL().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let request = URLRequest(url:url! as URL)
        webView.load(request)
        
    }
    func getTMWRegURL() -> String{
       
        if AppConfiguration.useProductionServerForPG{
             let user = UserDataCache.getInstance()?.currentUser
            let urlString = "https://themobilewallet.com/TMWPG/signup?retailerId=\(AppConfiguration.TMW_RETAILER_ID)&firstname=\(user!.userName)&mobileno=\(StringUtils.getStringFromDouble(decimalNumber: user!.contactNo))"
            return urlString
        }else{
            return "https://staging.themobilewallet.com/Restruct_TMWPG/signup"
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString
        AppDelegate.getAppDelegate().log.debug("\(String(describing: urlString))")
        if urlString == AppConfiguration.TMW_REDIRECTION_URL || urlString == AppConfiguration.TMW_REDIRECTION_URL_STAGGING{
            webView.isHidden = true
            scrollView.isHidden = false
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url
        AppDelegate.getAppDelegate().log.debug("\(String(describing: url))")
        if url == URL(string: AppConfiguration.TMW_REDIRECTION_URL) || url == URL(string: AppConfiguration.TMW_REDIRECTION_URL_STAGGING) {
            webView.isHidden = true
            scrollView.isHidden = false
        }
    }

    @IBAction func contactTMWSupport(_ sender: Any)
    {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setSubject("")
            mailComposeViewController.mailComposeDelegate = self
            var recepients = [String]()
            recepients.append(clientConfiguration!.tmwSupportEmail)
            mailComposeViewController.setToRecipients(recepients)
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
        }
    }
    
    @IBAction func callTMWSupport(_ sender: Any) {
        AppUtilConnect.callSupportNumber(phoneNumber: self.clientConfiguration!.tmwSupportPhone, targetViewController: self)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
