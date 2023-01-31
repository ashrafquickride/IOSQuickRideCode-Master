//
//  TaxiTripHelpTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class TaxiTripHelpTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    private var taxiRide: TaxiRidePassenger?
    func initialiseHelpView(title: String,taxiRide: TaxiRidePassenger?){
        self.taxiRide = taxiRide
        titleLabel.text = title
    }

    
    @IBAction func emailTapped(_ sender: Any) {
        if taxiRide?.status == TaxiRidePassenger.STATUS_CANCELLED{
            let userProfile = UserDataCache.getInstance()?.userProfile
            let modelName = UIDevice.current.model + ", " + UIDevice.current.systemVersion
            let rideId = StringUtils.getStringFromDouble(decimalNumber: taxiRide?.id)
            let taxiGroupId = StringUtils.getStringFromDouble(decimalNumber: taxiRide?.taxiGroupId)
            let fare = String(taxiRide?.initialFare ?? 0)
            let startAddress = (taxiRide?.startAddress ?? "")
            let endAddress = (taxiRide?.endAddress ?? "")
            let cancelReason = (taxiRide?.taxiUnjoinReason ?? "")
            let body = String(format: Strings.taxi_issue_mail_body, arguments: [(userProfile?.userName ?? ""),(SharedPreferenceHelper.getLoggedInUserContactNo() ?? ""),(UserDataCache.getInstance()?.userId ?? ""),rideId,taxiGroupId,(taxiRide?.tripType ?? ""),startAddress,endAddress,fare,cancelReason,modelName,AppConfiguration.APP_CURRENT_VERSION_NO])
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController:  self.parentViewController ?? ViewControllerUtils.getCenterViewController(), subject: "Taxi cancellation", toRecipients: [clientConfiguration.taxiSupportEmail],ccRecipients: [],mailBody: body)
        }else{
            HelpUtils.sendEmailToSupport(viewController: parentViewController ?? ViewControllerUtils.getCenterViewController(), image: nil,listOfIssueTypes: Strings.list_of_issue_types)
        }
    }
}
//MARK: OUtlets
extension TaxiTripHelpTableViewCell: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
