//
//  CancellationReferViewController.swift
//  Quickride
//
//  Created by Vinutha on 03/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancellationReferViewController: UIViewController {

    //MARK: Outlets
     @IBOutlet weak var backGroundView: UIView!
     @IBOutlet weak var contentView: UIView!
     @IBOutlet weak var referPointsLabel: UILabel!
     @IBOutlet weak var referButton: UIButton!
    
    //MARK: Variables
    private var referNowtitle: String?
    func initializeData(referNowtitle: String){
        self.referNowtitle = referNowtitle
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                   animations: { [weak self] in
                    guard let self = `self` else {return}
                    self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        referPointsLabel.text = referNowtitle
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @IBAction func referNowTapped(_ sender: Any){
        AppDelegate.getAppDelegate().log.debug("referThroughThroughWhatsApp()")
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                let referralURL = String(format: Strings.share_and_earn_msg, arguments: [(UserDataCache.getInstance()?.getReferralCode() ?? ""),url,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
                let urlStringEncoded = StringUtils.encodeUrlString(urlString: referralURL)
                let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded)")
                if UIApplication.shared.canOpenURL(url! as URL) {
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }else{
                    MessageDisplay.displayAlert(messageString: Strings.can_not_find_whatsup, viewController: self,handler: nil)
                }
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
}
