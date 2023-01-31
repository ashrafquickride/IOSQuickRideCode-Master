//
//  RentalPackageSelectionTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 22/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalPackageSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var rentalPackageCollectionView: UICollectionView!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerlabel: UILabel!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var packageInfoView: UIView!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var pickUpImage: UIImageView!
    @IBOutlet weak var fromdateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rentalPackageCollectionViewHeight: NSLayoutConstraint!

    private var pickup: Location?
    var rentalPackageEstimates: [RentalPackageEstimate]?
    private var userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?
    private var rentalPackageSelectionDelegate: RentalPackageSelectionDelegate?
    var selectedIndex = -1
    private var timer: Timer?
    private var fromTime = NSDate().timeIntervalSince1970

    func setupUI(pickup: Location?, rentalPackageEstimates: [RentalPackageEstimate]?, userSelectionDelegate: RideLocationSelectionTableViewCellDelegate?, rentalPackageSelectionDelegate: RentalPackageSelectionDelegate, selectedIndex: Int?, isFromHomePage: Bool, startTime: Double?) {
        self.pickup = pickup
        self.fromTime = startTime ?? NSDate().getTimeStamp()
        self.userSelectionDelegate = userSelectionDelegate
        self.rentalPackageEstimates = rentalPackageEstimates
        self.rentalPackageSelectionDelegate = rentalPackageSelectionDelegate
        rentalPackageCollectionView.register(UINib(nibName: "RentalPackageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RentalPackageCollectionViewCell")
        self.selectedIndex = selectedIndex ?? -1
        setStartLocation()
        setupOfferView()
        setupRentalPackageCollectionView(isFromHomePage: isFromHomePage)
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fromDate(_:))))
        packageInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(packageInfoTpped(_:))))
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateToCurrentTime), userInfo: nil, repeats: true)
        let indexPath = IndexPath(item: selectedIndex ?? 0, section: 0)
        rentalPackageCollectionView.dataSource = self
        rentalPackageCollectionView.delegate = self
        rentalPackageCollectionView.reloadData()
        if let numberofPackages = rentalPackageEstimates?.count, numberofPackages > indexPath.row {
            rentalPackageCollectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
        showTime()
    }

    func setupOfferView() {
        if let coupon = SharedPreferenceHelper.getTaxiOfferCoupon() {
            offerView.isHidden = false
            offerlabel.text = String(format: Strings.use_taxi_offer, arguments: [StringUtils.getStringFromDouble(decimalNumber: coupon.maxDiscount), coupon.couponCode])
            offerImage.image = offerImage.image?.withRenderingMode(.alwaysTemplate)
            offerImage.tintColor = UIColor(netHex: 0x000000)
        } else {
            offerView.isHidden = true
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: offerView, cornerRadius: 10)
    }

    func setupRentalPackageCollectionView(isFromHomePage: Bool) {
        guard let rentalPackageEstimates = rentalPackageEstimates, !rentalPackageEstimates.isEmpty else {
            fromDateView.isHidden = true
            packageInfoView.isHidden = true
            fromdateHeightConstraint.constant = 0
            offerView.isHidden = true
            offerViewHeightConstraint.constant = 0
            rentalPackageCollectionViewHeight.constant = 0
            return
        }
        if isFromHomePage {
            rentalPackageCollectionViewHeight.constant = 145
            if let coupon = SharedPreferenceHelper.getTaxiOfferCoupon() {
                offerView.isHidden = false
                offerViewHeightConstraint.constant = 50
                offerlabel.text = String(format: Strings.use_taxi_offer, arguments: [StringUtils.getStringFromDouble(decimalNumber: coupon.maxDiscount), coupon.couponCode])
                offerImage.image = offerImage.image?.withRenderingMode(.alwaysTemplate)
                offerImage.tintColor = UIColor(netHex: 0x000000)
                fromDateView.isHidden = true
                fromdateHeightConstraint.constant = 0
                packageInfoView.isHidden = true
            } else {
                offerView.isHidden = true
                offerViewHeightConstraint.constant = 0
                fromDateView.isHidden = true
                fromdateHeightConstraint.constant = 0
                packageInfoView.isHidden = true
            }
        } else {
            fromDateView.isHidden = false
            fromdateHeightConstraint.constant = 45
            offerView.isHidden = true
            offerViewHeightConstraint.constant = 0
        }
    }

    @objc private func fromDate(_ gesture: UITapGestureRecognizer) {
        rentalPackageSelectionDelegate?.pickUpDateTapped()
    }

    @objc private func packageInfoTpped(_ gesture: UITapGestureRecognizer) {
        rentalPackageSelectionDelegate?.showPackageInfo()
    }

    @objc private func updateToCurrentTime() {
        if fromTime < NSDate().timeIntervalSince1970 {
            fromTime = NSDate().timeIntervalSince1970
            fromDateLabel.text = "Now"
        }
    }

    private func setStartLocation() {
        if let address = pickup?.completeAddress, !address.isEmpty {
            startLocationButton.setTitle(address, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        } else {
            startLocationButton.setTitle(Strings.enter_start_location, for: .normal)
            startLocationButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        }
    }

    private func showTime() {
        if ((DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!).compare(DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)!)) == ComparisonResult.orderedSame {
            if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: fromTime, time2: NSDate().getTimeStamp()) < 1 {
                fromDateLabel.text = "Now"
            } else {
                fromDateLabel.text = "Today at " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }
        } else {
            fromDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromTime, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
        }
    }

    @IBAction func pickupLocationButtonTapped(_ sender: Any) {
        rentalPackageSelectionDelegate?.pickupLocationChanged()
    }

}

extension RentalPackageSelectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rentalPackageEstimates?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RentalPackageCollectionViewCell", for: indexPath) as! RentalPackageCollectionViewCell
        cell.setupUI(packageDistance: rentalPackageEstimates?[indexPath.row].packageDistance ?? 0, packageDuration: rentalPackageEstimates?[indexPath.row].packageDuration ?? 0)
        if selectedIndex == indexPath.row {
            cell.packageBackGroundView.backgroundColor = UIColor(netHex: 0x009F4C)
            cell.packageDistanceLabel.textColor = UIColor.white
            cell.packageDurationLabel.textColor = UIColor.white
        } else {
            cell.packageBackGroundView.backgroundColor = UIColor.white
            cell.packageDistanceLabel.textColor = UIColor.black
            cell.packageDurationLabel.textColor = UIColor.black
        }
        return cell
    }
}

extension RentalPackageSelectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let packageDistance = rentalPackageEstimates?[indexPath.row].packageDistance, let packageDuration = rentalPackageEstimates?[indexPath.row].packageDuration else {
            return
        }
        rentalPackageSelectionDelegate?.selectedRentalPackage(packageDistance: packageDistance, packageDuration: packageDuration)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension RentalPackageSelectionTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 90)
    }
}
