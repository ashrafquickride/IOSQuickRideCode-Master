//
//  TableViewFooterTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 19/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TableViewFooterTableViewCell: UITableViewCell {

    @IBOutlet weak var footerNameLabel: UILabel!
    
    private var section = 0
    func initialiseView(section: Int,footerText: String){
        self.section = section
        footerNameLabel.text = footerText
    }
    
    @IBAction func editiDetailsTapped(_ sender: UIButton) {
        var userInfo = [String: Int]()
        userInfo["section"] = section
        NotificationCenter.default.post(name: .footerTapped, object: nil, userInfo: userInfo)
    }
}
