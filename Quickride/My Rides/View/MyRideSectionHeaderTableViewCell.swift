//
//  MyRideSectionHeaderTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 02/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol MyRideSectionHeaderTableViewCellDelegate: class {
    func loadCreateRideView()
}

class MyRideSectionHeaderTableViewCell: UITableViewCell {
    //MARK: Outlet
    @IBOutlet weak fileprivate var upcomingRideHeaderLabel: UILabel!
    
    weak var delegate: MyRideSectionHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    //MARK: Method
    func configureUI(totalNumberOfActiveRides: Int, todayActiveRides: Int) {
        
        (totalNumberOfActiveRides > 1) ? (upcomingRideHeaderLabel.text = Strings.upcoming_rides) : (upcomingRideHeaderLabel.text = Strings.upcoming_ride)
    }
    //MARK: Action
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        delegate?.loadCreateRideView()
    }
    
}
