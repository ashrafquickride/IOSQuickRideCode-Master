//
//  QuickJobsViewController.swift
//  Quickride
//
//  Created by Quick Ride on 8/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import WebKit

class QuickJobsViewController: UIViewController,WKNavigationDelegate {
    
    private var urlToLoadForQuickjob: String?
    private var quickJobsAnimationView: QuickJobsAnimationViewController!
    
    func initialiseQuickJob(urlString: String?){
        self.urlToLoadForQuickjob = urlString
    }
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    var loaded = false
    fileprivate func loadWebView() {
        if loaded {
            return
        }
        guard let jwtToken = SharedPreferenceHelper.getJWTAuthenticationToken() else {
            return
        }
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        var urlString = clientConfiguration.quickJobsUrl
        if let url = urlToLoadForQuickjob {
            urlString = url
        }
        urlString.append("?token=")
        urlString.append(jwtToken.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        urlString.append("&userId=")
        urlString.append(SharedPreferenceHelper.getLoggedInUserId()!)
        urlString.append("&isMobile=true")
        
        if let url = URL(string: urlString) {
            if !QRReachability.isConnectedToNetwork(){
                ErrorProcessUtils.displayNetworkError(viewController: self) { (status) in
                    self.navigationController?.popViewController(animated: false)
                }
                return
            }
            
            showloadingAnimation()
            QRReachability.isInternetAvailable { (isConnectedToNetwork) in
                if !isConnectedToNetwork {
                    self.removeloadingAnimation()
                    ErrorProcessUtils.displayNetworkError(viewController: self) { (status) in
                        self.navigationController?.popViewController(animated: false)
                    }
                }else{
                    self.loaded = true
                    self.webView.load(URLRequest(url: url))
                }
            }
            
        }else{
            UIApplication.shared.keyWindow?.makeToast( "Could not load Quick Jobs, Please try later")
        }
    }
    
    override func viewDidLoad() {
       AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.QUICK_JOBS_TAP, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        setupWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        loadWebView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ContainerTabBarViewController.indexToSelect = 3
        self.navigationController?.isNavigationBarHidden = true
        displayUpdateApplicationIfRequired()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func showloadingAnimation() {
        let quickJobsAnimationVC = UIStoryboard(name: StoryBoardIdentifiers.quick_jobs__storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickJobsAnimationViewController") as! QuickJobsAnimationViewController
        
        quickJobsAnimationVC.view.frame = self.view.bounds
        quickJobsAnimationVC.willMove(toParent: self)
        quickJobsAnimationView = quickJobsAnimationVC
        self.view.addSubview(quickJobsAnimationView.view)
        quickJobsAnimationVC.didMove(toParent: self)
    }
    
    
    func displayUpdateApplicationIfRequired(){
        AppDelegate.getAppDelegate().log.debug("displayUpdateApplicationIfRequired()")
        let configurationCache = ConfigurationCache.getInstance()
        if configurationCache == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        let updateStatus = ConfigurationCache.getInstance()!.appUpgradeStatus
        if updateStatus == nil ||  configurationCache!.isAlertDisplayedForUpgrade == true{
            return
        }
        if updateStatus == User.UPDATE_REQUIRED{
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : false, message1: Strings.upgrade_version, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : nil,linkButtonText : nil,viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }else if updateStatus == User.UPDATE_AVAILABLE {
            MessageDisplay.displayErrorAlertWithAction(title: Strings.app_update_title, isDismissViewRequired : true, message1: Strings.new_version_available, message2: nil, positiveActnTitle: Strings.upgrade_caps, negativeActionTitle : Strings.later_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.upgrade_caps == result{
                    self.moveToAppStore()
                }
            })
        }
    }
    
    private func moveToAppStore(){
        AppDelegate.getAppDelegate().log.debug("moveToAppStore()")
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.please_upgrade_from_app_store, duration: 3.0, position: .center)
        }
    }
    
    private func removeloadingAnimation(){
        guard let quickJobsAnimationView = quickJobsAnimationView, quickJobsAnimationView.view != nil else {
            return
        }
        quickJobsAnimationView.view.removeFromSuperview()
        quickJobsAnimationView.removeFromParent()
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeloadingAnimation()
        AppDelegate.getAppDelegate().log.debug( "webViewDidFinish: \(String(describing: webView.url))")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showloadingAnimation()
        AppDelegate.getAppDelegate().log.debug("webViewDidFail \(String(describing: webView.url))")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showloadingAnimation() 
        AppDelegate.getAppDelegate().log.debug("didFailProvisionalNavigation \(String(describing: webView.url))")
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        showloadingAnimation()
        AppDelegate.getAppDelegate().log.debug("didReceiveServerRedirectForProvisionalNavigation \(String(describing: webView.url))")
    }
    
}
