//
//  ReferralFAQTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferralFAQTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var referralFAQTableView: UITableView!
    
    //MARK: Variables
    private var faqsList = Strings.referralFAQList
    func initializeFAQTable(){
        referralFAQTableView.delegate = self
        referralFAQTableView.dataSource = self
    }
}

//MARK: UITableViewDataSource
extension ReferralFAQTableViewCell: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferralFAQDetailsTableViewCell", for: indexPath) as! ReferralFAQDetailsTableViewCell
        cell.initializeFAQ(faq: faqsList[indexPath.row],index: indexPath.row)
        return cell
    }
}

//MARK: UITableViewDelegate
extension ReferralFAQTableViewCell: UITableViewDelegate{
    
}
