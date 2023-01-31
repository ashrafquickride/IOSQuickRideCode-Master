//
//  CarpoolContactCustomerCareTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 24/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class CarpoolContactCustomerCareTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var faqLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var isFromTaxiPool = false
    var tripStatus: String?
    var tripType: String?
    var sharing: String?
    func initialiseHelp(title: String, tripStatus: String?, tripType: String?, sharing: String?, isFromTaxiPool: Bool){
        self.titleLabel.text = title
        self.isFromTaxiPool = isFromTaxiPool
        self.tripStatus = tripStatus
        self.sharing = sharing
        
        if isFromTaxiPool {
            imageViewIcon.image = UIImage(named: "faq_image")
            faqLabel.text = "FAQ"
        } else {
            imageViewIcon.image = UIImage(named: "call_black")
            faqLabel.text = "Call"
        }
        }  
    
    
    
    
    
    @IBAction func callButtonClicked(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if isFromTaxiPool{
            let taxiHelpViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxiHelpViewController") as! TaxiHelpViewController
                  taxiHelpViewController.initialiseTaxiStatus(tripStatus: tripStatus, tripType: tripType, sharing: sharing, isfromTaxiLiveRide: true)
            ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: taxiHelpViewController, animated: false)
        }else {
            AppUtilConnect.callSupportNumber(phoneNumber: clientConfiguration.quickRideSupportNumberForCarpool, targetViewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())
        }
    }
    @IBAction func emailButtonClicked(_ sender: Any) {
        if isFromTaxiPool{
            sendingMail(listOfIssueTypes: Strings.list_of_taxi_help_issue)
        }else {
            sendingMail(listOfIssueTypes: Strings.list_of_issue_types)
        }
    }
    
    
    func sendingMail(listOfIssueTypes: [String]){
        HelpUtils.sendEmailToSupport(viewController: parentViewController ?? ViewControllerUtils.getCenterViewController(), image: nil,listOfIssueTypes: listOfIssueTypes)

    }
    
}
extension CarpoolContactCustomerCareTableViewCell: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
