//
//  CustomerAlertViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CustomerAlertViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var mainContantView: QuickRideCardView!
    @IBOutlet weak var customerReasonAlertTableview: UITableView!
    @IBOutlet weak var customerAlertTabelViewHeight: NSLayoutConstraint!
    @IBOutlet weak var otherReasonTextView: UIView!
    @IBOutlet weak var sendAlertBtn: QRCustomButton!
    @IBOutlet weak var otherReasonTextField: UITextField!
    @IBOutlet weak var sendbtnBottomCon: NSLayoutConstraint!
    @IBOutlet weak var otherReasonHeightCon: NSLayoutConstraint!

    var customerAlertViewModel: CustomerAlertViewModel?
    private var isKeyBoardVisible = false
 
    
    func initialiseDataBfrPresentingView(taxiRidePassenger: TaxiRidePassengerDetails?, isTaxiStarted: Bool?, completionHandler : customerReasonsCompletionHandler?){
        customerAlertViewModel = CustomerAlertViewModel(taxiRidePassenger: taxiRidePassenger, isTaxiStarted: isTaxiStarted, completionHandler: completionHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.mainContantView.center.y -= self.mainContantView.bounds.height
            }, completion: nil)
        customerAlertViewModel?.prepareCustomerReasons()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        customerReasonAlertTableview.delegate = self
        customerReasonAlertTableview.dataSource = self
        otherReasonHeightCon.constant = 0
        otherReasonTextField.delegate = self
        otherReasonTextView.isHidden = true
        customerAlertTabelViewHeight.constant = CGFloat(((customerAlertViewModel?.customerReasonsList.count ?? 0 ))*35)
        sendAlertBtn.backgroundColor = .lightGray
        sendAlertBtn.isUserInteractionEnabled = false
       NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            sendbtnBottomCon.constant = keyBoardSize.height + 15

        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        sendbtnBottomCon.constant = 15
    }
    
    func typeOfRisk(index: Int){
        
        if customerAlertViewModel?.isTaxiStarted == true {
            
            switch index {
            case 0:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_AC_IS_NOT_ON
            case 1:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_DEMANDING_EXTRA_MONEY
            case 2:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_DEVIATED_ROUTE
            case 3:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_CALL_ME_BACK_CUSTOMER
            default:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_CUSTOMER_RAISED
            }
        } else {
            switch index {
            case 0:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_NOT_ANSWRING
            case 1:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_REFUSAL
            case 2:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_DEMANDING_EXTRA_MONEY
            case 3:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_CALL_ME_BACK_CUSTOMER
            case 4:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_NOT_MOVING
            case 5:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_DRIVER_ASKING_FOR_OFFLINE_BOOKING
            case 6:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_PAYMENT_ISSUE
            case 7:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_CLARIFICATION
            case 8:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_ROUTE_CHANGE_REQUIRED
            default:
                customerAlertViewModel?.riskType = RideRiskAssessment.RISK_TYPE_CUSTOMER_RAISED
            }
        }
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func sendMessageAlertBtn(_ sender: Any) {
        self.view.endEditing(true)
        if let text = customerAlertViewModel?.customerReason, let type = customerAlertViewModel?.riskType, let texthandler = customerAlertViewModel?.customerReasonsCompletionHandler{
            texthandler(text, type)
        }
        closeView()
    }
}

extension  CustomerAlertViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerAlertViewModel?.customerReasonsList.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reasonsListCell = tableView.dequeueReusableCell(withIdentifier: "CustomerAlertReasonTableViewCell", for: indexPath) as! CustomerAlertReasonTableViewCell
        reasonsListCell.selectionStyle = .none
        reasonsListCell.toSetUpUi(selectedIndex: customerAlertViewModel?.selectedIndex, index: indexPath.row, reasonText: customerAlertViewModel?.customerReasonsList[indexPath.row] ?? "")
        return reasonsListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        customerAlertViewModel?.selectedIndex = indexPath.row
       if indexPath.row == (customerAlertViewModel?.customerReasonsList.count ?? 0) - 1 {
            otherReasonTextView.isHidden = false
           otherReasonHeightCon.constant = 40
            otherReasonTextField.text = ""
           sendAlertBtn.backgroundColor = .lightGray
           sendAlertBtn.isUserInteractionEnabled = false
        } else {
            otherReasonTextView.isHidden = true
            otherReasonHeightCon.constant = 0
            customerAlertViewModel?.customerReason = customerAlertViewModel?.customerReasonsList[indexPath.row]
            sendAlertBtn.backgroundColor = UIColor(netHex: 0x00B557)
            typeOfRisk(index: indexPath.row)
            sendAlertBtn.isUserInteractionEnabled = true
       }
      customerReasonAlertTableview.reloadData()
   }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
}

extension CustomerAlertViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
           customerAlertViewModel?.customerReason = textField.text
           sendAlertBtn.backgroundColor = UIColor(netHex: 0x00B557)
            sendAlertBtn.isUserInteractionEnabled = true
            typeOfRisk(index: 4)
       }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCountList = textField.text?.count ?? 0
        if currentCharacterCountList > 18{
            sendAlertBtn.backgroundColor = UIColor(netHex: 0x00b557)
            sendAlertBtn.isUserInteractionEnabled = true
        }else{
            sendAlertBtn.backgroundColor = UIColor(netHex: 0xD3D3D3)
            sendAlertBtn.isUserInteractionEnabled = false
        }
        let newLength = currentCharacterCountList + string.count - range.length
        if newLength > 250{
            return false
        }
        return true
    }
}
