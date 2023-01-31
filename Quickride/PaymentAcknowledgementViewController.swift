//
//  PaymentAcknowledgementViewController.swift
//  Quickride
//
//  Created by Vinutha on 11/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

public typealias paymentActionCompletionHandler = (_ result : String?) -> Void

class PaymentAcknowledgementViewController: UIViewController {
    
    //MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var successOrFailureInfoLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var upiIdLabel: UILabel!
    @IBOutlet weak var taxiTripCompleted: UILabel!
    
    //MARK: properties
    private var paymentAckowledgementViewModel: PaymentAckowledgementViewModel?
    private var countdownTimer: Timer!
    private var totalTime = 0
    private var timeLeft = 60*5
    
    //MARK: initializer
    func initializeData(orderId: String, rideId: Double?,isFromTaxi: Bool,amount: Double, actionCompletionHandler: paymentActionCompletionHandler?) {
        paymentAckowledgementViewModel = PaymentAckowledgementViewModel()
        paymentAckowledgementViewModel?.setData(orderId: orderId, rideId: rideId,isFromTaxi: isFromTaxi,amount: amount,actionCompletionHandler: actionCompletionHandler)
    }
    
    //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentAckowledgementViewModel?.paymentStatusDelegate = self
        paymentAckowledgementViewModel?.cancelPaymentDelegate = self
        UserDataCache.getInstance()?.addLinkedWalletTransactionStatusListener(linkedWalletTransactionStatusListener: self)
        NotificationCenter.default.addObserver(self, selector: #selector(checkPaymentStatus), name: Notification.Name.init(PaymentAckowledgementViewModel.PAYMENT_STATUS), object: nil)
        if paymentAckowledgementViewModel?.isFromTaxi ?? false{
            taxiTripCompleted.isHidden = false
        }else{
            taxiTripCompleted.isHidden = true
        }
        upiIdLabel.text = "UPI - \(UserDataCache.getInstance()?.getDefaultLinkedWallet()?.token ?? "")"
        if let amount = paymentAckowledgementViewModel?.amount{
            amountLabel.text = "₹\(amount) - Payment request sent"
        }
        startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        UserDataCache.getInstance()?.removeLinkedWalletTransactionStatusListener()
    }
    
    //MARK: methods
    private func addAnimatedView(){
        timerLabel.isHidden = true
        minutesLabel.isHidden = true
        imageView.isHidden = true
        animationView.isHidden = false
        animationView.animation = Animation.named("signup_congrats")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()
    }
    
    private func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func checkPaymentStatus() {
        self.paymentAckowledgementViewModel?.checkPaymentStatus()
    }
    @objc private func updateTime() {
        timerLabel.text = "\(timeFormatted(timeLeft))"
        totalTime += 1
        if totalTime.isMultiple(of: 30) {
            self.paymentAckowledgementViewModel?.checkPaymentStatus()
        }
        if timeLeft != 0 {
            timeLeft -= 1
        } else {
            endTimer()
        }
    }
    
    private func endTimer() {
        imageView.isHidden = false
        imageView.image = UIImage(named: "Red_Exclamation_Dot")
        successOrFailureInfoLabel.text = Strings.transaction_unsuccess
        popViewController(status: Strings.failed)
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func popViewController(status: String) {
        invalidateTimerAndRemoveObserver()
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0 , execute: {
            self.animationView.stop()
            self.navigationController?.popViewController(animated: false)
            self.paymentAckowledgementViewModel?.actionCompletionHandler?(status)
        })
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(PaymentAckowledgementViewModel.PAYMENT_STATUS), object: nil)
    }
    
    private func invalidateTimerAndRemoveObserver() {
        timerLabel.isHidden = true
        minutesLabel.isHidden = true
        if countdownTimer != nil {
            countdownTimer.invalidate()
            countdownTimer = nil
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(PaymentAckowledgementViewModel.PAYMENT_STATUS), object: nil)
    }
  
    //MARK: actions
    @IBAction func cancelPaymentTapped(_ sender: UIButton) {
        paymentAckowledgementViewModel?.cancelPayment()
    }
}

extension PaymentAcknowledgementViewController: cancelPaymentResponseActionDelegate, LinkedWalletTransactionStatusReceiver, paymentStatusResponseActionDelegate{
    
    func cancelPaymentSucceeded() {
        invalidateTimerAndRemoveObserver()
        UIApplication.shared.keyWindow?.makeToast( Strings.transaction_cancelled)
        self.navigationController?.popViewController(animated: false)
        self.paymentAckowledgementViewModel?.actionCompletionHandler?(Strings.failed)
    }
    
    func linkedWalletTransactionStatusUpdated(linkedWalletTransactionStatus: LinkedWalletTransactionStatus) {
        if linkedWalletTransactionStatus.status == LinkedWalletTransactionStatus.LINKED_WALLLET_TRANSACTION_RESERVE && paymentAckowledgementViewModel?.orderId == linkedWalletTransactionStatus.transactionId {
            successOrFailureInfoLabel.text = Strings.payment_success
            addAnimatedView()
            popViewController(status: Strings.success)
        }
    }
    
    func paymentSucceeded() {
        popViewController(status: Strings.success)
        successOrFailureInfoLabel.text = Strings.payment_success
        addAnimatedView()
        popViewController(status: Strings.success)
    }
}
