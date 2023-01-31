//
//  RideCompletionWithEmptySeatViewController.swift
//  Quickride
//
//  Created by Vinutha on 26/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RideCompletionWithEmptySeatViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var rideTimeLabel: UILabel!
    
    private var ride: Ride?
    private var isFromRideHistory = false
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
         definesPresentationContext = true
        if let rideEndTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride?.actualEndtime, timeFormat: DateUtils.TIME_FORMAT_hmm_a), let rideEndDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride?.actualEndtime, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_MMM_yyyy) {
            rideTimeLabel.text = rideEndTime + " | " + rideEndDate
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    //MARK: initializer
    func initialiseData(riderRide: Ride?,isFromRideHistory: Bool) {
        self.ride = riderRide
        self.isFromRideHistory = isFromRideHistory
    }
    //MARK: Method
    func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_and_earn_msg, arguments: [(UserDataCache.getInstance()?.getReferralCode() ?? ""),urlString,(UserDataCache.getInstance()?.userProfile?.userName ?? "")])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.present(avc, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func referNowClicked(_ sender: UIButton) {
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if urlString != nil{
                self.shareReferralContext(urlString: urlString!)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        if isFromRideHistory{
            self.navigationController?.popViewController(animated: false)
        }else{
            RideManagementUtils.moveToRideCreationScreen(viewController: self)
        }
    }
}
