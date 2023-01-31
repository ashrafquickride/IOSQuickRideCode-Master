//
//  TMWEncashSuccessViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 12/28/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class TMWEncashSuccessViewController: ModelViewController {
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var clapsView: UIView!
    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var encashMessageLabel: UILabel!
    
    @IBOutlet weak var referMessageLabel: UILabel!
    
    @IBOutlet weak var referBtn: UIButton!
    var message : String?

    func initializeMessage(message : String)
    {
        self.message = message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 8
        alertView.layer.masksToBounds = true
        ViewCustomizationUtils.addCornerRadiusToView(view: referBtn, cornerRadius: 3.0)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TMWEncashSuccessViewController.backGroundViewTapped(_:))))
        self.encashMessageLabel.text = message
        let attributedString = NSMutableAttributedString(string: Strings.redemption_sucess_msg)
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrributeWithUnderline(textColor: UIColor(netHex:0x0A60FF), textSize: 13), range: (Strings.redemption_sucess_msg as NSString).range(of: "Refer Once – Earn Everyday"))
        self.referMessageLabel.attributedText = attributedString
        referMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TMWEncashSuccessViewController.navigateToReferEarnOfferURl(_:))))
    }
    @objc func navigateToReferEarnOfferURl(_ sender: UITapGestureRecognizer)
    {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.refer_once_offers_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            
            webViewController.initializeDataBeforePresenting(titleString: Strings.refer_and_rewards, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
    @IBAction func referButtonTapped(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        let shareEarnVC = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController)
         ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: shareEarnVC, animated: false)
}

    
}
