//
//  MyReferralsViewController.swift
//  Quickride
//
//  Created by Halesh on 21/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyReferralsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var myReferralTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    
    //MARK: Variables
    private var myReferralsViewModel = MyReferralsViewModel()
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        myReferralsViewModel.prepareOfferListAndUpdateUI()
        myReferralsViewModel.getUserReferralsDetails(delegate: self, viewController: self)
        myReferralsViewModel.getreferralLeaderList(delegate: self, viewController: self)
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setUpUI(){
        myReferralTableView.register(UINib(nibName: "ReferralTableViewCell", bundle: nil), forCellReuseIdentifier: "ReferralTableViewCell")
        myReferralTableView.register(UINib(nibName: "CommunityOrOrganisationReferalTableViewCell", bundle: nil), forCellReuseIdentifier: "CommunityOrOrganisationReferalTableViewCell")
        backButton.changeBackgroundColorBasedOnSelection()
        myReferralTableView.dataSource = self
        myReferralTableView.reloadData()
        myReferralTableView.estimatedRowHeight = 358
        myReferralTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func helpIconTapped(_ sender: Any) {
        
    }
    @IBAction func termAndConditionTapped(_ sender: Any) {
      let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTermsAndConditionsViewController") as! ShowTermsAndConditionsViewController
        showTermsAndConditionsViewController.initializeDataBeforePresenting(termsAndConditions: myReferralsViewModel.referralStats?.termsAndConditions ?? [String](), titleString: Strings.terms_and_conditions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
}
//MARK: UITableViewDataSource
extension MyReferralsViewController: MyReferralsViewModelDelegate{
    func handleSuccessResponse() {
        myReferralTableView.reloadData()
        if let referralStats = myReferralsViewModel.referralStats,SharedPreferenceHelper.getReferralCurrentLevel() != 0, SharedPreferenceHelper.getReferralCurrentLevel() < referralStats.level{
            let nextLevelReachedViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NextLevelReachedViewController") as! NextLevelReachedViewController
            nextLevelReachedViewController.initializeNextLevelView(referralStats: referralStats)
            ViewControllerUtils.addSubView(viewControllerToDisplay: nextLevelReachedViewController)
        }
        SharedPreferenceHelper.setReferralCurrentLevel(count: myReferralsViewModel.referralStats?.level)
    }
}

//MARK: UITableViewDataSource
extension MyReferralsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReferralLevelAndPointsTableViewCell", for: indexPath) as! MyReferralLevelAndPointsTableViewCell
            cell.initializeLevelAndEarnedPoints(referralStats: myReferralsViewModel.referralStats,delegate: self)
            return cell
        case 1:
            if let pointsAfterVerification = SharedPreferenceHelper.getShareAndEarnPointsAfterVerification(), let pointsAfterFirstRide = SharedPreferenceHelper.getShareAndEarnPointsAfterFirstRide(){
                let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReferralTableViewCell", for: indexPath) as! ReferralTableViewCell
                let referalPoints = String(pointsAfterVerification + pointsAfterFirstRide)
               let percentageNumber = String(clientConfiguration.percentCommissionForReferredUser)

                cell.updateCellData(referralPoints: referalPoints, percentageNumber: percentageNumber, delegate: self)
                
                return cell
            }else{
                return UITableViewCell()
            }
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReferMyContactsTableViewCell", for: indexPath) as! ReferMyContactsTableViewCell
            cell.initializeCell(delegate: self)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopThereeReferralsTableViewCell", for: indexPath) as! TopThereeReferralsTableViewCell
            cell.initializeTopThreeReferrals(referralLeaderList: myReferralsViewModel.referralLeaderList, delegate: self)
            return cell
        case 4:let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityOrOrganisationReferalTableViewCell", for: indexPath) as! CommunityOrOrganisationReferalTableViewCell
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        cell.updateUI(referralImage: UIImage(named: "orgnisation_reward"), rewardType: RewardsTermsAndConditions.REFER_ORGANIZATION, offerDetails: String(format: Strings.get_free_points, arguments: [String(clientConfiguration.maximumOrganizationReferralPoints)]),delegate: self)
        return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityOrOrganisationReferalTableViewCell", for: indexPath) as! CommunityOrOrganisationReferalTableViewCell
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            cell.updateUI(referralImage: UIImage(named: "apartments"), rewardType: RewardsTermsAndConditions.REFER_COMMUNITY, offerDetails: String(format: Strings.win_points, arguments: [String(clientConfiguration.maximumCommunityReferralPoints)]),delegate: self)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReferralFAQTableViewCell", for: indexPath) as! ReferralFAQTableViewCell
            cell.initializeFAQTable()
            return cell
        default: break
        }
        return UITableViewCell()
    }
    
}

//MARK: MyReferralLevelAndPoints
extension MyReferralsViewController: MyReferralLevelAndPoints{
    func levelInfoClicked() {
        guard let referralStats = myReferralsViewModel.referralStats else { return }
        let levelsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.levelsViewController) as! LevelsViewController
        levelsViewController.initializeLevels(referralStats: referralStats)
        self.navigationController?.pushViewController(levelsViewController, animated: true)
    }
    
    func referredPeopleClicked() {
        guard let referralStats = myReferralsViewModel.referralStats else { return }
        let myReferralsReportViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsReportViewController) as! MyReferralsReportViewController
        myReferralsReportViewController.initializeReferralReport(referralStats: referralStats)
        self.navigationController?.pushViewController(myReferralsReportViewController, animated: true)
    }
}

//MARK: ReferralTableViewCellDelegate
extension MyReferralsViewController: ReferralTableViewCellDelegate{
    func referNowButtonpressed() {
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
    
    func howItWorksPressed() {
        if myReferralsViewModel.shareAndEarnOffers.isEmpty{
            return
        }
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HowItWorkPopUpForShareAndEarnViewController") as! HowItWorkPopUpForShareAndEarnViewController
        showTermsAndConditionsViewController.initializeView(shareAndEarnOffer: myReferralsViewModel.shareAndEarnOffers[0])
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
    
    func shareButtonPressed() {
        InstallReferrer.prepareURLForDeepLink(referralCode: UserDataCache.getInstance()?.getReferralCode() ?? "") { (urlString)  in
            if let url = urlString{
                self.myReferralsViewModel.shareReferralContext(urlString: url,viewController: self)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
}

//MARK: ReferMyContactsTableViewCellDelegate
extension MyReferralsViewController: ReferMyContactsTableViewCellDelegate{
    func referContactsClicked() {
        let referMyContactsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.referMyContactsViewController) as! ReferMyContactsViewController
        self.navigationController?.pushViewController(referMyContactsViewController, animated: true)
    }
}

//MARK: TopThereeReferralsTableViewCellDelegate
extension MyReferralsViewController: TopThereeReferralsTableViewCellDelegate{
    func checkLeaderBoardClicked() {
        let topReferrersViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.topReferrersViewController) as! TopReferrersViewController
        topReferrersViewController.initializeLeadersList(referralLeaderList: myReferralsViewModel.referralLeaderList)
        self.navigationController?.pushViewController(topReferrersViewController, animated: true)
    }
}

//MARK: CommunityOrOrganisationReferalTableViewCellDelegate
extension MyReferralsViewController: CommunityOrOrganisationReferalTableViewCellDelegate{
    func rewardsInfoClicked(rewardType: String?) {
        var shareAndEarnOffer: ShareAndEarnOffer?
        if rewardType == RewardsTermsAndConditions.REFER_ORGANIZATION {
            let index = myReferralsViewModel.shareAndEarnOffers.count - 2
            if index >= 0{
                shareAndEarnOffer = myReferralsViewModel.shareAndEarnOffers[index]
            }
        }else if rewardType == RewardsTermsAndConditions.REFER_COMMUNITY{
            let index = myReferralsViewModel.shareAndEarnOffers.count - 1
            if index >= 0{
                shareAndEarnOffer = myReferralsViewModel.shareAndEarnOffers[index]
            }
        }
        
        guard let shareAndEarn = shareAndEarnOffer else { return }
        let rewardsDetailViewController  = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RewardsDetailViewController") as! RewardsDetailViewController
        rewardsDetailViewController.initializeView(shareAndEarnOffer: shareAndEarn)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rewardsDetailViewController, animated: false)
    }
}
