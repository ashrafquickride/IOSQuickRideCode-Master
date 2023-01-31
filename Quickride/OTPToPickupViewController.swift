//
//  OTPToPickupViewController.swift
//  Quickride
//
//  Created by Vinutha on 29/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Lottie

protocol PassengerPickupWithOtpDelegate {
    func passengerPickedUpWithOtp(riderRideId : Double, userId: Double)
    func passengerNotPickedUp(userId: Double)
}

class OTPToPickupViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet var backGroundView: UIView!
    @IBOutlet var pickupView: UIView!
    @IBOutlet var otpView: UIView!
    @IBOutlet var successView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var otpSharedWithLabel: UIView!
    @IBOutlet var otpTextField1: UITextField!
    @IBOutlet var otpTextField2: UITextField!
    @IBOutlet var otpTextField3: UITextField!
    @IBOutlet var otpTextField4: UITextField!
    @IBOutlet var otpFailedLabel: UILabel!
    @IBOutlet var animationView: AnimationView!
    @IBOutlet var pickupButton: UIButton!
    @IBOutlet var goBackButton: UIButton!
    
    //MARK: Properties
    private var otpToPickupViewModel = OTPToPickupViewModel()
    private var passengerPickupDelegate : PassengerPickupWithOtpDelegate?

    //MARK: Initializer
    func initializeData(rideParticipant: RideParticipant?, riderRideId: Double, isFromMultiPickup: Bool, passengerPickupDelegate : PassengerPickupWithOtpDelegate?) {
        otpToPickupViewModel.initializeData(rideParticipant: rideParticipant, riderRideId: riderRideId, isFromMultiPickup: isFromMultiPickup, rideUpdateDelegate: self)
        self.passengerPickupDelegate = passengerPickupDelegate
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        addTargetToTextFields()
        handlePickupButton()
    }

    //MARK: Methods
    private func animateView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                   animations: { [weak self] in
                    guard let self = `self` else {return}
                    self.pickupView.center.y -= self.pickupView.bounds.height
        }, completion: nil)
    }
    
    private func addTargetToTextFields() {
        otpFailedLabel.isHidden = true
        if otpToPickupViewModel.isFromMultiPickup {
            goBackButton.isHidden = false
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        otpTextField1.delegate = self
        otpTextField2.delegate = self
        otpTextField3.delegate = self
        otpTextField4.delegate = self
        otpTextField1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField3.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField4.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField1, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField2, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField3, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField4, cornerRadius: 5.0)
    }
    
    @objc func textFieldDidChange(textField : UITextField) {
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case otpTextField1:
                handlePickupButton()
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                handlePickupButton()
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                handlePickupButton()
                otpTextField4.becomeFirstResponder()
            case otpTextField4:
                handlePickupButton()
                otpTextField4.resignFirstResponder()
            default:
                break
            }
            
        }else{
            switch textField {
            case otpTextField4:
                handlePickupButton()
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                handlePickupButton()
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                handlePickupButton()
                otpTextField1.becomeFirstResponder()
            case otpTextField1:
                handlePickupButton()
                otpTextField1.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    private func handlePickupButton() {
        if otpTextField1.text == nil || otpTextField1.text!.isEmpty || otpTextField2 == nil || otpTextField2.text!.isEmpty || otpTextField3 == nil || otpTextField3.text!.isEmpty || otpTextField4 == nil || otpTextField4.text!.isEmpty {
            pickupButton.isUserInteractionEnabled = false
            CustomExtensionUtility.changeBtnColor(sender: pickupButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        } else {
            pickupButton.isUserInteractionEnabled = true
            CustomExtensionUtility.changeBtnColor(sender: pickupButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        }
        
    }
    
    private func verifyOTP() {
        if otpTextField1.text == nil || otpTextField1.text!.isEmpty || otpTextField2 == nil || otpTextField2.text!.isEmpty || otpTextField3 == nil || otpTextField3.text!.isEmpty || otpTextField4 == nil || otpTextField4.text!.isEmpty
        {
            MessageDisplay.displayAlert(messageString: Strings.verification_code,  viewController: self,handler: nil)
            return
        }
        let otpText = otpTextField1.text! + otpTextField2.text! + otpTextField3.text! + otpTextField4.text!
        otpView.isHidden = true
        otpFailedLabel.isHidden = true
        successView.isHidden = false
        statusLabel.text = "Verifying OTP"
        animationView.isHidden = false
        animationView.animation = Animation.named("loading_otp")
        animationView.loopMode = .loop
        animationView.play()
        otpToPickupViewModel.updatePassengerRide(otp: otpText, viewController: self)
    }
    
    @objc private func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.pickupView.center.y += self.pickupView.bounds.height
            self.pickupView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    //MARK: Actions
    @IBAction func pickupButtonTapped(_ sender: UIButton) {
        verifyOTP()
    }
    
    @IBAction func goBackButtonTapped(_ sender: UIButton) {
        removeView()
        passengerPickupDelegate?.passengerNotPickedUp(userId: otpToPickupViewModel.rideParticipant?.userId ?? 0)
    }
}

extension OTPToPickupViewController: RideUpdateDelegate {
    func rideUpdatedSucceded() {
        otpView.isHidden = true
        otpFailedLabel.isHidden = true
        successView.isHidden = false
        statusLabel.text = "Ride Taker Picked Up"
        animationView.isHidden = false
        animationView.animation = Animation.named("signup_congrats")
        animationView.loopMode = .loop
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.removeView()
            self.passengerPickupDelegate?.passengerPickedUpWithOtp(riderRideId: self.otpToPickupViewModel.rideParticipant?.riderRideId ?? 0, userId: self.otpToPickupViewModel.rideParticipant?.userId ?? 0)
        })
    }
    
    func rideUpdatedFailed(_ responseObject: NSDictionary?, _ error: NSError?) {
        otpView.isHidden = false
        successView.isHidden = true
        otpFailedLabel.isHidden = false
        animationView.isHidden = true
        pickupButton.isHidden = false
        animationView.stop()
        otpTextField1.text = ""
        otpTextField2.text = ""
        otpTextField3.text = ""
        otpTextField4.text = ""
        handlePickupButton()
        if let responseObject = responseObject, let responseError = Mapper<ResponseError>().map(JSONObject: responseObject["resultData"]) {
            if responseError.errorCode == RideValidationUtils.RIDER_PICKED_UP_ERROR {
                otpFailedLabel.text = String(format: Strings.rider_picked_up_error, arguments: [otpToPickupViewModel.rideParticipant?.name ?? "", otpToPickupViewModel.rideParticipant?.name ?? ""])
            } else {
                otpFailedLabel.text = ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError)
            }
        } else {
            otpFailedLabel.text = "OTP verification failed, Please try again"
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
}
extension OTPToPickupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let threshold = 1
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold
    }
}
