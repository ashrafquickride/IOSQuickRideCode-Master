//
//  VideoPlayerViewController.swift
//  Quickride
//
//  Created by rakesh on 2/26/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import WebKit

class VideoPlayerViewController : ModelViewController, WKNavigationDelegate, WKUIDelegate{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var webViewBackGround: UIView!
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var url : URL?
    func initializeDataBeforePresenting(url : URL){
        self.url = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        let request = URLRequest(url: self.url!)
        webView.load(request)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VideoPlayerViewController.dismissTapped(_:))))
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
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }


}
