//
//  TaxiTripStepsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/23/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiTripStepsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var joinedStatusLabel: UILabel!
    @IBOutlet weak var confirmedStatusLabel: UILabel!
    @IBOutlet weak var allocatedStatusLabel: UILabel!
    @IBOutlet weak var reachedStatusLabel: UILabel!
    @IBOutlet weak var startedStatusLabel: UILabel!
    @IBOutlet weak var joinedImageView: CircularImageView!
    @IBOutlet weak var joinedLabel: UILabel!
    @IBOutlet weak var confirmedImageView: UIImageView!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var allocatedImageView: UIImageView!
    @IBOutlet weak var allocatedLabel: UILabel!
    @IBOutlet weak var reachedImageView: UIImageView!
    @IBOutlet weak var reachedLabel: UILabel!
    @IBOutlet weak var startedImageView: UIImageView!
    @IBOutlet weak var startedLabel: UILabel!
    
    private var imageArray = [UIImageView]()
    private var labelArray = [UILabel]()
    private var statusLabelArray = [UILabel]()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        imageArray = [joinedImageView,confirmedImageView,allocatedImageView,reachedImageView,startedImageView]
        labelArray = [joinedLabel,confirmedLabel,allocatedLabel,reachedLabel,startedLabel]
        statusLabelArray = [joinedStatusLabel,confirmedStatusLabel,allocatedStatusLabel,reachedStatusLabel,startedStatusLabel]
    }
    
    func prepareData(viewModel : TaxiPoolLiveRideViewModel) {
        
        if let shareType = viewModel.getTaxiRidePassenger()?.getShareType(), shareType == TaxiPoolConstants.SHARE_TYPE_EXCLUSIVE {
            joinedStatusLabel.text = Strings.booked
        }else {
            joinedStatusLabel.text = Strings.joined
        }
        if viewModel.isTaxiStarted() {
            updateUI(checkPoint: 5)
        }else if viewModel.isTaxiReached() {
            updateUI(checkPoint: 4)
        } else if viewModel.isTaxiAllotted() {
            updateUI(checkPoint: 3)
        } else if viewModel.isTaxiConfirmed() {
            updateUI(checkPoint: 2)
        } else {
            updateUI(checkPoint: 1)
        }
    }

    
    private func updateUI(checkPoint: Int) {
        for (index,imageView) in imageArray.enumerated() {
            if index < checkPoint {
                imageView.image = UIImage(named: "check")
            }else{
                imageView.image = nil
                imageView.layer.borderColor = UIColor(netHex: 0xCFCFCF).cgColor
                imageView.layer.borderWidth = 1
            }
        }
        for (index,label) in labelArray.enumerated() {
            if index < checkPoint {
                label.isHidden = true
            }else{
                label.isHidden = false
            }
        }
        for (index,label) in statusLabelArray.enumerated() {
            if index < checkPoint {
                label.textColor = .black
                label.font = UIFont(name: "Roboto-Medium", size: 12)
            }else{
                label.textColor = UIColor(netHex: 0xE3E3E3)
                label.font = UIFont(name: "Roboto-Regular", size: 12)
            }
        }
    }
}
