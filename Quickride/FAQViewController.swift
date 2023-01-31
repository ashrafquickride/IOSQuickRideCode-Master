//
//  FAQViewController.swift
//  Quickride
//
//  Created by Vinutha on 3/30/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class FAQViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var faqTableView: UITableView!
    
    var faqElement : [String] = [String]()
    var customerSupportElement : CustomerSupportElement?
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.faqTableView.delegate = nil
        self.faqTableView.dataSource = nil
        CustomerSupportDetailsParser.getInstance().getCustomerSupportElement { (customerSupportElement) in
            self.customerSupportElement = customerSupportElement
            self.faqElement = Strings.faq_Element
            self.faqTableView.delegate = self
            self.faqTableView.dataSource = self
            self.faqTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillDisappear()")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Strings.faq_Element.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqInfoCell") as! FAQTableViewCell
        if faqElement.endIndex <= indexPath.row{
            return cell
        }
        cell.infoLabel.text = faqElement[indexPath.row]
        let origImage = cell.forwardImage.image
        let tintedImage = origImage!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.forwardImage.image = tintedImage
        cell.forwardImage.tintColor = UIColor.black
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath()")
        if faqElement[indexPath.row] == Strings.others{
            HelpUtils.sendEmailToSupport(viewController: self, image: nil,listOfIssueTypes: Strings.list_of_issue_types)
        }
        else{
            self.moveToCustomerInfoView(indexPath: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func moveToCustomerInfoView(indexPath: Int){
        let element = customerSupportElement!.customerSupportElement![indexPath]
        let customerInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CustomerInfoViewController") as! CustomerInfoViewController
        customerInfoViewController.initializeDataBeforepresentingView(customerSupportElement: element)
        self.navigationController?.pushViewController(customerInfoViewController, animated: false)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
}

