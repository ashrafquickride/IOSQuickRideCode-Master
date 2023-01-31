//
//  WebViewController.swift
//  Quickride
//
//  Created by rakesh on 1/8/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
        
    @IBOutlet weak var backButton: UIButton!
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var titleString : String?
    var url : URL?
    var backImage: UIImage?
    var successUrl: URL?
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initializeDataBeforePresenting(titleString : String?,url : URL?,actionComplitionHandler: actionComplitionHandler?){
        self.titleString = titleString
        self.url = url
        self.actionComplitionHandler = actionComplitionHandler
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = self.titleString
        if backImage != nil {
            backButton.setImage(backImage, for: .normal)
        }
        setupWebView()
        if let url = self.url {
            let request = URLRequest(url: url)
            QuickRideProgressSpinner.startSpinner()
            webView.load(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func setupWebView() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
        NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                webView.leftAnchor
                    .constraint(equalTo: self.view.leftAnchor),
                webView.bottomAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                webView.rightAnchor
                    .constraint(equalTo: self.view.rightAnchor)
        ])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug( "webViewDidFinish: \(String(describing: webView.url))")
        if webView.url == successUrl{
            if let actionComplitionHandler = actionComplitionHandler {
                actionComplitionHandler(true)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        QuickRideProgressSpinner.startSpinner()
        AppDelegate.getAppDelegate().log.debug("webViewDidFail \(String(describing: webView.url))")
    }
}
