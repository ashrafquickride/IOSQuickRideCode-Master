//
//  MatchedUserCollectionViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 14/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class MatchedUserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var matchingOptionTitleLabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var firstImageWidthConstraint:  NSLayoutConstraint!
    @IBOutlet weak var filterCountLabel: UILabel!
    @IBOutlet weak var filterCountView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        ViewCustomizationUtils.addCornerRadiusWithBorderToView(view: outerView, cornerRadius: 5, borderWidth: 1.0, color: UIColor(netHex: 0xebebeb))
    }
    
    func initializeFilterOptionsCell(index: Int, status: [String : String],rideType: String?) {
        let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().copy() as? SecurityPreferences
        switch index {
        case 0:
            matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
            matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            outerView.backgroundColor = .clear
            secondImageView.isHidden = true
            let count = DynamicFiltersCache.getInstance().getApplyedFiltersToCurrentRide(filterStatus: status)
            if count > 0{
                filterCountLabel.text = String(count)
                filterCountView.isHidden = false
                firstImageView.isHidden = true
                firstImageWidthConstraint.constant = 15
            }else{
                let image = UIImage(named: "noun_filter_245880")
                firstImageView.image = image?.withRenderingMode(.alwaysTemplate)
                firstImageView.tintColor = UIColor.black.withAlphaComponent(0.4)
                firstImageView.isHidden = false
                firstImageWidthConstraint.constant = 12
                filterCountView.isHidden = true
            }
        case 1:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            secondImageView.isHidden = false
            secondImageView.image = UIImage(named: "down arrow")
            matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            outerView.backgroundColor = .clear
            if let routeMatchPer = status[DynamicFiltersCache.ROUTE_MATCH_CRITERIA]{
                matchingOptionTitleLabel.text = String(format: Strings.sortAndFilterList[index],arguments: [routeMatchPer]) + Strings.percentage_symbol
            }else{
                guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()else { return }
                if rideType == Ride.RIDER_RIDE{
                    matchingOptionTitleLabel.text = String(format: Strings.sortAndFilterList[index],arguments: [String(ridePreferences.rideMatchPercentageAsRider)]) + Strings.percentage_symbol
                }else{
                    matchingOptionTitleLabel.text = String(format: Strings.sortAndFilterList[index],arguments: [String(ridePreferences.rideMatchPercentageAsPassenger)]) + Strings.percentage_symbol
                }
            }
        case 2:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
            if let value = status[DynamicFiltersCache.USERS_CRITERIA], value == DynamicFiltersCache.PREFERRED_USERS_VERIFIED{
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "cancel_white_icon")
                outerView.backgroundColor = UIColor(netHex: 0x00b557)
                matchingOptionTitleLabel.textColor = .white
            }else if let shareRidesWithUnVeririfiedUsers = securityPreferences?.shareRidesWithUnVeririfiedUsers,!shareRidesWithUnVeririfiedUsers{
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "cancel_white_icon")
                outerView.backgroundColor = UIColor(netHex: 0x00b557)
                matchingOptionTitleLabel.textColor = .white
            }else{
                outerView.backgroundColor = .clear
                secondImageView.isHidden = true
                matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            }
        case 3:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
            if let value = status[DynamicFiltersCache.EXISTANCE_CRITERIA], value == DynamicFiltersCache.ACTIVE_USERS{
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "cancel_white_icon")
                outerView.backgroundColor = UIColor(netHex: 0x00b557)
                matchingOptionTitleLabel.textColor = .white
            }else{
                outerView.backgroundColor = .clear
                secondImageView.isHidden = true
                matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            }
        case 4:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
            if let value = status[DynamicFiltersCache.PARTNERS_CRITERIA], value == DynamicFiltersCache.FAVOURITE_PARTNERS{
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "cancel_white_icon")
                outerView.backgroundColor = UIColor(netHex: 0x00b557)
                matchingOptionTitleLabel.textColor = .white
            }else{
                outerView.backgroundColor = .clear
                secondImageView.isHidden = true
                matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            }
        case 5:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            if rideType == Ride.RIDER_RIDE{
                var time = "0"
                if let value = status[DynamicFiltersCache.TIME_RANGE_CRITERIA]{
                    time = value
                }else{
                    guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()else { return }
                    time = String(ridePreferences.rideMatchTimeThreshold)
                }
                if time == "1.5" || time == "2"{
                    matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["+",time,"hr"])
                }else if time == "1"{
                    matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["±",time,"hr"])
                }else{
                    matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["±",time,"Min"])
                }
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "down arrow")
                matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
                outerView.backgroundColor = .clear
            }else{
                matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
                if let value = status[DynamicFiltersCache.ROUTE_POINT_CRITERIA], value == DynamicFiltersCache.VIA_START_POINT{
                    secondImageView.isHidden = false
                    secondImageView.image = UIImage(named: "cancel_white_icon")
                    outerView.backgroundColor = UIColor(netHex: 0x00b557)
                    matchingOptionTitleLabel.textColor = .white
                }else{
                    outerView.backgroundColor = .clear
                    secondImageView.isHidden = true
                    matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
                }
            }
        case 6:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            matchingOptionTitleLabel.text = Strings.sortAndFilterList[index]
            if let value = status[DynamicFiltersCache.VEHICLE_CRITERIA], value == DynamicFiltersCache.PREFERRED_VEHICLE_CAR{
                secondImageView.isHidden = false
                secondImageView.image = UIImage(named: "cancel_white_icon")
                outerView.backgroundColor = UIColor(netHex: 0x00b557)
                matchingOptionTitleLabel.textColor = .white
            }else{
                outerView.backgroundColor = .clear
                secondImageView.isHidden = true
                matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            }
        case 7:
            filterCountView.isHidden = true
            firstImageView.isHidden = true
            firstImageWidthConstraint.constant = 0
            var time = "0"
            if let value = status[DynamicFiltersCache.TIME_RANGE_CRITERIA]{
                time = value
            }else{
                guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()else { return }
                time = String(ridePreferences.rideMatchTimeThreshold)
            }
            if time == "1.5" || time == "2"{
                matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["+",time,"hr"])
            }else if time == "1"{
                matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["±",time,"hr"])
            }else{
                matchingOptionTitleLabel.text = String(format: Strings.time,arguments: ["±",time,"Min"])
            }
            secondImageView.isHidden = false
            secondImageView.image = UIImage(named: "down arrow")
            matchingOptionTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            outerView.backgroundColor = .clear
        default:
            break
        }
    }

}
