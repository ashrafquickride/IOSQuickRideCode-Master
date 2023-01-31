//
//  NoMatchesAfterFilteringTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 19/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NoMatchesAfterFilteringTableViewCell: UITableViewCell {
    
 @IBAction func clearFilterTaped(_ sender: UIButton) {
     NotificationCenter.default.post(name: .clearFilters, object: nil)
 }
}
