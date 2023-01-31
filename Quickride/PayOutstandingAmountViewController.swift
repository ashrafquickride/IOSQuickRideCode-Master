//
//  PayOutstandingAmountViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 26/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
typealias pendingAmountComplitionHandler = (_ amount: Double) -> Void

class PayOutstandingAmountViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var payButton: QRCustomButton!
    @IBOutlet weak var extraDaysView: UIView!
    @IBOutlet weak var extraDayLabel: UILabel!
    @IBOutlet weak var unPaidRentView: UIView!
    @IBOutlet weak var extraDaysRentLabel: UILabel!
    @IBOutlet weak var extraRentTextLabel: UILabel!
    @IBOutlet weak var damageView: UIView!
    @IBOutlet weak var damgeAmountLabel: UILabel!
    @IBOutlet weak var failedAmountView: UIView!
    @IBOutlet weak var failedTypeTextLabel: UILabel!
    @IBOutlet weak var failedAmountLabel: UILabel!
    
    private var handler: pendingAmountComplitionHandler?
    private var failedAmount = 0.0
    private var failedType: String?
    private var damageAmount:Double?
    private var extraRent:Double?
    private var extraDays = 0
    private var perDayRent = 0
    
    func initialiseOutstandingAmount(failedAmount: Double,failedType: String?,damageAmount: Double?,extraRent: Double?,extraDays: Int,perDayRent: Int,handler: @escaping pendingAmountComplitionHandler){
        self.handler = handler
        self.failedAmount = failedAmount
        self.failedType = failedType
        self.extraRent = extraRent
        self.damageAmount = damageAmount
        self.extraDays = extraDays
        self.perDayRent = perDayRent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        showPendingAmounts()
    }
    private func showPendingAmounts(){
        if let type = failedType{
            failedAmountView.isHidden = false
            failedAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(failedAmount)])
            switch type {
            case OrderPayment.BOOKING:
                failedTypeTextLabel.text = Strings.advance_text
            case OrderPayment.FINAL:
                failedTypeTextLabel.text = Strings.sellingPrice
            case OrderPayment.RENT:
                failedTypeTextLabel.text = Strings.rent_amount
            default:
                break
            }
        }else{
            failedAmountView.isHidden = true
        }
        if let amount = damageAmount{
            damageView.isHidden = false
            damgeAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(amount)])
        }else{
            damageView.isHidden = true
        }
        if let rent = extraRent{
            extraDaysView.isHidden = false
            unPaidRentView.isHidden = false
            extraDayLabel.text = String(extraDays)
            extraRentTextLabel.text = String(format: Strings.unpaid_amount, arguments: [String(perDayRent),String(extraDays)])
            extraDaysRentLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(extraDays*perDayRent)])
        }else{
            extraDaysView.isHidden = true
            unPaidRentView.isHidden = true
        }
        let total = (failedAmount) + (damageAmount ?? 0) + (extraRent ?? 0)
        payButton.setTitle(String(format: Strings.pay_amount, arguments: [String(total)]), for: .normal)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
        let total = (failedAmount) + (damageAmount ?? 0) + (extraRent ?? 0)
        handler?(total)
        closeView()
    }
}
