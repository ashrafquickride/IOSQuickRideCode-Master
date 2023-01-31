//
//  RechargedAmountRedemedChargesDialouge.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 07/02/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import  UIKit

public typealias rechargedAmountRedemedChargesHandler = (_ result : String) -> Void

class RechargedAmountRedemedChargesDialouge : UIViewController{
    
    
    @IBOutlet weak var redemedAmount: UILabel!
    
    @IBOutlet weak var rechargedPoints: UILabel!
    
    @IBOutlet weak var paymentGatewayCharges: UILabel!
    
    @IBOutlet weak var netAmount: UILabel!
    
    @IBOutlet weak var paymentGateWayPercentages: UILabel!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var negativeButton: UIButton!
    
    @IBOutlet weak var positiveButton: UIButton!
    
    var rechargedAmount = 0
    var redemedPoints = ""
    var handler : rechargedAmountRedemedChargesHandler?

    
    func initializeDataBeforePresentingView(rechargedAmount : Int ,redemedPoints : String,viewController : UIViewController?, handler : @escaping rechargedAmountRedemedChargesHandler)
    {
        self.rechargedAmount = rechargedAmount
        self.redemedPoints = redemedPoints
        self.handler = handler
        if viewController?.navigationController != nil{
            viewController?.navigationController?.view.addSubview(self.view!)
            viewController?.navigationController?.addChild(self)
        }else{
            viewController?.view.addSubview(self.view!)
            viewController?.addChild(self)
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveButton, cornerRadius: 3.0)


    }
    
    override func viewDidLoad() {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil
        {
            clientConfiguration = ClientConfigurtion()
        }
        paymentGateWayPercentages.text = String(format: Strings.payment_gateway_charges, String(clientConfiguration!.rechargeServiceFee)+"%")
        rechargedPoints.text = ": "+String(rechargedAmount)
        redemedAmount.text = ": "+redemedPoints
        let totalnetamount = RedemptionRequest.getAmountAfterRemovingGateWayChargesForRechargePoints(points: rechargedAmount, gateWayCharges: clientConfiguration!.rechargeServiceFee)
        let serviceFeeForRechargedAmount = rechargedAmount-totalnetamount
        paymentGatewayCharges.text = ": " + String(serviceFeeForRechargedAmount)
        netAmount.text = ": "+String(Int(redemedPoints)!-serviceFeeForRechargedAmount)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        handler?(sender.titleLabel!.text!)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        handler?(sender.titleLabel!.text!)
    }
    
}
