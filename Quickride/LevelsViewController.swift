//
//  LevelsViewController.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class LevelsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var referredPeopleCountLabel: UILabel!
    @IBOutlet weak var levelsTableView: UITableView!
    
    //MARK:Variable
    private var levelsViewModel = LevelsViewModel()
    
    func initializeLevels(referralStats: ReferralStats){
        levelsViewModel.referralStats = referralStats
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        levelsViewModel.prepareLevels()
        nameLabel.text = UserDataCache.getInstance()?.getUserName()
        referredPeopleCountLabel.text = String(format: Strings.referred_people, arguments: [String(levelsViewModel.referralStats?.totalReferralCount ?? 0)])
        levelsTableView.estimatedRowHeight = 448
        levelsTableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termAndConditionTapped(_ sender: Any) {
      let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTermsAndConditionsViewController") as! ShowTermsAndConditionsViewController
        showTermsAndConditionsViewController.initializeDataBeforePresenting(termsAndConditions: levelsViewModel.referralStats?.termsAndConditions ?? [String](), titleString: Strings.terms_and_conditions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
}

//MARK: UITableViewDataSource
extension LevelsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelsViewModel.referralLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelTableViewCell", for: indexPath) as! LevelTableViewCell
        cell.initializeLevelCellData(referralLevel: levelsViewModel.referralLevels[indexPath.row],index: indexPath.row + 1)
        return cell
    }
    
}
