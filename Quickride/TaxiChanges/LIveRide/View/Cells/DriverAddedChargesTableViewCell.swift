//
//  DriverAddedChargesTableViewCell.swift
//  Quickride
//
//  Created by HK on 14/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DriverAddedChargesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var disputeButton: UIButton!
    @IBOutlet weak var backView: UIView!
    
    private var viewModel = TaxiPoolLiveRideViewModel()
    private var taxiTripExtraFareDetails: TaxiTripExtraFareDetails?
    
    func driverAddedCharges(viewModel: TaxiPoolLiveRideViewModel,taxiTripExtraFareDetails: TaxiTripExtraFareDetails?) {
        self.viewModel = viewModel
        self.taxiTripExtraFareDetails = taxiTripExtraFareDetails
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(taxiTripExtraFareDetails?.creationDateMs ?? 0), timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        titleLabel.text = getTitleString(fareType: taxiTripExtraFareDetails?.fareType ?? "") + " - " + (date ?? "")
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiTripExtraFareDetails?.amount)])
        locationLabel.text = taxiTripExtraFareDetails?.location
        if taxiTripExtraFareDetails?.status == TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
            disputeButton.setTitleColor(UIColor(netHex: 0xE20000), for: .normal)
            disputeButton.setTitle("Disputed", for: .normal)
            disputeButton.isUserInteractionEnabled = false
        }else{
            disputeButton.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            disputeButton.isUserInteractionEnabled = true
            disputeButton.setTitle(Strings.Dispute, for: .normal)
        }
    }
    
    private func getTitleString(fareType: String) -> String{
        switch fareType {
        case TaxiTripExtraFareDetails.FARE_TYPE_INTER_STATE_TAX:
            return "Inter State Tax"
        case TaxiTripExtraFareDetails.FARE_TYPE_NIGHT_CHARGES:
            return "Night Charges"
        default:
            return fareType
        }
    }
    
    @IBAction func DisputeTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.updateAddedPaymentStatus(id: taxiTripExtraFareDetails?.id ?? "", customerId: UserDataCache.getInstance()?.userId ?? "", status: TaxiUserAdditionalPaymentDetails.STATUS_REJECTED) {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.viewModel.getOutstationFareSummaryDetails()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
            }
        }
    }
}
