//
//  RentalStopLocationTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 25/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias handlerTappedOnPackageInfo = (_ completed : Bool) -> Void

class RentalStopLocationPointTableViewCell: UITableViewCell {

    @IBOutlet weak var tripDetailsView: UIView!
    @IBOutlet weak var tripDetailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var stopPointLabel: UILabel!
    @IBOutlet weak var rentalTripIdLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    
    var handlerTappedOnPackageInfo: handlerTappedOnPackageInfo?
    
    func setupUI(stopPoint: String?, isFirstIndex: Bool, handlerTappedOnPackageInfo: @escaping  handlerTappedOnPackageInfo){
        self.handlerTappedOnPackageInfo = handlerTappedOnPackageInfo
        if isFirstIndex {
            tripDetailsView.isHidden = false
            tripDetailsViewHeight.constant = 80
        }else{
            tripDetailsView.isHidden = true
            tripDetailsViewHeight.constant = 0
        }
        if let stopPoint = stopPoint {
            stopPointLabel.text = stopPoint
            stopPointLabel.textColor = UIColor.black
        } else{
            stopPointLabel.text = "Enter Destination"
            stopPointLabel.textColor = UIColor.systemBlue
        }
        rentalTripIdLabel.isUserInteractionEnabled = true
        rentalTripIdLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TappedOnPackageInfo(_:))))
    }
    @objc func TappedOnPackageInfo(_ gesture : UITapGestureRecognizer){
        if let handlerTappedOnPackageInfo = handlerTappedOnPackageInfo {
            handlerTappedOnPackageInfo(true)
        }
    }
}
