//
//  TripTypeViewController.swift
//  Quickride
//
//  Created by Rajesab on 24/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TripTypeViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pesrsonalSelectionImageView: UIImageView!
    @IBOutlet weak var contactDetailsTableView: UITableView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var confirmButton: QRCustomButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var tripTypeViewModel = TripTypeViewModel()

    func initialiseData(behalfBookingPhoneNumber: String?, behalfBookingName: String?, completionHandler : handleTaxiBookingForSomeOneHandler?){
        tripTypeViewModel = TripTypeViewModel(behalfBookingName: behalfBookingName, behalfBookingPhoneNumber: behalfBookingPhoneNumber, completionHandler: completionHandler )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        contactDetailsTableView.dataSource = self
        contactDetailsTableView.delegate = self
        nameTextfield.delegate = self
        numberTextField.delegate = self
        tableViewHeightConstraint.constant = CGFloat(tripTypeViewModel.behalfBookingContactDetailsList.count * 45)
        if tripTypeViewModel.selectedIndex == nil {
            pesrsonalSelectionImageView.image = UIImage(named: "box_with_tick_icon")
            confirmButton.setTitle(Strings.skip.uppercased(), for: .normal)
            confirmButton.borderWidth = 2
            confirmButton.borderColor = .systemBlue
            confirmButton.backgroundColor = .white
            confirmButton.setTitleColor(.systemBlue, for: .normal)
        }else {
            pesrsonalSelectionImageView.image = UIImage(named: "box_without_tick_icon")
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }

    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }

    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    private func setupUI(){
        tableViewHeightConstraint.constant = CGFloat(tripTypeViewModel.behalfBookingContactDetailsList.count * 45)
        confirmButton.backgroundColor = UIColor(netHex: 0x00B557)
        confirmButton.isUserInteractionEnabled = true
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitle(Strings.confirm.uppercased(), for: .normal)
        confirmButton.borderWidth = 0
        if tripTypeViewModel.selectedIndex == nil {
            pesrsonalSelectionImageView.image = UIImage(named: "box_with_tick_icon")
        }else {
            pesrsonalSelectionImageView.image = UIImage(named: "box_without_tick_icon")
        }
    }
    
    @IBAction func changeContactTapped(_ sender: Any) {
        ContactUtils.requestForAccess { (status) in
            if status {
                self.moveToContactSelectionScreen()
            }
        }
    }
    
    private func moveToContactSelectionScreen(){
        let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
        selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
        self.present(selectContactViewController, animated: false, completion: nil)
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        if confirmButton.titleLabel?.text == Strings.skip.uppercased() {
            closeView()
        }else {
            confirmAndCloseView()
        }
    }
    
    @IBAction func personalBtnTapped(_ sender: Any) {
        tripTypeViewModel.selectedIndex = nil
        contactDetailsTableView.reloadData()
        setupUI()
    }
    
    private func confirmAndCloseView(){
        guard let handler = tripTypeViewModel.completionHandler else {
            return
        }
        if let selectedIndex = tripTypeViewModel.selectedIndex {
            handler(tripTypeViewModel.behalfBookingContactDetailsList[selectedIndex].behalfBookingName, tripTypeViewModel.behalfBookingContactDetailsList[selectedIndex].behalfBookingPhoneNumber)
            storeNewContactToList(contactName: tripTypeViewModel.behalfBookingContactDetailsList[selectedIndex].behalfBookingName ?? "", contactNo: tripTypeViewModel.behalfBookingContactDetailsList[selectedIndex].behalfBookingPhoneNumber ?? "")
        }else if let name = nameTextfield.text, !name.isEmpty , let number = numberTextField.text, !number.isEmpty {
            storeNewContactToList(contactName: name, contactNo: number)
            handler(nameTextfield.text, numberTextField.text)
        }else {
            handler(nil,nil)
        }
        closeView()
    }
}
extension TripTypeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tripTypeViewModel.behalfBookingContactDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailsTableviewCell", for: indexPath as IndexPath) as! ContactDetailsTableviewCell
        if indexPath.row == tripTypeViewModel.selectedIndex {
            cell.radioButtonImageView.image = UIImage(named: "radio_button_checked")
        }else {
            cell.radioButtonImageView.image = UIImage(named: "radio_button_1")
        }
        cell.detailsLabel.text = (tripTypeViewModel.behalfBookingContactDetailsList[indexPath.row].behalfBookingName ?? "") + ", " + (tripTypeViewModel.behalfBookingContactDetailsList[indexPath.row].behalfBookingPhoneNumber ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tripTypeViewModel.selectedIndex = indexPath.row
        setupUI()
        contactDetailsTableView.reloadData()
    }

}
extension TripTypeViewController: SelectContactDelegate {
    func selectedContact(contact: Contact) {
        storeNewContactToList(contactName: contact.contactName, contactNo: StringUtils.getStringFromDouble(decimalNumber: contact.contactNo))
        contactDetailsTableView.reloadData()
        setupUI()
    }
    
    private func storeNewContactToList(contactName: String, contactNo: String){
        var behalfBookingContactDetailsList = tripTypeViewModel.behalfBookingContactDetailsList
        let index = behalfBookingContactDetailsList.firstIndex(where: {$0.behalfBookingPhoneNumber == contactNo})
        if let index = index {
            tripTypeViewModel.behalfBookingContactDetailsList.swapAt(0, index)
            tripTypeViewModel.selectedIndex = 0
            SharedPreferenceHelper.storeBehalfBookingContactDetails(behalfBookingContactDetailsList: tripTypeViewModel.behalfBookingContactDetailsList)
            return
        }else if behalfBookingContactDetailsList.count > 2 {
            behalfBookingContactDetailsList.removeLast()
        }
        var contactNameDetail = contactName
        if contactNameDetail.isEmpty {
            contactNameDetail = contactNo
        }
        let newcontactDetail = TaxiBehalfBookingContactDetails(behalfBookingName: contactNameDetail, behalfBookingPhoneNumber: contactNo)
        behalfBookingContactDetailsList.insert(newcontactDetail, at: 0)
        tripTypeViewModel.behalfBookingContactDetailsList = behalfBookingContactDetailsList
        SharedPreferenceHelper.storeBehalfBookingContactDetails(behalfBookingContactDetailsList: behalfBookingContactDetailsList)
        tripTypeViewModel.selectedIndex = 0
    }
}
extension TripTypeViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        confirmButton.borderWidth = 0
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitle(Strings.confirm.uppercased(), for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        tripTypeViewModel.selectedIndex = nil
        contactDetailsTableView.reloadData()
        pesrsonalSelectionImageView.image = UIImage(named: "box_without_tick_icon")
        if textField == nameTextfield, let currentString: NSString = textField.text as NSString? {
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length > 0, numberTextField.text!.count == 10 {
                confirmButton.backgroundColor = UIColor(netHex: 0x00B557)
                confirmButton.isUserInteractionEnabled = true
            }else {
                confirmButton.backgroundColor = .lightGray
                confirmButton.isUserInteractionEnabled = false
            }
        }else if textField == numberTextField, let currentString: NSString = textField.text as NSString? {
            let maxLength = 10
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length >= 10, !(nameTextfield.text?.isEmpty ?? true)  {
                confirmButton.backgroundColor = UIColor(netHex: 0x00B557)
                confirmButton.isUserInteractionEnabled = true
            }else {
                confirmButton.backgroundColor = .lightGray
                confirmButton.isUserInteractionEnabled = false
            }
            if newString.length <= maxLength{
                return true
            }else {
                return false
            }

        }
        return true
    }
}
