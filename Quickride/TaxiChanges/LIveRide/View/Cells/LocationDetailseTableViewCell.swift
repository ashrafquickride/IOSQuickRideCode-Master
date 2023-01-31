//
//  LocationDetailseTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 03/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

enum LocationType {
    case pickup
    case drop
    case viapoint
}


class LocationDetailseTableViewCell: UITableViewCell {

    @IBOutlet weak var dotView: UIView!
    
    @IBOutlet weak var changeLocationButton: UIButton!
    
    @IBOutlet weak var editLocationImageView: UIImageView!
    
    @IBOutlet weak var editLocationButton: UIButton!
    
    var locationType: LocationType?
    var location: String?
    var handler: actionComplitionHandler?
    
    func initialiseData(locationType: LocationType, location: String, handler: actionComplitionHandler?){
        self.location = location
        self.locationType = locationType
        self.handler = handler
        setupUI()
    }
    
    private func setupUI(){
        changeLocationButton.setTitle(location, for: .normal)
        switch locationType {
        case .pickup:
            dotView.backgroundColor = UIColor(netHex: 0x99D8A8)
            editLocationImageView.image = UIImage(named: "icon_edit")
            changeLocationButton.setTitleColor(.black, for: .normal)
            changeLocationButton.isUserInteractionEnabled = false
        case .drop:
            dotView.backgroundColor = UIColor(netHex: 0xD89999)
            editLocationImageView.image = UIImage(named: "icon_edit")
            changeLocationButton.setTitleColor(.black, for: .normal)
            changeLocationButton.isUserInteractionEnabled = false
        case .viapoint:
            dotView.backgroundColor = .black
            editLocationImageView.image = UIImage(named: "cross_icon")
            changeLocationButton.setTitleColor(.systemBlue, for: .normal)
            changeLocationButton.isUserInteractionEnabled = true
        default :
            break
        }
    }
    
    @IBAction func editLocationButtonTapped(_ sender: Any) {
        if let handler = handler {
            handler(true)
        }
    }
    
    @IBAction func changeLocationButtonTapped(_ sender: Any) {
        if let handler = handler {
            handler(false)
        }
    }
    
}
