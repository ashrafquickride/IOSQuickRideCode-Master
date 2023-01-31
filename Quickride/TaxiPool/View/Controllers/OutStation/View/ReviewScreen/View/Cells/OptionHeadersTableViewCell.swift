//
//  OptionHeadersTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 10/19/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol OptionHeadersTableViewCellDelegate {
    func selectedTab(selectedIndex: Int)
}

typealias actionComplition = (_ showInfo : Bool) -> Void

class OptionHeadersTableViewCell: UITableViewCell {
    @IBOutlet weak var inclusionLabel: UILabel!
    @IBOutlet weak var exclusionLabel: UILabel!
    @IBOutlet weak var FacilitiesLabel: UILabel!
    @IBOutlet weak var tnCLabel: UILabel!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var inclusionMarkerView: UIView!
    @IBOutlet weak var exclusionMarkerView: UIView!
    @IBOutlet weak var facilitiesMarkerView: UIView!
    @IBOutlet weak var tnCMarkerView: UIView!
    @IBOutlet weak var dropDownArrowImageView: UIImageView!
    @IBOutlet weak var seperaterView: UIView!
    
    private var tabData = [Strings.inclusions,Strings.exclusions,Strings.facilities,Strings.T_and_C]
    private var selectedTabIndex = 0
    var delegate: OptionHeadersTableViewCellDelegate?
    private var actionComplition: actionComplition?
    var isRequiredToShowInfo: Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    func updatDataAsPerUI(selectedIndex: Int, screenWidth: Double, isRequiredToShowInfo: Bool?, isFromLiveRide: Bool, actionComplition: @escaping actionComplition) {
        self.selectedTabIndex = selectedIndex
        self.isRequiredToShowInfo = isRequiredToShowInfo
        self.actionComplition = actionComplition
        setSelectedOption(index: selectedIndex)
        if isFromLiveRide {
            dropDownArrowImageView.isHidden = false
            dropDownButton.isUserInteractionEnabled = true
        }
        seperaterView.isHidden = false
        if isRequiredToShowInfo ?? true {
            dropDownArrowImageView.image = UIImage(named: "arrow_up_grey")
        } else {
            dropDownArrowImageView.image = UIImage(named: "down arrow")
            inclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            exclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            facilitiesMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            tnCMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            inclusionLabel.textColor = UIColor(netHex: 0x808080)
            exclusionLabel.textColor = UIColor(netHex: 0x808080)
            FacilitiesLabel.textColor = UIColor(netHex: 0x808080)
            tnCLabel.textColor = UIColor(netHex: 0x808080)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func optionBarTapped(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        if let actionComplition = actionComplition {
            actionComplition(true)
        }
        delegate?.selectedTab(selectedIndex: sender.tag)
    }
    
    func setSelectedOption(index: Int){
        switch index {
        case 0:
            inclusionMarkerView.backgroundColor = UIColor(netHex: 0x707070)
            exclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            facilitiesMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            tnCMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            inclusionLabel.textColor = UIColor(netHex: 0x000000)
            exclusionLabel.textColor = UIColor(netHex: 0x808080)
            FacilitiesLabel.textColor = UIColor(netHex: 0x808080)
            tnCLabel.textColor = UIColor(netHex: 0x808080)
        case 1:
            inclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            exclusionMarkerView.backgroundColor = UIColor(netHex: 0x707070)
            facilitiesMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            tnCMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            inclusionLabel.textColor = UIColor(netHex: 0x808080)
            exclusionLabel.textColor = UIColor(netHex: 0x000000)
            FacilitiesLabel.textColor = UIColor(netHex: 0x808080)
            tnCLabel.textColor = UIColor(netHex: 0x808080)
        case 2:
            inclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            exclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            facilitiesMarkerView.backgroundColor = UIColor(netHex: 0x707070)
            tnCMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            inclusionLabel.textColor = UIColor(netHex: 0x808080)
            exclusionLabel.textColor = UIColor(netHex: 0x808080)
            FacilitiesLabel.textColor = UIColor(netHex: 0x000000)
            tnCLabel.textColor = UIColor(netHex: 0x808080)
        case 3:
            inclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            exclusionMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            facilitiesMarkerView.backgroundColor = UIColor(netHex: 0xFFFFFF)
            tnCMarkerView.backgroundColor = UIColor(netHex: 0x707070)
            inclusionLabel.textColor = UIColor(netHex: 0x808080)
            exclusionLabel.textColor = UIColor(netHex: 0x808080)
            FacilitiesLabel.textColor = UIColor(netHex: 0x808080)
            tnCLabel.textColor = UIColor(netHex: 0x000000)
        default:
            break
        }
    }
    
    @IBAction func dropDownButtonTapped(_ sender: Any) {
        if let isRequiredToShowInfo = isRequiredToShowInfo, let actionComplition = actionComplition {
            if isRequiredToShowInfo {
                actionComplition(false)
            } else {
                actionComplition(true)
            }
        }
    }
}

extension OptionHeadersTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rideTypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RideTypeCollectionViewCell", for: indexPath) as! RideTypeCollectionViewCell
        rideTypeCell.rideTypeLabel.text = tabData[indexPath.row]
        if indexPath.row == selectedTabIndex {
            rideTypeCell.rideTypeView.backgroundColor = UIColor(netHex: 0x383838)
            rideTypeCell.rideTypeLabel.textColor = .white
        }else{
            rideTypeCell.rideTypeView.backgroundColor = UIColor(netHex: 0xEAEAEA)
            rideTypeCell.rideTypeLabel.textColor = UIColor(netHex: 0x464646)
        }
        return rideTypeCell
    }
}

