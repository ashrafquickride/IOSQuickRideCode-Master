//
//  ProfileVerificationUtils.swift
//  Quickride
//
//  Created by Admin on 28/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias receivingCompanyDomainsComplitionHandler = (_ domains : [String]) -> Void

class ProfileVerificationUtils {
    
    static private var profileVerificationView = ProfileVerificationView()
    
    static func displayProfileVerificationView(rideType : String?,rideId: Double,bottomPosition:  CGFloat? ,viewController : UIViewController) {
        guard let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData,!profileVerificationData.profileVerified,let displayStatus = UserDataCache.getInstance()?.getEntityDisplayStatus(key:  UserDataCache.VERIFICATION_VIEW),!displayStatus,SharedPreferenceHelper.getCountForVerificationViewDisplay() < 3,
              (SharedPreferenceHelper.getNewCompanyAddedStatus() == nil || !SharedPreferenceHelper.getNewCompanyAddedStatus()!) else{
                  return
              }
        profileVerificationView = Bundle.main.loadNibNamed("ProfileVerificationView", owner: nil, options: nil)?[0] as! ProfileVerificationView
        profileVerificationView.initializeView(rideType: rideType, profileVerificationData: profileVerificationData)
        var viewFrame = UIView()
        if let bottomPosition = bottomPosition{
            viewFrame = UIView(frame: CGRect(origin: CGPoint(x: viewController.view.frame.minX, y:  bottomPosition), size: CGSize(width:  viewController.view.frame.width, height: 50)))
        }else{
            if #available(iOS 11.0, *) {
                let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
                viewFrame = UIView(frame: CGRect(origin: CGPoint(x: viewController.view.frame.minX, y:  viewController.view.frame.maxY - 50 - (bottomPadding ?? 0)), size: CGSize(width:  viewController.view.frame.width, height: 50)))
            }else{
                viewFrame = UIView(frame: CGRect(origin: CGPoint(x: viewController.view.frame.minX, y:  viewController.view.frame.maxY - 65), size: CGSize(width:  viewController.view.frame.width, height: 50)))
            }
        }
        viewFrame.addSubview(profileVerificationView)
        viewController.view.addSubview(viewFrame)
        viewController.view!.layoutIfNeeded()
    }
    
    static func removeView(){
        profileVerificationView.isHidden = true
        profileVerificationView.removeFromSuperview()
    }
    
    static func getRequestId () -> String{
        return QRSessionManager.getInstance()!.getUserId() + DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)!
    }
    static func getCompanyDomainsBasedOnCharacters(emailDomain: String,handler: @escaping receivingCompanyDomainsComplitionHandler){
        UserRestClient.getCompanyDomains(userId: UserDataCache.getInstance()?.userId ?? "", identifier: emailDomain) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let allCompanyDomains = responseObject!["resultData"] as? [String] ?? [String]()
                handler(allCompanyDomains)
            }
        }
    }
}
