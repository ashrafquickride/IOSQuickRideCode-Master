//
//  InsuranceClaimViewController.swift
//  Quickride
//
//  Created by Admin on 29/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import DropDown
import ObjectMapper

class InsuranceClaimViewController : UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var insuranceClaimView: UIView!
    
    @IBOutlet weak var claimView: UIView!
    
    @IBOutlet weak var insuranceClaimTextField: UITextField!
    
    @IBOutlet weak var requestClaimBtn: UIButton!
    
    @IBOutlet weak var claimSeparationView: UIView!
    
    var insuranceClaimTypeDropDown = DropDown()
    var passengerRideId : Double?
    var riderId : Double?
    var rideId : Double?
    var dismissHandler : DialogDismissCompletionHandler?
    
    func initializeDataBeforePresenting(passengerRideId : Double?,riderId : Double?,rideId : Double?,dismissHandler : DialogDismissCompletionHandler?){
        self.passengerRideId = passengerRideId
        self.riderId = riderId
        self.rideId = rideId
        self.dismissHandler = dismissHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupClaimTypesDropDown()
        claimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InsuranceClaimViewController.claimViewTapped(_:))))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InsuranceClaimViewController.backgroundViewTapped(_:))))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ViewCustomizationUtils.addCornerRadiusToView(view: insuranceClaimView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: self.requestClaimBtn, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.requestClaimBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    
    func setupClaimTypesDropDown() {
        insuranceClaimTypeDropDown.anchorView = claimSeparationView
        insuranceClaimTypeDropDown.dataSource = Strings.insurance_claim_types
        insuranceClaimTypeDropDown.selectionAction = { [weak self] (index, item) in
            self?.insuranceClaimTextField.text = item
        }
    }
    
    @objc func claimViewTapped(_ gesture : UITapGestureRecognizer){
        insuranceClaimTypeDropDown.show()
    }
    
    
    @IBAction func requestClaimClicked(_ sender: Any) {
        
        if insuranceClaimTextField.text == nil || insuranceClaimTextField.text!.isEmpty{
            MessageDisplay.displayAlert(messageString: Strings.select_claim_type, viewController: self, handler: nil)
            return
        }
        
        
        
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.claimRideInsurance(userId: QRSessionManager.getInstance()?.getUserId(), passengerRideId: passengerRideId, riderId: riderId, rideId: rideId, claimType: NomineeDetails.insuranceClaimTypeValues[insuranceClaimTextField.text!]!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.dismissHandler?()
                self.view.removeFromSuperview()
                self.removeFromParent()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
       self.view.removeFromSuperview()
       self.removeFromParent()
    }
    
}
