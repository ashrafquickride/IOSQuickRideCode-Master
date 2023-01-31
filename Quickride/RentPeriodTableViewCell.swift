//
//  RentPeriodTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentPeriodTableViewCell: UITableViewCell {

    @IBOutlet weak var rentalDaysLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var isRequireToHideEditButton = false
    private var fromDate = 0.0
    private var toDate = 0.0
    
    func initialiseRentalDays(fromDate: Double,toDate: Double){
        self.fromDate = fromDate
        self.toDate = toDate
        let startDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: fromDate, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        let endDate = DateUtils.getTimeStringFromTimeInMillis(timeStamp: toDate, timeFormat: DateUtils.DATE_FORMAT_D_MM)
        var rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: toDate/1000), date2: NSDate(timeIntervalSince1970: fromDate/1000))
        rentalDaysLabel.text = String(format: Strings.rental_days, arguments: [(startDate ?? ""),(endDate ?? ""),String(rentalDays)])
        if isRequireToHideEditButton{
            editButton.isHidden = true
        }else{
            editButton.isHidden = false
        }
    }
    
    @IBAction func EditButtonTapped(_ sender: Any) {
        var productRequest = RequestProduct()
        productRequest.fromTime = fromDate
        productRequest.toTime = toDate
        productRequest.tradeType = Product.RENT
        let selectDeliveryTypeViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SelectDeliveryTypeViewController") as! SelectDeliveryTypeViewController
        selectDeliveryTypeViewController.initialiseDeliveryAddressType(productRequest: productRequest, handler: {(productRequest) in
            var userInfo = [String: Any]()
            userInfo["productRequest"] = productRequest
            NotificationCenter.default.post(name: .rentalDaysUpdated, object: nil, userInfo: userInfo)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: selectDeliveryTypeViewController)
    }
}
