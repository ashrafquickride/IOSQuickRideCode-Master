//
//  JobPromotionCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 15/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class JobPromotionCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var adsView: UIView!
    
    //MARK: Initialiser
    func setupUI(jobPromotionHTMLString: String) {
        adsView.addShadow()
        setupAndLoadWebView(jobPromotionHTMLString: jobPromotionHTMLString)
    }

    private func setupAndLoadWebView(jobPromotionHTMLString: String) {
        let webView = QRWebView.getWKWebView(navigationDelegate: nil)
        webView.isUserInteractionEnabled = false
        adsView.backgroundColor = .white
        adsView.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: adsView.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: adsView.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: adsView.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: adsView.rightAnchor)
        ])
        webView.loadHTMLString(jobPromotionHTMLString, baseURL: nil)
    }
    
}
