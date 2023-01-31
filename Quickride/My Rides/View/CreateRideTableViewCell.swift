//
//  CreateRideTableViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 20/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol CreateRideTableViewCellDelegate: class {
    func createRideButtonTapped()
}

class CreateRideTableViewCell: UITableViewCell {
    //MARK: Property
    weak var delegate: CreateRideTableViewCellDelegate?
   
    @IBOutlet weak var titleText: UILabel!
    
    @IBOutlet weak var createRideButton: UIButton!
    
    @IBOutlet weak var seperatorView: UIView!
    
    func setUpUI(data: Bool?) {
        if data ?? false {
            titleText.text = "No carpool found, try Taxipool"
            createRideButton.isHidden = true
        }else {
          titleText.text = "Oh! You have no upcoming rides. Go ahead & create one. Happy Carpooling!"
            createRideButton.isHidden = false
        }
        
    }
    //MARK: Action
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        delegate?.createRideButtonTapped()
    }
}
