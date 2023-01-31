//
//  CustomerInfoViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import MessageUI
import UIKit

class CustomerInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var customerInfoTableView: UITableView!
    @IBOutlet weak var customerElementSearchBar: UISearchBar!
    @IBOutlet weak var callOptionButton: CustomUIButton!
    
    var customerSupportElement : CustomerSupportElement?
    var customerSupportElementSearchResults : CustomerSupportElement?
    var isExpanded : [Int : Bool] = [Int: Bool]()
    
    func initializeDataBeforepresentingView(customerSupportElement : CustomerSupportElement?)
    {
        self.customerSupportElement = customerSupportElement
    }
    override func viewDidLoad() {
        customerInfoTableView.delegate = self
        customerInfoTableView.dataSource = self
        customerElementSearchBar.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        customerSupportElementSearchResults = customerSupportElement
        self.navigationItem.title = customerSupportElement?.title
        enableCallOption()
        customerInfoTableView.estimatedRowHeight = 100
        customerInfoTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func enableCallOption() {
        if customerSupportElement?.title == Strings.ride_type_taxipool {
            let hour = NSCalendar.current.component(.hour, from: NSDate() as Date)
            let day = NSCalendar.current.component(.weekday, from: NSDate() as Date)
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            if hour < Int(clientConfiguration.customerSupportAllowFromTime)! || hour >= Int(clientConfiguration.customerSupportAllowToTime)! || day == HelpViewController.saturday || day == HelpViewController.sunday
            {
                callOptionButton.isHidden = true
            } else {
                callOptionButton.isHidden = false
            }
        } else  {
            callOptionButton.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillDisappear()")
        customerElementSearchBar.endEditing(false)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidBeginEditing()")
        searchBar.text = nil
        customerInfoTableView.reloadData()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        AppDelegate.getAppDelegate().log.debug("searchBarTextDidEndEditing()")
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        customerInfoTableView.delegate = nil
        customerInfoTableView.dataSource = nil
        customerSupportElementSearchResults = CustomerSupportElement(title : "Customer Support" , message : nil , suggestion : nil , resolution : nil , input : nil , link: nil, customerSupportElement : [])
        if searchText.isEmpty == true{
            customerSupportElementSearchResults = customerSupportElement
        }
        else
        {
            for customerElement in customerSupportElement!.customerSupportElement!
            {
                if customerElement.customerSupportElement == nil || customerElement.customerSupportElement!.isEmpty
                {
                    if (customerElement.title?.localizedCaseInsensitiveContains(searchText))!{
                        customerSupportElementSearchResults!.customerSupportElement!.append(customerElement)
                    }
                }
                else{
                    for customerTitle1 in customerElement.customerSupportElement!
                    {
                        if (customerTitle1.title?.localizedCaseInsensitiveContains(searchText))!{
                            customerSupportElementSearchResults!.customerSupportElement!.append(customerTitle1)
                        }
                    }
                }
            }
        }
        customerInfoTableView.delegate = self
        customerInfoTableView.dataSource = self
        customerInfoTableView.reloadData()
    }
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        AppDelegate.getAppDelegate().log.debug("searchBarSearchButtonClicked()")
        searchBar.endEditing(true)
        view.resignFirstResponder()
    }
    
    @IBAction func callOptionBtnPressed(_ sender: UIButton) {
        
        if let phoneNumber = ConfigurationCache.getInstance()?.getClientConfiguration()?.taxiSupportMobileNumber {
            AppUtilConnect.callSupportNumber(phoneNumber: phoneNumber, targetViewController: self)
        } else {
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (customerSupportElementSearchResults?.customerSupportElement?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerInfoCell") as! CustomerInfoTableViewCell
        if isExpanded[indexPath.row] == nil{
            isExpanded[indexPath.row] = false
        }
        cell.set(content: (customerSupportElementSearchResults?.customerSupportElement![indexPath.row])!,isExpanded: isExpanded[indexPath.row]!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if customerSupportElementSearchResults!.customerSupportElement!.count <= indexPath.row{
            return
        }
        let element = customerSupportElementSearchResults?.customerSupportElement![indexPath.row]
        if element?.message == nil || element?.message?.isEmpty == true
        {
            moveToMail()
            return
        }
        isExpanded[indexPath.row] = !isExpanded[indexPath.row]!
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    func moveToMail(){
        HelpUtils.sendEmailToSupport(viewController: self, image: nil,listOfIssueTypes: Strings.list_of_issue_types)

    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
