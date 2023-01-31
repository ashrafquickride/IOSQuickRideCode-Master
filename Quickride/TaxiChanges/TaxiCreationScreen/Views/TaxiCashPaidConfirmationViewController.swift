//
//  TaxiCashPaidConfirmationViewController.swift
//  Quickride
//
//  Created by Rajesab on 17/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

public typealias paymentComplitionHandler = (_ result: Bool) -> Void

class TaxiCashPaidConfirmationViewController: UIViewController {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var farePaidConfirmationMessageLabel: UILabel!
    
    var pendingFare: Double?
    var complition: paymentComplitionHandler?
    
    func initialiseData(pendingFare: Double?, complition: @escaping paymentComplitionHandler){
        self.pendingFare = pendingFare
        self.complition = complition
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pendingFare = pendingFare {
            farePaidConfirmationMessageLabel.text = String(format: Strings.taxi_pending_amount_pay_message, arguments: [String(pendingFare)])
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
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
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        if let complition = complition{
            complition(true)
        }
        closeView()
    }
    
    @IBAction func notPaidTapped(_ sender: Any) {
        closeView()
    }
}
