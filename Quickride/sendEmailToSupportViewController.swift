//
//  sendEmailToSupportViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Foundation
import MessageUI
import Zip


class sendEmailToSupportViewController: UIViewController {
    
   
    @IBOutlet weak var sendEmailSupportTableView: UITableView!
    

    var handler: supportCategorySelectionHandler?
    
    var listOfIssueTypes: [String]?
     var image : UIImage?
    
    func  intialisingListofIssues(listOfIssueTypes: [String], image : UIImage?) {
        self.listOfIssueTypes = listOfIssueTypes
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendEmailSupportTableView.dataSource = self
        sendEmailSupportTableView.delegate = self
        setUI()
        self.sendEmailSupportTableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setUI() {
    sendEmailSupportTableView.estimatedRowHeight = 50
    sendEmailSupportTableView.rowHeight = UITableView.automaticDimension
    sendEmailSupportTableView.register(UINib(nibName: "SendEmailSupportTableViewCell", bundle: nil), forCellReuseIdentifier: "SendEmailSupportTableViewCell")
    }


    @IBAction func backButtnTapped(_ sender: Any) {
        dismiss(animated: false)
    }
}
    
extension sendEmailToSupportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  listOfIssueTypes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendEmailSupportTableViewCell", for: indexPath) as! SendEmailSupportTableViewCell
        cell.listofIssueLabel?.text = listOfIssueTypes?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let issue = listOfIssueTypes?[indexPath.row] ?? " "
        HelpUtils.sendMailToSupportWithSubject(delegate: self, viewController: self, messageBody: nil,subject: issue, contactNo: nil, image: image)
    
        }
}
extension sendEmailToSupportViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
       
   


    
    


