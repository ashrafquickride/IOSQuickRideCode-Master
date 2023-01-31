//
//  ReferAndEarnTableViewCell.swift
//  Quickride
//
//  Created by HK on 29/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferAndEarnTableViewCell: UITableViewCell {

    @IBOutlet weak var referpointsAndCommissionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    func intializeViews(referralStats : ReferralStats){
        userNameLabel.text = UserDataCache.getInstance()?.userProfile?.userName
        if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            referpointsAndCommissionLabel.text = String(format: Strings.earn_points_and_commission, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol])
        }
    }
    
    @IBAction func referNowTapped(_ sender: Any) {
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                self.shareReferralContext(urlString: url)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String) {
        let message = String(format: Strings.share_and_earn_msg, arguments: [UserDataCache.getInstance()?.getReferralCode() ?? "",urlString,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
        let activityItem: [AnyObject] = [message as AnyObject]
        let vc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            vc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        vc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            }else{
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController)
        self.parentViewController?.navigationController?.pushViewController(destViewController, animated: true)
    }
}
