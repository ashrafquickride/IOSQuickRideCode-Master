//
//  MyAccountViewController.swift
//  Quickride
//
//  Created by KNM Rao on 07/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import MRCountryPicker
import BottomPopup

protocol AccountUpdateDelegate{
  func accountUpdated()
}



class MyAccountViewController: BottomPopupViewController,AccountUpdateDelegate,MRCountryPickerDelegate
{
  
  @IBOutlet var contactNumberLabel: UILabel!
  
  @IBOutlet var organisationalMailLabel: UILabel!
  
  @IBOutlet var communicationalMailLabel: UILabel!
  
  @IBOutlet var countryCodeLabel: UILabel!
  @IBOutlet var countryFlag: UIImageView!
  @IBOutlet var countryPicker: MRCountryPicker!
    
    @IBOutlet weak var changeContactNumberView: UIView!
    @IBOutlet weak var changeOrganizationMailView: UIView!
    @IBOutlet weak var changeCommunicationMailView: UIView!
    
    @IBOutlet weak var changeAlternateNumberView: UIView!
    
    @IBOutlet weak var alternateContactNumberLbl: UILabel!
    
    @IBOutlet weak var alternateNumberButton: UIButton!
    
    @IBOutlet weak var deleteView: UIView!
    
    var profile : UserProfile?
    var accountUpdateDelegate : AccountUpdateDelegate?
 
  
  override func viewDidLoad() {
    self.automaticallyAdjustsScrollViewInsets = false
    changeContactNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.changeContactNumberAction(_:))))
    changeOrganizationMailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.changeOrganisationalMailAction(_:))))
    changeCommunicationMailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.changeCommunicationMailAction(_:))))
    changeAlternateNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyAccountViewController.changeAlternateNumberAction(_:))))
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
      
  }
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = true
    profile = UserDataCache.getInstance()?.getLoggedInUserProfile()?.copy() as? UserProfile

    if profile!.email != nil{
      organisationalMailLabel.text = profile!.email
    }else{
      organisationalMailLabel.text = "Click on change to configure Organization email"
    }
    if profile!.emailForCommunication != nil{
      communicationalMailLabel.text = profile!.emailForCommunication
    }else{
      communicationalMailLabel.text = "Click on change to configure contact email"
    }
    let user = UserDataCache.getInstance()?.currentUser!.copy() as? User
    contactNumberLabel.text = StringUtils.getStringFromDouble(decimalNumber: user!.contactNo)
    if countryCodeLabel != nil{
      
      if user!.countryCode != nil && user!.countryCode!.isEmpty == false{
        countryPicker.countryPickerDelegate = self
        countryPicker.setCountryByPhoneCode(user!.countryCode!)
      }else{
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        if countryCode != nil{
        countryPicker.countryPickerDelegate = self
            countryPicker.setCountryByPhoneCode(countryCode!)
        }else{
          countryPicker.countryPickerDelegate = self
          countryPicker.setCountryByPhoneCode(AppConfiguration.DEFAULT_COUNTRY_CODE)
        }
      }
    }
    
    if let alternateNumber = user!.alternateContactNo,alternateNumber != 0{
        alternateContactNumberLbl.text = StringUtils.getStringFromDouble(decimalNumber: alternateNumber)
        alternateNumberButton.setTitle(Strings.change_caps.capitalized, for: .normal)
    }else{
        alternateContactNumberLbl.text = Strings.edit_alternate_num_text
        alternateNumberButton.setTitle(Strings.add_caps.capitalized, for: .normal)
    }
  }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
    countryCodeLabel.text = phoneCode
    countryFlag.image = flag
  }

    @objc func changeContactNumberAction(_ gesture : UITapGestureRecognizer) {
        
        let viewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeMobileNumber") as! ChangeMobileNumber
        viewController.accountUpdateDelegate = self
        
        viewController.initialisingDataHandling(){ phoneNumber , countryFlag in
            self.dismiss(animated: false)
            
            guard let phoneNumber = phoneNumber else {
                return
            }
            if !phoneNumber.isEmpty {
                if AppUtil.isValidPhoneNo(phoneNo: phoneNumber, countryCode: countryFlag) == false
                {
                    MessageDisplay.displayAlert(messageString: Strings.phone_no_not_valid,viewController: self,handler: nil)
                    return
                }
                
                if(QRSessionManager.getInstance()!.getCurrentSessionStatus() == UserSessionStatus.Unknown){
                    MessageDisplay.displayAlert(messageString:  Strings.phone_no_same_as_old, viewController: self,handler: nil)
                    return
                }
                
                QuickRideProgressSpinner.startSpinner()
                UserRestClient.changeMobileNumber(userId: (QRSessionManager.getInstance()?.getUserId())!,newMobileNo: phoneNumber,countryCode: countryFlag, viewController: self)
                {
                    responseObject, error in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        
                        let viewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ActivateMobileNumberAfterChange") as! ActivateMobileNumberAfterChange
                        viewController.initializeDataBeforePresenting(phoneNumber : phoneNumber,countryCode: countryFlag,accountUpdateDelegate:  self.accountUpdateDelegate)
                       viewController.modalPresentationStyle = .overFullScreen
                        viewController.accountUpdateDelegate = self
                        self.present(viewController, animated: false, completion: nil)
                        
                    } else {
                        
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                }
            }
        }
        self.present(viewController, animated: false, completion: nil)
    }
       
        
       
  @IBAction func backButtonAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: false)
  }
  
    @objc func changeOrganisationalMailAction(_ gesture : UITapGestureRecognizer) {
    
    let viewController = UIStoryboard(name: "MyPreferences", bundle: nil).instantiateViewController(withIdentifier: "ChangeOrganisationalMailViewController") as! ChangeOrganisationalMailViewController
    viewController.accountUpdateDelegate = self
        self.present(viewController, animated: false, completion: nil)
  }
  
    @objc func changeCommunicationMailAction(_ gesture : UITapGestureRecognizer) {
    let viewController = UIStoryboard(name: "MyPreferences", bundle: nil).instantiateViewController(withIdentifier: "ChangeCommunicationMailViewController") as! ChangeCommunicationMailViewController
    viewController.accountUpdateDelegate = self
        self.present(viewController, animated: false, completion: nil)
  }
    @objc func changeAlternateNumberAction(_ gesture : UITapGestureRecognizer) {
        let addAlternateNumViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddOrUpdateAlternateNumberViewController") as! AddOrUpdateAlternateNumberViewController
        addAlternateNumViewController.accountUpdateDelegate = self
        self.present(addAlternateNumViewController, animated: false, completion: nil)
     }
    
    @IBAction func suspendAccountAction(_ sender: Any) {
        suspendAccount()
    }
    func suspendAccount()  {
        let textFieldAlertController = UIStoryboard(name: "MyPreferences", bundle: nil).instantiateViewController(withIdentifier: "TextFieldCustomAlertController") as! TextFieldCustomAlertController
        textFieldAlertController.initializeDataBeforePresentingView(textAlignment: NSTextAlignment.left, placeHolder: Strings.suspend_account_hint, handler: { (text, result) in
            if Strings.yes_caps == result
            {
                let reason = text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                if reason!.count == 0{
                    MessageDisplay.displayAlert(messageString: Strings.suspend_reason,  viewController: self,handler: nil)
                    return
                }
                QuickRideProgressSpinner.startSpinner()
                UserRestClient.setSuspendUser(userId: QRSessionManager.getInstance()!.getUserId(), suspendedByUser: true, suspendedMessage : text!, viewContrller: self, responseHandler: { (responseObject, error) in
                   QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        if UserDataCache.getInstance() != nil
                        {
                            UserDataCache.getInstance()!.notifyUserLockedStatus()
                        }
                    }
                    else {
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                })
            }
        })
        self.present(textFieldAlertController, animated: false, completion: nil)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let deleteAccountViewControllerSB = UIStoryboard(name: "DeleteAccountSB", bundle: nil).instantiateViewController(withIdentifier: "DeleteAccountViewControllerSB") as! DeleteAccountViewControllerSB
        deleteAccountViewControllerSB.handler = {
            (action: DeleteAction) -> Void in
            if action == .suspend{
                self.suspendAccount()
            }else if action == .delete{
                self.deleteAccount()
            }
        }
        present(deleteAccountViewControllerSB, animated: true, completion: nil)
    }
    func deleteAccount() {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.deleteUserAccount(userId: UserDataCache.getCurrentUserId()) { responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            if let result = responseObject?["result"] as? String, result == HttpUtils.RESPONSE_SUCCESS{
                LogOutTask(viewController: self).userLogOutTask()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
  func accountUpdated(){
    self.viewWillAppear(false)
  }
  
}
