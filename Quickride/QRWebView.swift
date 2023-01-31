//
//  QRWebView.swift
//  Quickride
//
//  Created by Vinutha on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import WebKit

class QRWebView: WKWebView {

    static func getWKWebView(navigationDelegate: WKNavigationDelegate?) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = navigationDelegate
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }

}
