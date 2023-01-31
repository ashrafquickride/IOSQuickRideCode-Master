//
//  CancelledTripTableViewCell.swift
//  Quickride
//
//  Created by HK on 07/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelledTripTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feeInfoView: UIView!
    @IBOutlet weak var appliedFeeLabel: UILabel!
    @IBOutlet weak var cancelledByLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var appliedFeeView: UIView!
    @IBOutlet weak var vehicelModelLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverImage: CircularImageView!
    
    private var taxiRide: TaxiRidePassenger?
    
    func initialiseCancellationCell(cancelTaxiRideInvoice: CancelTaxiRideInvoice,taxiRide: TaxiRidePassenger?){
        if cancelTaxiRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_CUSTOMER{
            feeInfoView.isHidden = false
            appliedFeeLabel.textColor = UIColor(netHex: 0xE20000)
            appliedFeeLabel.text = "-" + String(format: Strings.points_with_rupee_symbol, arguments: [String(cancelTaxiRideInvoice.penaltyAmount)])
        }else if cancelTaxiRideInvoice.penalizedTo == TaxiPoolConstants.PENALIZED_TO_PARTNER{
            feeInfoView.isHidden = true
            appliedFeeLabel.textColor = UIColor(netHex: 0x00B557)
            appliedFeeLabel.text = "+" + String(format: Strings.points_with_rupee_symbol, arguments: [ String(cancelTaxiRideInvoice.penaltyAmount)])
        }else{
           appliedFeeView.isHidden = true
           feeInfoView.isHidden = true
        }
        checkCancelledBy(cancelledBy: cancelTaxiRideInvoice.cancelledBy ?? "")
        reasonLabel.text = "Reason - " + (cancelTaxiRideInvoice.cancelReason ?? "")
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(taxiRide?.initialFare ?? 0)])
        driverNameLabel.text = cancelTaxiRideInvoice.driverName?.capitalized ?? ""
        vehicelModelLabel.text = (cancelTaxiRideInvoice.vehicleModel?.capitalized ?? "") + "," + (cancelTaxiRideInvoice.vehicleNo?.capitalized ?? "")
        ImageCache.getInstance().setImageToView(imageView: driverImage, imageUrl:  cancelTaxiRideInvoice.driverImgUri ?? "", placeHolderImg: UIImage(named: "default_taxi_driver"),imageSize: ImageCache.DIMENTION_SMALL)
    }
    @IBAction func cancellationPolicyTapped(_ sender: Any) {
        var url = ""
        var title = ""
        if taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            url = AppConfiguration.outstation_taxi_cancel_url
            title = Strings.taxi_cancel_policy
        }else{
            if taxiRide?.shareType == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING{
                url = AppConfiguration.taxipool_cancel_url
                title = Strings.taxipool_cancel_policy
            }else{
                url = AppConfiguration.local_taxi_cancel_url
                title = Strings.taxi_cancel_policy
            }
        }
        let urlcomps = URLComponents(string :  url)
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: title, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.parentViewController?.navigationController?.pushViewController(webViewController, animated: false)
        }
    }
    
    private func checkCancelledBy(cancelledBy: String){
        switch cancelledBy {
        case TaxiPoolConstants.CANCELLED_BY_CUSTOMER:
            cancelledByLabel.text = String(format: Strings.cancelled_by, arguments: ["you"])
            case TaxiPoolConstants.CANCELLED_BY_PARTNER:
            cancelledByLabel.text = String(format: Strings.cancelled_by, arguments: ["driver"])
            case TaxiPoolConstants.CANCELLED_BY_OPERATOR:
            cancelledByLabel.text = String(format: Strings.cancelled_by, arguments: ["operator"])
        default:
            cancelledByLabel.text = String(format: Strings.cancelled_by, arguments: ["system"])
        }
    }
}
