//
//  ContactInvitationStatusController.swift
//  Quickride
//
//  Created by KNM Rao on 09/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ContactInvitationStatusController: ModelViewController,UITableViewDelegate,UITableViewDataSource {
  
  @IBOutlet var backGroundView: UIView!
  
  @IBOutlet var alertView: UIView!
  
  @IBOutlet var tableView: UITableView!
    
  @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
  var contactResponse = [ContactInviteResponse]()
  var contactsMap = [String : Contact]()
  var heights = [Int]()
  var viewController : UIViewController?
  
  func initializeDataBeforePresenting(contactResponse : [ContactInviteResponse],contacts : [Contact],viewController : UIViewController){
    for contact in contacts{
      contactsMap[contact.contactId!] = contact
    }
   
    self.contactResponse = contactResponse
    self.viewController = viewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
    backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactInvitationStatusController.backgroundTapped(_:))))
    ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contactResponse.count
  }
    
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InviteContactStatusTableViewCell") as! InviteContactStatusTableViewCell
    if contactResponse.endIndex <= indexPath.row{
        return cell
    }
    let contactInviteResponse = contactResponse[indexPath.row]
    let contact = contactsMap[contactInviteResponse.contactId!]
    cell.userName.text = contact?.contactName
    cell.contactNumber.text = NumberUtils.getMaskedMobileNumber(mobileNumber: contact?.contactNo)
    if contactInviteResponse.success{
      cell.statusImage.image = UIImage(named: "ride_sch")
      cell.failureMessage.isHidden = true
    }else{
      cell.statusImage.image = UIImage(named: "ride_cncl")
      cell.failureMessage.isHidden = false
      cell.failureMessage.text = contactInviteResponse.error!.userMessage!
    }

    return cell
  }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contactInviteResponse = contactResponse[indexPath.row]
        if contactInviteResponse.success{
            return 50
        }else{
            let lines = CGFloat(contactInviteResponse.error!.userMessage!.count * 12)/(self.alertView.frame.size.width - 40)
            var height = lines * CGFloat(ViewCustomizationUtils.ALERT_DIALOG_LABEL_LINE_HEIGHT)
            height = height + 20
          
          if height < 50{
            height = 50
          }
          return height

        }
    }
    @objc func backgroundTapped(_ sender : UITapGestureRecognizer){
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
  
  @IBAction func doneAction(_ sender: Any) {
    self.view.removeFromSuperview()
    self.removeFromParent()
    viewController?.navigationController?.popViewController(animated: false)
  }
}
