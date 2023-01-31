//
//  MyReferralsReportViewController.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MyReferralsReportViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var myReferralsCountLabel: UILabel!
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var co2Label: UILabel!
    @IBOutlet weak var referredUserInfoTableView: UITableView!
    @IBOutlet weak var referredUserInfoTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activatedReferralCount: UILabel!
    @IBOutlet weak var shareImage: UIImageView!
    
    //MARK: Variables
    private var myReferralsReportViewModel = MyReferralsReportViewModel()
    
    func initializeReferralReport(referralStats: ReferralStats){
        myReferralsReportViewModel.referralStats = referralStats
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        myReferralsReportViewModel.getReferredUserInfoList(delagate: self, viewController: self)
        setUpUI()
    }
    
    private func setUpUI(){
        myReferralsCountLabel.text = String(myReferralsReportViewModel.referralStats?.totalReferralCount ?? 0)
        co2Label.text =  StringUtils.getStringFromDouble(decimalNumber: myReferralsReportViewModel.referralStats?.co2SavedFromReferral) + " KG"
        earnedPointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: myReferralsReportViewModel.referralStats?.bonusEarned)
        activatedReferralCount.text = String(format: Strings.activated_referral, arguments: [String(myReferralsReportViewModel.referralStats?.activatedReferralCount ?? 0)])
        shareImage.image = shareImage.image?.withRenderingMode(.alwaysTemplate)
        shareImage.tintColor = .white
        backButton.changeBackgroundColorBasedOnSelection()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareAchievementButtonTapped(_ sender: Any) {
        guard let referralStats = myReferralsReportViewModel.referralStats else { return }
        if referralStats.totalReferralCount == 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.no_achievement)
        }else{
            let referralAchievementViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.referralAchievementViewController) as! ReferralAchievementViewController
            referralAchievementViewController.initializeView(referralStats: referralStats)
            self.navigationController?.pushViewController(referralAchievementViewController, animated: true)
        }
    }
}
//MARK:MyReferralsReportViewModelDelegate
extension MyReferralsReportViewController: MyReferralsReportViewModelDelegate{
    func handleSuccessResponse() {
        myReferralsReportViewModel.referredUserInfoListFetched = true
        referredUserInfoTableView.reloadData()
    }
}

//MARK:UITableViewDataSource
extension MyReferralsReportViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myReferralsReportViewModel.referredUserInfoListFetched{
            return myReferralsReportViewModel.referredUserInfoList.count
        }else if myReferralsReportViewModel.referredUserInfoList.isEmpty{
            return 6
        }else{
            return myReferralsReportViewModel.referredUserInfoList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if myReferralsReportViewModel.referredUserInfoList.isEmpty{
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath as IndexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferredUserInfoTableViewCell", for: indexPath) as! ReferredUserInfoTableViewCell
        cell.initializeReferredUserInfo(referredUserInfo: myReferralsReportViewModel.referredUserInfoList[indexPath.row])
        return cell
    }
}
