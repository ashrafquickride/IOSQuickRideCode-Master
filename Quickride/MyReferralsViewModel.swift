//
//  MyReferralsViewModel.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol MyReferralsViewModelDelegate {
    func handleSuccessResponse()
}

class MyReferralsViewModel {
    
    //MARK: Variables
    var referralStats: ReferralStats?
    var referralLeaderList = [ReferralLeader]()
    var shareAndEarnOffers = [ShareAndEarnOffer]()
    var rewardsTermsAndConditions = [String : [String]]()
    var accountTransactionDetails : [AccountTransaction] = [AccountTransaction]()
    
    func getUserReferralsDetails(delegate: MyReferralsViewModelDelegate,viewController: UIViewController){
        UserRestClient.getUserReferralStats(userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.referralStats = Mapper<ReferralStats>().map(JSONObject: responseObject!["resultData"])
                delegate.handleSuccessResponse()
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func getreferralLeaderList(delegate: MyReferralsViewModelDelegate,viewController: UIViewController){
        UserRestClient.getReferralLeaderList(){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.referralLeaderList = Mapper<ReferralLeader>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ReferralLeader]()
                delegate.handleSuccessResponse()
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func prepareOfferListAndUpdateUI() {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        ReferAndRewardsTermsAndConditionDetailsParser.getInstance().getRewardsTermsAndConditionElement{ (rewardsTermsAndConditions) in
            for termsAndCondtion in rewardsTermsAndConditions!.referAndRewardsTermsAndConditions!{
                self.rewardsTermsAndConditions.updateValue(termsAndCondtion.terms_and_conditions!, forKey: termsAndCondtion.type!)
            }
            if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                self.shareAndEarnOffers.append(ShareAndEarnOffer(type: RewardsTermsAndConditions.REFER_FRIENDS, title:String(format: Strings.refer_and_earn_title, arguments: [String(pointsAfterVerification + pointsAfterFirstRide),String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), rewardDetailIamge: UIImage(named: "refer_earn_image")!, backGroundColor: [UIColor(netHex: 0xF50364)], buttonText: Strings.refer_now, termsAndCondition: self.rewardsTermsAndConditions[RewardsTermsAndConditions.REFER_FRIENDS]!, stepOneTitle: String(format: Strings.refer_earn_title1, arguments: [String(pointsAfterVerification)]), stepTwoTitle: String(format: Strings.refer_earn_title2, arguments: [String(pointsAfterFirstRide)]), stepThreeTitle: String(format: Strings.refer_earn_title3, arguments: [String(clientConfiguration.percentCommissionForReferredUser),Strings.percentage_symbol]), stepOneText: Strings.refer_earn_desc1, stepThreeText: Strings.refer_earn_desc3, referralCode: true, sampleEmail: false,stepTwoText: Strings.refer_earn_desc2))
            }
            self.shareAndEarnOffers.append(ShareAndEarnOffer(type: RewardsTermsAndConditions.REFER_ORGANIZATION, title: String(format: Strings.refer_orgnisation_title, arguments: [String(clientConfiguration.maximumOrganizationReferralPoints)]), rewardDetailIamge: UIImage(named: "refer_orgnisation")!, backGroundColor: [UIColor(netHex:0x1FBFC5), UIColor(netHex:0x23CD60)], buttonText: Strings.refer_now, termsAndCondition: self.rewardsTermsAndConditions[RewardsTermsAndConditions.REFER_ORGANIZATION]!, stepOneTitle: Strings.orgnisation_title1, stepTwoTitle: Strings.orgnisation_title2, stepThreeTitle: String(format: Strings.orgnisation_title3, arguments: [String(clientConfiguration.maximumOrganizationReferralPoints)]), stepOneText: Strings.orgnisation_desc1, stepThreeText: String(format: Strings.orgnisation_desc3, arguments: [String(clientConfiguration.maximumOrganizationReferralPoints)]), referralCode: false, sampleEmail: true, stepTwoText: Strings.orgnisation_desc2))
            self.checkAndUpdateCommunityReferralToList()
        }
    }
    
    private func checkAndUpdateCommunityReferralToList(){
        if self.rewardsTermsAndConditions.keys.contains(RewardsTermsAndConditions.REFER_COMMUNITY){
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            self.shareAndEarnOffers.append(ShareAndEarnOffer(type: RewardsTermsAndConditions.REFER_COMMUNITY,title: String(format: Strings.refer_community_title, arguments: [String(clientConfiguration.maximumCommunityReferralPoints)]), rewardDetailIamge: UIImage(named: "refer_community")!, backGroundColor: [UIColor(netHex:0xC01F5D), UIColor(netHex:0x9122C5)], buttonText: Strings.refer_now, termsAndCondition: self.rewardsTermsAndConditions[RewardsTermsAndConditions.REFER_COMMUNITY]!, stepOneTitle: Strings.community_title1, stepTwoTitle: Strings.community_title2, stepThreeTitle: String(format: Strings.community_title3, arguments: [String(clientConfiguration.maximumCommunityReferralPoints)]), stepOneText: Strings.community_desc1, stepThreeText: String(format: Strings.community_desc3, arguments: [String(clientConfiguration.maximumCommunityReferralPoints)]), referralCode: false, sampleEmail: false,stepTwoText: Strings.community_desc2))
        }
    }
    
    func shareReferralContext(urlString : String, viewController: UIViewController){
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
                AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.REFERRAL_CREATED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","time of creation": DateUtils.getDateStringFromNSDate(date: NSDate(), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_hh_mm_aaa) ?? "" ], uniqueField: User.FLD_USER_ID)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
                AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.REFERRAL_IGNORED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
            }
        }
        viewController.present(avc, animated: true, completion: nil)
    }
    
    
    func getTransactionDetailsForWalletSource(complitionHandler: @escaping(_ responseError: ResponseError?,_ error: NSError?)-> ()) {
        AppDelegate.getAppDelegate().log.debug("getTransactionDetails()")
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.getTransactionDetails(userId: UserDataCache.getCurrentUserId()) { (responseObject, error) -> Void in
            DispatchQueue.main.async(execute: {
                QuickRideProgressSpinner.stopSpinner()
            })
            let result = RestResponseParser<AccountTransaction>().parseArray(responseObject: responseObject, error: error)
            if let accountTransactionDetails = result.0 {
                self.filterTransactions(accountTransactions: accountTransactionDetails)
                    complitionHandler(result.1,result.2)
            }
            complitionHandler(result.1,result.2)
        }
    }
    
    private func filterTransactions(accountTransactions: [AccountTransaction]){
            accountTransactionDetails = accountTransactions.filter{$0.walletSource == AccountTransaction.WALLET_SOURCE_TYPE_REWARDS }
        if !accountTransactionDetails.isEmpty {
        accountTransactionDetails = self.accountTransactionDetails.reversed()
            return
        }
}
}
    
struct ShareAndEarnOffer {
    let type: String
    let title : String
    let rewardDetailIamge : UIImage
    var backGroundColor = [UIColor]()
    var termsAndCondition = [String]()
    let stepOneTitle: String
    let stepTwoTitle: String
    let stepThreeTitle: String
    let stepOneText: String
    let stepThreeText: String
    let referralCode : Bool
    let sampleEmail : Bool
    let stepTwoText: String
    let buttonText : String?
    
    init(type: String,title : String,rewardDetailIamge : UIImage,backGroundColor: [UIColor],buttonText : String?,termsAndCondition : [String],stepOneTitle: String,stepTwoTitle: String,stepThreeTitle: String,stepOneText: String,stepThreeText: String,referralCode : Bool,sampleEmail : Bool,stepTwoText: String) {
        
        self.type = type
        self.title = title
        self.rewardDetailIamge = rewardDetailIamge
        self.backGroundColor = backGroundColor
        self.buttonText = buttonText
        self.termsAndCondition = termsAndCondition
        self.stepOneTitle = stepOneTitle
        self.stepTwoTitle = stepTwoTitle
        self.stepThreeTitle = stepThreeTitle
        self.stepOneText = stepOneText
        self.stepThreeText = stepThreeText
        self.referralCode = referralCode
        self.sampleEmail = sampleEmail
        self.stepTwoText = stepTwoText
    }
}
