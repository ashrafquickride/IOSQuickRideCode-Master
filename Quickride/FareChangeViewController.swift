//
//  FareChangeViewController.swift
//  Quickride
//
//  Created by KNM Rao on 16/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import BottomPopup
typealias FareChangeClosure = (_ actualFare : Double,_ requestedFare : Double) -> Void

class FareChangeViewController : BottomPopupViewController, UITextFieldDelegate{

    @IBOutlet var fareChangeView: UIView!
    @IBOutlet var newFareTextField: UITextField!
    @IBOutlet weak var positiveActnBtn: UIButton!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var fareChangeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    var isKeyBoardVisible = false
    var actualFare : Double?
    var fareChangeClosure : FareChangeClosure?
    var distance : Double?
    var noOfSeats : Int = 1
    var recommededFare : Double?
    var rideType : String?
    var farePerKm : Double?

    func initializeDataBeforePresenting(rideType : String,actualFare : Double,distance : Double,selectedSeats :Int,farePerKm : Double?,fareChangeClosure : @escaping FareChangeClosure){
        self.actualFare  = actualFare
        self.fareChangeClosure = fareChangeClosure
        self.distance = distance
        self.noOfSeats = selectedSeats
        self.rideType = rideType
        self.farePerKm = farePerKm
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if rideType == Ride.PASSENGER_RIDE{
            recommededFare = round(FareChangeUtils.getMinAmountThatCanReqstdForFareChangeForDistance(points: actualFare!, minPercent: clientConfiguration!.minPercentToRequestForFareChange, distance: distance!, minFare: clientConfiguration!.minFareToRequestForFareChange,noOfSeats: self.noOfSeats,maxPoints: clientConfiguration!.minFareToConsiderFareChangeAlways))
            infoLabel.text = Strings.carpool_points_negotiation_info_rider
        }else{
            recommededFare = FareChangeUtils.getMaxAmountThatCanReqstdForFareChangeForDistance(points: actualFare!,distance: distance!, maxFare: clientConfiguration!.vehicleMaxFare,noOfSeats: self.noOfSeats, rideFarePerKm: farePerKm ?? 0.0)
            infoLabel.text = Strings.carpool_points_negotiation_info_passenger
        }
        newFareTextField.text = StringUtils.getStringFromDouble(decimalNumber: ceil(actualFare ?? 0))
        newFareTextField.delegate = self
        ViewCustomizationUtils.addCornerRadiusToView(view: fareChangeView, cornerRadius: 5.0)
        positiveActnBtn.backgroundColor = Colors.mainButtonColor
        NotificationCenter.default.addObserver(self, selector: #selector(FareChangeViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FareChangeViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        updatePopupHeight(to: 280)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]

        textField.inputAccessoryView = keyToolBar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return false
    }

    @IBAction func confirmAction(_ sender: Any) {
        self.view.endEditing(false)
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if newFareTextField.text == nil || newFareTextField.text!.isEmpty {
            UIApplication.shared.keyWindow?.makeToast( Strings.new_fare_can_not_be_empty)
            return
        }

        if NumberUtils.validateTextFieldForSpecialCharacters(textField: newFareTextField, viewController: self){
            return
        }

        if rideType == Ride.PASSENGER_RIDE{
            let maxFare = FareChangeUtils.getMaxAmountThatCanReqstdForFareChangeForDistance(points: actualFare!,distance: distance!, maxFare: clientConfiguration!.vehicleMaxFare,noOfSeats: self.noOfSeats, rideFarePerKm: farePerKm ?? 0.0)

            if Int(recommededFare!) > Int(newFareTextField.text!)!{
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.new_fare_should_not_be_less_than, StringUtils.getStringFromDouble(decimalNumber : recommededFare)))
                positiveActnBtn.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.positiveActnBtn.isUserInteractionEnabled = true
                }
                return
            }
            if Int(maxFare) < Int(newFareTextField.text!)!{
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.new_fare_should_not_be_more_than, StringUtils.getStringFromDouble(decimalNumber : maxFare)))
                positiveActnBtn.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.positiveActnBtn.isUserInteractionEnabled = true
                }
                return
            }
        }else{

            if Int(newFareTextField.text!)! < clientConfiguration!.minPointsForARide{
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.new_fare_should_not_be_less_than, String(clientConfiguration!.minPointsForARide)))
                positiveActnBtn.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.positiveActnBtn.isUserInteractionEnabled = true
                }
                return
            }
            if Int(recommededFare!) < Int(newFareTextField.text!)!{
                UIApplication.shared.keyWindow?.makeToast( String(format: Strings.new_fare_should_not_be_more_than, StringUtils.getStringFromDouble(decimalNumber : recommededFare)))
                positiveActnBtn.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.positiveActnBtn.isUserInteractionEnabled = true
                }
                return
            }
        }
        self.dismiss(animated: false, completion: nil)
        fareChangeClosure?(actualFare!,Double(newFareTextField.text!)!)

    }
    
    @IBAction func incrementButtonTapped(_ sender: Any) {
        guard let valueStr = newFareTextField.text else { return }
        let value = Int(valueStr)
        guard var verifiedValue = value else { return }
        verifiedValue = verifiedValue + 1
        newFareTextField.text = String(verifiedValue)
    }
    
    @IBAction func decrementButtonTapped(_ sender: Any) {
        guard let valueStr = newFareTextField.text else { return }
        let value = Int(valueStr)
        guard var verifiedValue = value, verifiedValue > 0 else { return }
        verifiedValue = verifiedValue - 1
        newFareTextField.text = String(verifiedValue)
    }
    
    @IBAction func fareChangeButtonTapped(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 570)
        }else {
            updatePopupHeight(to: 510)
        }
        newFareTextField.becomeFirstResponder()
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        fareChangeButton.isHidden = true
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        updatePopupHeight(to: 280)
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        fareChangeButton.isHidden = false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == newFareTextField{
            threshold = 7
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
