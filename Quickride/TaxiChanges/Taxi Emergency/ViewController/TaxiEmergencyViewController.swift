//
//  TaxiEmergencyViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class TaxiEmergencyViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var editEmergencyContactNoView: UIView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactNoLabel: UILabel!
    @IBOutlet weak var addEmergencyContactNoView: UIView!
    
    private var taxiEmergencyViewModel = TaxiEmergencyViewModel()
    
    func iniatialiseEmergencyView(isEmergencyAlreadyStarted: Bool,taxiPassengerRide: TaxiRidePassenger?,driverName: String,driverContactNo: String){
        taxiEmergencyViewModel = TaxiEmergencyViewModel(isEmergencyAlreadyStarted: isEmergencyAlreadyStarted,taxiPassengerRide: taxiPassengerRide,driverName: driverName,driverContactNo: driverContactNo)
    }   
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        checkEmergencyContactIsAvailableOrNot()
    }
    
    private func checkEmergencyContactIsAvailableOrNot(){
        if let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact,!emergencyContactNo.isEmpty{
            let nameAndPhoneNo = emergencyContactNo.components(separatedBy: "(") // contact no is "name(contactNo)" in this format extracting and showing
            editEmergencyContactNoView.isHidden = false
            addEmergencyContactNoView.isHidden = true
            contactNameLabel.text = nameAndPhoneNo[0]
            let contactNo = nameAndPhoneNo[1].dropLast()
            contactNoLabel.text = String(contactNo)
            if !taxiEmergencyViewModel.isEmergencyAlreadyStarted{
                startEmergency()
            }
        }else{
            editEmergencyContactNoView.isHidden = true
            addEmergencyContactNoView.isHidden = false
            
        }
    }
    
    func startEmergency(){
        initiateEmergency()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        taxiEmergencyViewModel.noOfIntimations = Int(clientConfiguration.maxTimeEmergency/clientConfiguration.timeDelayEmergency)
        taxiEmergencyViewModel.timerTask = Timer.scheduledTimer(timeInterval: clientConfiguration.timeDelayEmergency/1000, target: self, selector: #selector(TaxiEmergencyViewController.sendEmergencyContact), userInfo: nil, repeats: true)
    }
    
    @objc func sendEmergencyContact(){
       AppDelegate.getAppDelegate().log.debug("sendEmergencyContact()")
        taxiEmergencyViewModel.noOfIntimations -= 1
        if taxiEmergencyViewModel.noOfIntimations == 0{
            taxiEmergencyViewModel.timerTask!.invalidate()
        }else{
            self.sendMessageToSelecetdContact(url: taxiEmergencyViewModel.messageUrl ?? "")
        }
    }
    private func initiateEmergency() {
        let taxiGroupI = StringUtils.getStringFromDouble(decimalNumber: taxiEmergencyViewModel.taxiPassengerRide?.taxiGroupId)
        taxiEmergencyViewModel.prepareRideTrackCoreURL(taxiGroupId: taxiGroupI) { (url) in
            self.taxiEmergencyViewModel.messageUrl = url
            self.taxiEmergencyViewModel.initiateEmeregency(url: url) { (result) in
            }
            self.sendMessageToSelecetdContact(url: url)
        }
    }
    
    private func sendMessageToSelecetdContact(url: String){
        let messageBody = taxiEmergencyViewModel.getMessageForEmergency(contactNo: contactNoLabel.text ?? "", url: url)
        let messageViewConrtoller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = messageBody
            messageViewConrtoller.recipients = [(contactNoLabel.text ?? "")]
            messageViewConrtoller.messageComposeDelegate = self
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: messageViewConrtoller, animated: false, completion: nil)
        }
    }
    
    private func selectEmergencyContact(){
        let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
        selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
        selectContactViewController.modalPresentationStyle = .overFullScreen
        self.present(selectContactViewController, animated: false, completion: nil)
    }
    
    @IBAction func editTapped(_ sender: Any) {
        selectEmergencyContact()
    }
    
    @IBAction func addContactNumberTapped(_ sender: Any) {
        selectEmergencyContact()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    @IBAction func callSupportTapped(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        AppUtilConnect.callSupportNumber(phoneNumber: clientConfiguration.quickRideSupportNumberForTaxi, targetViewController: self )
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
    override func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled :
            UIApplication.shared.keyWindow?.makeToast( Strings.sending_sms_cancelled)
            controller.dismiss(animated: false, completion: nil)
            
        case .sent :
            UIApplication.shared.keyWindow?.makeToast( Strings.sms_sent)
            controller.dismiss(animated: false, completion: nil)
            
        case .failed :
            UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_failed)
            controller.dismiss(animated: false, completion: nil)
            
        default:
            break
        }
    }
}
//MARK: SelectContactDelegate
extension TaxiEmergencyViewController: SelectContactDelegate{
    func selectedContact(contact: Contact) {
        let emergencyContact = EmergencyContactUtils.getEmergencyContactNumberWithName(contact: contact)
        UserDataCache.getInstance()?.updateUserProfileWithTheEmergencyContact(emergencyContact: emergencyContact,viewController : self)
        editEmergencyContactNoView.isHidden = false
        addEmergencyContactNoView.isHidden = true
        contactNameLabel.text = contact.contactName.capitalized
        contactNoLabel.text = StringUtils.getStringFromDouble(decimalNumber: contact.contactNo)
        startEmergency()
    }
    
}
