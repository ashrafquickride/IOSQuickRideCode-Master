//
//  RewardsViewController.swift
//  Quickride
//
//  Created by Admin on 07/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RewardsViewController : UIViewController {

    @IBOutlet weak var rewardsInfoView: UIStackView!
    @IBOutlet weak var referalDetailsTableView: UITableView!
    @IBOutlet weak var msgLabel: UILabel!
    
    private var myReferralsViewModel = MyReferralsViewModel()
    
   
    var userAccount : Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTransactionDetailForRefund()
        var clientConfiguration = ConfigurationCache.getInstance()!.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.maxPercentageMovingRewardsToEarnedPoints > 0 {
            let attributedString = NSMutableAttributedString(string: String(format: Strings.earned_section_msg, arguments: [String(clientConfiguration!.maxPercentageMovingRewardsToEarnedPoints),Strings.percentage_symbol]))
            let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            msgLabel.attributedText = attributedString
        } else {
            msgLabel.text = Strings.earned_section_msg_for_ridetaker
        }
        referalDetailsTableView.register(UINib(nibName: "RewardPointsTableViewCell", bundle: nil), forCellReuseIdentifier: "RewardPointsTableViewCell")
        referalDetailsTableView.register(UINib(nibName: "TransationViewTableViewCell", bundle: nil), forCellReuseIdentifier: "TransationViewTableViewCell")
        referalDetailsTableView.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        referalDetailsTableView.register(UINib(nibName: "ReferralTableViewCell", bundle: nil), forCellReuseIdentifier: "ReferralTableViewCell")
        self.referalDetailsTableView.dataSource = self
        self.referalDetailsTableView.delegate = self
        referalDetailsTableView.reloadData()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAccountInfo()
        
   }
    
    private func getTransactionDetailForRefund(){
        if QRReachability.isConnectedToNetwork() == false {
            DispatchQueue.main.async(execute: {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            })
            return
        }
        myReferralsViewModel.getTransactionDetailsForWalletSource { (responseError, error) in
            if responseError != nil || error != nil {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
            }else {
                self.referalDetailsTableView.reloadData()
            }
        }
    }
    
    
    func refreashData(){
        referalDetailsTableView.reloadData()
    }
    
    
    func getAccountInfo(){
        AppDelegate.getAppDelegate().log.debug("getAccountInfo()")
        UserDataCache.getInstance()?.getAccountInformation(completionHandler: { (responseObject, error) -> Void in
            if responseObject != nil{
                self.userAccount = responseObject
                self.referalDetailsTableView.reloadData()
            }
        })                   
    }

    @IBAction func gotItBtnClicked(_ sender: Any) {
        rewardsInfoView.isHidden = true
        SharedPreferenceHelper.setDisplayStatusForRewardsInfoView(status: true)
    }
}


extension RewardsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       switch section {
     case 0:
           if self.userAccount != nil {
               return 1
           }else{
               return 0
           }
       case 1:
           if self.myReferralsViewModel.accountTransactionDetails.count != 0 {
               return 1
           } else {
               return 0
           }
        case 2:
           let count = self.myReferralsViewModel.accountTransactionDetails.count
           if count > 0 {
               if count < 6 {
                   return count
               } else {
                   return 5
               }
           }
           return 0
       case 3:
           return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RewardPointsTableViewCell", for: indexPath) as! RewardPointsTableViewCell
           cell.totalRefundPoints.text = StringUtils.getPointsInDecimal(points: self.userAccount!.rewardsPoints)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransationViewTableViewCell", for: indexPath) as! TransationViewTableViewCell
            cell.intialisingDataForUpdateUi(isFromRewardHistory: true)
            if myReferralsViewModel.accountTransactionDetails.count > 5 {
                cell.viewAllBtn.isHidden = false
            } else {
                cell.viewAllBtn.isHidden = true
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
            cell.transationIconImageView.isHidden = true
            cell.balenceRewardPointsLbl.isHidden = false
            cell.seperatorView.isHidden = false
            
            if self.myReferralsViewModel.accountTransactionDetails.endIndex <= indexPath.row{
                return cell
            }
            cell.initializeCellData(accountTransaction: myReferralsViewModel.accountTransactionDetails[indexPath.row])
            return cell
        case 3:
            if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReferralTableViewCell", for: indexPath) as! ReferralTableViewCell
                cell.referViewBottomConstant.constant = 0
                cell.referViewLeadindConstant.constant = 0
                cell.referViewTopConstant.constant = 0
                cell.referViewTralingConstant.constant = 0
                cell.quickRideCardView.cornerRadius = 0
                cell.seperatorView.isHidden = false
              let referalPoints = String(pointsAfterVerification + pointsAfterFirstRide)
            let percentageNumber = String(clientConfiguration.percentCommissionForReferredUser)

                cell.updateCellData(referralPoints: referalPoints, percentageNumber: percentageNumber, delegate: self)
                myReferralsViewModel.prepareOfferListAndUpdateUI()
                return cell
            }else{
                return UITableViewCell()
            }
           
        default :
            let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            cell.backgroundColor = .clear
            return cell
        }
    }

}


extension RewardsViewController: ReferralTableViewCellDelegate{
    func referNowButtonpressed() {
        AppDelegate.getAppDelegate().log.debug("referThroughThroughWhatsApp()")
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        guard let referralCode = UserDataCache.getInstance()?.getReferralCode() else { return }
        
        InstallReferrer.prepareURLForDeepLink(referralCode: referralCode) { (urlString)  in
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
    
    func howItWorksPressed() {
        if myReferralsViewModel.shareAndEarnOffers.isEmpty{
            return
        }
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HowItWorkPopUpForShareAndEarnViewController") as! HowItWorkPopUpForShareAndEarnViewController
        showTermsAndConditionsViewController.initializeView(shareAndEarnOffer: myReferralsViewModel.shareAndEarnOffers[0])
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
    
    func shareButtonPressed() {
        guard let referralCode = UserDataCache.getInstance()?.getReferralCode() else { return }
        InstallReferrer.prepareURLForDeepLink(referralCode: referralCode) { (urlString)  in
            if let url = urlString{
                self.myReferralsViewModel.shareReferralContext(urlString: url,viewController: self)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
}
