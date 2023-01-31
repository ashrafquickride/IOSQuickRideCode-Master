//
//  AddPaymentsOnTheWayTableViewCell.swift
//  Quickride
//
//  Created by HK on 11/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddPaymentsOnTheWayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var amountView: QuickRideCardView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var remarksView: QuickRideCardView!
    @IBOutlet weak var remarksTextField: UITextField!
    @IBOutlet weak var actionButton: CustomUIButton!
    
    private var viewModel = AddOutstationAddtionalPaymentsViewModel()
    
    func initialiseAddPayment(viewModel: AddOutstationAddtionalPaymentsViewModel){
        self.viewModel = viewModel
        remarksTextField.delegate = self
        amountTextField.delegate = self
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        if let amount = amountTextField.text,!amount.isEmpty{
            QuickRideProgressSpinner.startSpinner()
            viewModel.addAdditionalPayment(amount: amountTextField.text ?? "", paymentType: TaxiUserAdditionalPaymentDetails.PAYMENT_TYPE_CASH, fareType: viewModel.selectedFareType, description: remarksTextField.text ?? "")
        }else{
            if amountTextField.text?.isEmpty ?? false {
                ViewCustomizationUtils.addBorderToView(view: amountView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
                return
            }
        }
    }
    
    private func changeButtonColor(){
        if let amount = amountTextField.text,!amount.isEmpty{
            actionButton.backgroundColor = Colors.green
        }else{
            actionButton.backgroundColor = .lightGray
        }
    }
}
//MARK:UITextFieldDelegate
extension AddPaymentsOnTheWayTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ViewCustomizationUtils.addBorderToView(view: amountView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        ViewCustomizationUtils.addBorderToView(view: remarksView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        changeButtonColor()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == amountTextField{
            threshold = 10
        }else if textField == remarksTextField{
            threshold = 300
        }else{
            return true
        }
        changeButtonColor()
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
}
