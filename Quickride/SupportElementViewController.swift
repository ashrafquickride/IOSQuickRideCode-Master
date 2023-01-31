//
//  SupportElementViewController.swift
//  Quickride
//
//  Created by Vinutha on 4/13/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class SupportElementViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var supportTableView: UITableView!
    var supportElement : [String]?
    var name: String?
    
    func initializeDataBeforePresenting(name: String)
    {
        self.name = name
    }
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        supportTableView.delegate = self
        supportTableView.dataSource = self
        if name == Strings.report_issue{
            supportElement = Strings.report_issue_elements
        }
        else{
            supportElement = Strings.voice_support_elements
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportElement!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "supportCell") as! SupportTableViewCell
        if supportElement!.endIndex <= indexPath.row{
            return cell
        }
        cell.infoLabel.text = supportElement![indexPath.row]
        switch indexPath.row {
        case 1:
            cell.subTitle.text = Strings.issue_resolution_period
        default:
            cell.subTitle.text = nil
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        AppDelegate.getAppDelegate().log.debug("\(indexPath)")
        
        switch indexPath.row {
        case 0:
            openFaQsPage()
        case 1:
            HelpUtils.sendEmailToSupport(viewController: self, image: nil,listOfIssueTypes: Strings.list_of_issue_types)
         case 2:
            if name == Strings.report_issue{
                moveToFeedback()
            }
            else{
                callSupport()
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func openFaQsPage(){
        let faqViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
        self.navigationController?.pushViewController(faqViewController, animated: false)
    }
    func moveToFeedback(){
        let feedbackViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        self.navigationController?.pushViewController(feedbackViewController, animated: false)
    }
    func callSupport()
    {
        AppDelegate.getAppDelegate().log.debug("")
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        AppUtilConnect.callSupportNumber(phoneNumber: "\(clientConfiguration!.callQuickRideForSupport)".components(separatedBy: ".")[0], targetViewController: self)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
 }



