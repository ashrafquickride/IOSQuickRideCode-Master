//
//  UPIPaymentInitiationViewController.swift
//  Quickride
//
//  Created by Vinutha on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class UPIPaymentInitiationViewController: UIViewController {

    //MARK: outlets
    @IBOutlet weak var ridePointsLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var paymentSelectionView: UIView!
    @IBOutlet weak var UPIAdressTextField: UITextField!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var totalRidePointsKeyLabel: UILabel!
    @IBOutlet weak var totalRidePointsValueLabel: UILabel!
    @IBOutlet weak var previousRidePointsKeyLabel: UILabel!
    @IBOutlet weak var previousRidePointsValueLabel: UILabel!
    @IBOutlet weak var offerPointsKeyLabel: UILabel!
    @IBOutlet weak var offerPointsValueLabel: UILabel!
    @IBOutlet weak var amountToPayKeyLabel: UILabel!
    @IBOutlet weak var amountToPayValueLabel: UILabel!
    @IBOutlet weak var totalRidePointsView: UIView!
    @IBOutlet weak var previousRidePointsView: UIView!
    @IBOutlet weak var offerPointsView: UIView!
    @IBOutlet weak var amountToPayView: UIView!
    @IBOutlet weak var pointsStackView: UIStackView!
    @IBOutlet weak var insurancePointsView: UIView!
    @IBOutlet weak var insurancePointsKeyLabel: UILabel!
    @IBOutlet weak var insurancePointsValueLabel: UILabel!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    //MARK: properties
    private var upiPaymemtInitiationViewModel: UPIPaymemtInitiationViewModel?
    private var isArrowTapped = false
    private var isKeyBoardVisible = false
    
    //Initializer
    func initializeData(paymentInfo: [String: Any], rideId: Double?, actionCompletionHandler: paymentActionCompletionHandler?) {
        upiPaymemtInitiationViewModel = UPIPaymemtInitiationViewModel(paymentInfo: paymentInfo, rideId: rideId, actionCompletionHandler: actionCompletionHandler)
    }
    //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UPIPaymentInitiationViewController.backGroundViewTapped(_:))))
        upiPaymemtInitiationViewModel?.upiPaymemtInitiationViewModelDelegate = self
        updateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    //MARK: methods
    func updateUI() {
        if let vpaAddress = upiPaymemtInitiationViewModel?.getDefaultLinkedWallet()?.token {
            UPIAdressTextField.text = vpaAddress
        }
        if let paymentInfo = upiPaymemtInitiationViewModel?.paymentInfo {
            let allKeys = paymentInfo.keys
            for key in allKeys {
                switch key {
                case ResponseError.TOTAL_RIDE_POINTS:
                    totalRidePointsKeyLabel.text = Strings.ride_points
                    if let totalPoints = paymentInfo[key] as? Double, totalPoints != 0 {
                        totalRidePointsView.isHidden = false
                        totalRidePointsValueLabel.text = StringUtils.getPointsInDecimal(points: totalPoints)
                    }
                    break
                case ResponseError.PAID_POINTS:
                    previousRidePointsKeyLabel.text = Strings.paid_points
                    if let previousRidePoints = paymentInfo[key] as? Double, previousRidePoints != 0 {
                        previousRidePointsView.isHidden = false
                        previousRidePointsValueLabel.text = StringUtils.getPointsInDecimal(points: previousRidePoints)
                    }
                    break
                case ResponseError.DISCOUNT_POINTS:
                    offerPointsKeyLabel.text = Strings.discount_points
                    if let offerPoints = paymentInfo[key] as? Double, offerPoints != 0 {
                        offerPointsView.isHidden = false
                        offerPointsValueLabel.text = StringUtils.getPointsInDecimal(points: offerPoints)
                    }
                    break
                case ResponseError.TOTAL_PENDING:
                    amountToPayKeyLabel.text = Strings.total_amount_to_pay
                    if let totalAmountToPay = paymentInfo[key] as? Double, totalAmountToPay != 0 {
                        amountToPayView.isHidden = false
                        amountToPayValueLabel.text = StringUtils.getPointsInDecimal(points: totalAmountToPay)
                        ridePointsLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getPointsInDecimal(points: totalAmountToPay)])
                    }
                    break
                case ResponseError.INSURANCE_POINTS:
                    insurancePointsKeyLabel.text = Strings.insurance_points
                    if let insurancePoints = paymentInfo[key] as? Double, insurancePoints != 0 {
                        insurancePointsView.isHidden = false
                        insurancePointsValueLabel.text = StringUtils.getPointsInDecimal(points: insurancePoints)
                    }
                    break
                default:
                    pointsStackView.isHidden = true
                    break
                }
            }
        }
        if let amountToPay = amountToPayValueLabel.text, let totalRidePoints = totalRidePointsValueLabel.text, Int(amountToPay) == Int(totalRidePoints), (insurancePointsValueLabel.text == nil || insurancePointsValueLabel.text!.isEmpty) {
            pointsStackView.isHidden = true
            arrowButton.isHidden = true
        }
    }
    
    private func showPaymentAcknowledgementView(orderId: String){
        let paymentAcknowledgementViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard,bundle: nil).instantiateViewController(withIdentifier: "PaymentRequestLoaderViewController") as! PaymentAcknowledgementViewController
        paymentAcknowledgementViewController.initializeData(orderId: orderId, rideId: upiPaymemtInitiationViewModel?.rideId,isFromTaxi: false,amount: Double(amountToPayValueLabel.text ?? "") ?? 0, actionCompletionHandler: upiPaymemtInitiationViewModel?.actionCompletionHandler)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: paymentAcknowledgementViewController, animated: false)
        removeCurrentView()
    }
    
    func removeCurrentView() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        upiPaymemtInitiationViewModel?.actionCompletionHandler?(Strings.dismissed)
        removeCurrentView()
    }
    
    //MARK: actions
    @IBAction func payNowButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        if let upiId = UPIAdressTextField.text,!upiId.isEmpty{
            if upiId != UserDataCache.getInstance()?.getDefaultLinkedWallet()?.token{
                let UPIType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type
                if UPIType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
                    let upiId = upiId.components(separatedBy: "@")
                    if upiId.count > 1 && !AccountUtils().isValidGpayUPIId(upiId: upiId[1]){
                        MessageDisplay.displayAlert( messageString: Strings.enter_valid_gpay_id, viewController: self,handler: nil)
                        return
                    }
                }
                QuickRideProgressSpinner.startSpinner()
                upiPaymemtInitiationViewModel!.updateUPIId(upiId: upiId){ (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject == nil && error == nil{
                        self.upiPaymemtInitiationViewModel!.initiateUPIPayment(amount: self.amountToPayValueLabel.text)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                }
            }else{
                upiPaymemtInitiationViewModel!.initiateUPIPayment(amount: amountToPayValueLabel.text)
            }
        }else{
            UIApplication.shared.keyWindow?.makeToast("Enter valid UPI ID")
        }
    }
    
    @IBAction func arrowButtonTapped(_ sender: Any) {
        if isArrowTapped {
            isArrowTapped = !isArrowTapped
            pointsStackView.isHidden = true
        } else {
            isArrowTapped = !isArrowTapped
            pointsStackView.isHidden = false
        }
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        if isKeyBoardVisible == true{
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 20
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        if isKeyBoardVisible == false{
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 50
    }
    
}

extension UPIPaymentInitiationViewController: upiPaymemtInitiationViewModelDelegate {
    func onSucess(orderId: String) {
        self.showPaymentAcknowledgementView(orderId: orderId)
    }
}
