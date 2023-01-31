//
//  PriceAndLoactionSelectionTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PriceAndLoactionSelectionTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var locationView: QuickRideCardView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addOtherlocationButton: UIButton!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    
    private var requestProduct = RequestProduct()
    func initialiseView(requestProduct: RequestProduct){
        self.requestProduct = requestProduct
        locationTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectLocationTapped(_:))))
        if requestProduct.requestLocationInfo != nil{
            locationTextField.text = requestProduct.requestLocationInfo?.address
        }else{
           locationTextField.text = QuickShareCache.getInstance()?.getUserLocation()?.completeAddress
        }
    }
    
    @objc func selectLocationTapped(_ sender :UITapGestureRecognizer){
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: "", currentSelectedLocation: QuickShareCache.getInstance()?.getUserLocation(), hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        parentViewController?.navigationController?.pushViewController(changeLocationViewController, animated: false)
    }
}
//MARK:
extension PriceAndLoactionSelectionTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        locationView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: locationView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
}
//ReceiveLocationDelegate
extension PriceAndLoactionSelectionTableViewCell: ReceiveLocationDelegate{
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        let requestLocationInfo = ProductLocation(location: location)
        locationTextField.text = location.completeAddress
        var userInfo = [String: Any]()
        userInfo["requestLocationInfo"] = requestLocationInfo
        NotificationCenter.default.post(name: .locationSelected, object: nil, userInfo: userInfo)
    }
    
    func locationSelectionCancelled(requestLocationType: String) {}
    
}
