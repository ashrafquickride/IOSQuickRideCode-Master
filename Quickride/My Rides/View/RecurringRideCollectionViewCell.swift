//
//  RecurringRideCollectionViewCell.swift
//  Quickride
//
//  Created by Bandish Kumar on 30/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RecurringRideCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak fileprivate var rideDetailView: UIView!
    @IBOutlet weak fileprivate var rideTimingLabel: UILabel!
    @IBOutlet weak var fromToAddressView: UIView!
    @IBOutlet weak fileprivate var fromAddressLabel: UILabel!
    @IBOutlet weak fileprivate var toAddressLabel: UILabel!
    @IBOutlet weak fileprivate var statusLabel: UILabel!
    @IBOutlet weak fileprivate var statusView: UIView!
    @IBOutlet weak fileprivate var rideDescriptionLabel: UILabel!
    @IBOutlet weak fileprivate var addNewRecurringRideView: UIView!
    @IBOutlet weak fileprivate var addRecurringRideLabel: UILabel!
    @IBOutlet weak fileprivate var addRecurringRideImageView: UIImageView!
    //homeOfficeAddressView - UI for home & Office address
    @IBOutlet weak var homeOfficeAddressView: UIView!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var officeAddressLabel: UILabel!
    
    lazy var myRideRecurringViewModel: MyRideRecurringViewModel = {
        return MyRideRecurringViewModel()
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
      //MARK: Methods
    private func setupUI() {
        ViewCustomizationUtils.addCornerRadiusToView(view:  statusView, cornerRadius: statusView.frame.height / 2)
        ViewCustomizationUtils.addBorderToView(view: statusView, borderWidth: 1.0, color: .white)
        ViewCustomizationUtils.addBorderToView(view: rideDetailView, borderWidth: 1, colorCode: 0xE5F1F5)
    }
  
    func configureViewWith(_ regularRide: RegularRide) {
        
        rideDetailView.isHidden = false
        addNewRecurringRideView.isHidden = true
        let rideTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: regularRide.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        rideTimingLabel.text = rideTime
        
        if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
            setHomeOfficeAddressView(regularRide: regularRide)
        } else {
            setFromToAddressView(regularRide: regularRide)
        }
        rideDescriptionLabel.text = myRideRecurringViewModel.setRecurringDay(for: regularRide).joined(separator: ", ")
        setRecurringStatus(for: regularRide)
    }
    
    func setHomeOfficeAddressView(regularRide: RegularRide) {
        homeOfficeAddressView.isHidden = false
        fromToAddressView.isHidden = true
        if let cacheInstance = UserDataCache.getInstance() {
            if let homeLocation = cacheInstance.getHomeLocation(), let  officeLocation = cacheInstance.getOfficeLocation() {
                if regularRide.startAddress == homeLocation.address, regularRide.endAddress == officeLocation.address {
                    homeAddressLabel.text = Strings.home
                    officeAddressLabel.text = Strings.office
                    return
                }
                if regularRide.startAddress == officeLocation.address, regularRide.endAddress == homeLocation.address {
                    homeAddressLabel.text = Strings.office
                    officeAddressLabel.text = Strings.home
                    return
                }
                setFromToAddressView(regularRide: regularRide)
             
            } else {
                 setFromToAddressView(regularRide: regularRide)
            }
        }
    }
    
    func setFromToAddressView(regularRide: RegularRide) {
            homeOfficeAddressView.isHidden = true
            fromToAddressView.isHidden = false
            fromAddressLabel.text = regularRide.startAddress
            toAddressLabel.text = regularRide.endAddress
    }
    
    func configureAddRecurringRideCell() {
        rideDetailView.isHidden = true
        addNewRecurringRideView.isHidden = false
        addRecurringRideLabel.isHidden = false
        addRecurringRideImageView.isHidden = false
    }
    
    private func setRecurringStatus(for regularRide: RegularRide) {
        switch regularRide.status {
        case Ride.RIDE_STATUS_SCHEDULED: fallthrough
        case Ride.RIDE_STATUS_STARTED: fallthrough
        case Ride.RIDE_STATUS_REQUESTED:
            statusView.backgroundColor = UIColor(netHex: 0x00B557)
            statusLabel.text = "ON"
            statusLabel.textColor = UIColor(netHex: 0x00B557)
        default:
            statusView.backgroundColor = .red
            statusLabel.text = "OFF"
            statusLabel.textColor = .red
        }
    }
    
    func getShortAddressForStartLocation(ride: Ride) {
        self.fromAddressLabel.text = ride.startAddress
    }
    
    func getShortAddressForEndLocation(ride: Ride) {
        self.toAddressLabel.text = ride.endAddress
    }
}
