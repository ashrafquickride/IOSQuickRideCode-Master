//
//  TopReferrersViewController.swift
//  Quickride
//
//  Created by Halesh on 28/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TopReferrersViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var referredUserInfoTableView: UITableView!
    @IBOutlet weak var backButton: CustomUIButton!
    
    var referralLeaderList = [ReferralLeader]()
    func initializeLeadersList(referralLeaderList: [ReferralLeader]){
        self.referralLeaderList = referralLeaderList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.changeBackgroundColorBasedOnSelection()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK: UITableViewDataSource
extension TopReferrersViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return referralLeaderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopReferrerTableViewCell", for: indexPath) as! TopReferrerTableViewCell
        if referralLeaderList.endIndex <= indexPath.row{
            return cell
        }
        cell.initializeLeaderCell(referralLeader: referralLeaderList[indexPath.row])
        return cell
    }
}
