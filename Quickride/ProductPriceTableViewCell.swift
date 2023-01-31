//
//  ProductPriceTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 24/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ProductPriceTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rentPerDayView: QuickRideCardView!
    @IBOutlet weak var rentPerDayTextField: UITextField!
    @IBOutlet weak var rentPerMonthView: QuickRideCardView!
    @IBOutlet weak var rentPerMonthTextField: UITextField!
    @IBOutlet weak var sellAmountView: QuickRideCardView!
    @IBOutlet weak var sellAmountTextField: UITextField!
    @IBOutlet weak var rentView: UIView!
    @IBOutlet weak var perMonthView: UIView!
    @IBOutlet weak var sellView: UIView!
    @IBOutlet weak var locationView: QuickRideCardView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addOtherlocationButton: UIButton!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var depositeTextField: UITextField!
    @IBOutlet weak var depositeView: QuickRideCardView!
    
    private var product = Product()
    func initialiseView(product: Product){
        self.product = product
        locationTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectLocationTapped(_:))))
        rentPerDayTextField.delegate = self
        rentPerMonthTextField.delegate = self
        sellAmountTextField.delegate = self
        depositeTextField.delegate = self
        if let _ = product.id, product.pricePerDay == "0"{
            rentPerDayTextField.text = ""
        }else{
            rentPerDayTextField.text = product.pricePerDay
        }
        if let _ = product.id, product.finalPrice == "0"{
            sellAmountTextField.text = ""
        }else{
            sellAmountTextField.text = product.finalPrice
        }
        if let _ = product.id, product.pricePerMonth == "0"{
            rentPerMonthTextField.text = ""
        }else{
            rentPerMonthTextField.text = product.pricePerMonth
        }
        if product.deposit != 0{
            depositeTextField.text = String(product.deposit)
        }else{
            let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: product.categoryCode ?? "")
            depositeTextField.text = String(category?.depositForRent ?? 0)
        }
        showPriceFieldBasedOnTradeSelectionType()
        if !product.location.isEmpty{
            locationTextField.text = product.location[0].completeAddress
        }else{
            locationTextField.text = QuickShareCache.getInstance()?.getUserLocation()?.completeAddress
        }
    }
    private func showPriceFieldBasedOnTradeSelectionType(){
        if product.tradeType == Product.RENT{
            rentView.isHidden = false
            sellView.isHidden = true
            if rentPerDayTextField.text?.isEmpty == true{
                rentPerDayTextField.becomeFirstResponder()
            }
        }else if product.tradeType == Product.SELL{
            rentView.isHidden = true
            sellView.isHidden = false
            if sellAmountTextField.text?.isEmpty == true {
                sellAmountTextField.becomeFirstResponder()
            }
        }else if product.tradeType == Product.DONATE || product.tradeType == Product.SHARE{
            rentView.isHidden = true
            sellView.isHidden = false
        }else{
            rentView.isHidden = false
            sellView.isHidden = false
            if rentPerDayTextField.text?.isEmpty == true{
                rentPerDayTextField.becomeFirstResponder()
            }
        }
    }
    @objc func selectLocationTapped(_ sender :UITapGestureRecognizer){
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: "", currentSelectedLocation: QuickShareCache.getInstance()?.getUserLocation(), hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        parentViewController?.navigationController?.pushViewController(changeLocationViewController, animated: false)
    }
}
//MARK:
extension ProductPriceTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rentPerDayView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: rentPerDayView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        rentPerMonthView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: rentPerMonthView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        sellAmountView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: sellAmountView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        depositeView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: depositeView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        locationView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: locationView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        NotificationCenter.default.post(name: .changeButtonColorIfAllFieldsFilled, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if product.tradeType == Product.RENT{
            product.pricePerDay = rentPerDayTextField.text
            product.pricePerMonth = rentPerMonthTextField.text
            product.deposit = Int(depositeTextField.text ?? "") ?? 0
        }else if product.tradeType == Product.SELL{
            product.finalPrice = sellAmountTextField.text
        }else{
            product.pricePerDay = rentPerDayTextField.text
            product.pricePerMonth = rentPerMonthTextField.text
            product.finalPrice = sellAmountTextField.text
            product.deposit = Int(depositeTextField.text ?? "") ?? 0
        }
        var userInfo = [String: Any]()
        userInfo["product"] = self.product
        NotificationCenter.default.post(name: .productPriceAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == rentPerDayTextField{
            threshold = 10
        }else if textField == rentPerMonthTextField{
            threshold = 10
        }else if textField == sellAmountTextField{
            threshold = 10
        }else if textField == depositeTextField{
            threshold = 10
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
}
//ReceiveLocationDelegate
extension ProductPriceTableViewCell: ReceiveLocationDelegate{
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        product.location.removeAll()
        product.location.append(location)
        locationTextField.text = location.completeAddress
        var userInfo = [String: Any]()
        userInfo["product"] = self.product
        NotificationCenter.default.post(name: .locationSelected, object: nil, userInfo: userInfo)
    }
    
    func locationSelectionCancelled(requestLocationType: String) {}
}
