//
//  SocialMediaPromotionTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 29/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SocialMediaPromotionTableViewCell: UITableViewCell {
    
    private weak var viewController: UIViewController?
    private static let FACEBOOK_URL = "https://www.facebook.com/QuickRidein"
    private static let TWITER_URL = "https://twitter.com/QuickRidein"
    private static let INSTAGRAM_URL = "https://www.instagram.com/QuickRidein"
    private static let LINKED_IN_URL = "https://www.linkedin.com/company/quickridein"
    
    private static let QUICKRIDE_FACEBOOK_PROFILE_ID = "526655274128927"
    
    func initializeSocialMediaView(viewController: UIViewController){
        self.viewController = viewController
    }
    
    @IBAction func facebookTapped(_ sender: UIButton) {
        
        if let appurl = NSURL(string : "fb://profile/\(SocialMediaPromotionTableViewCell.QUICKRIDE_FACEBOOK_PROFILE_ID)"), UIApplication.shared.canOpenURL(appurl as URL){
            UIApplication.shared.open(appurl as URL, options: [:], completionHandler: nil)
        }else{
            let url = NSURL(string :  SocialMediaPromotionTableViewCell.FACEBOOK_URL)
            if UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    @IBAction func twitterTapped(_ sender: UIButton) {
        
        if let appurl = NSURL(string : "twitter:///user?screen_name=QuickRidein"), UIApplication.shared.canOpenURL(appurl as URL){
            UIApplication.shared.open(appurl as URL, options: [:], completionHandler: nil)
        }else{
            let url = NSURL(string :  SocialMediaPromotionTableViewCell.TWITER_URL)
            if UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    @IBAction func linkedInTapped(_ sender: UIButton) {
        if let appurl = NSURL(string : "linkedin://company/QuickRidein"), UIApplication.shared.canOpenURL(appurl as URL){
            UIApplication.shared.open(appurl as URL, options: [:], completionHandler: nil)
        }else{
            let url = NSURL(string :  SocialMediaPromotionTableViewCell.LINKED_IN_URL)
            if UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
    }
    
    @IBAction func instagramTapped(_ sender: UIButton) {
        if let appurl = NSURL(string : "instagram://user?username=QuickRidein"), UIApplication.shared.canOpenURL(appurl as URL){
            UIApplication.shared.open(appurl as URL, options: [:], completionHandler: nil)
        }else{
            let url = NSURL(string :  SocialMediaPromotionTableViewCell.INSTAGRAM_URL)
            if UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
            }
        }
        
    }
}
