//
//  RentalTaxiStartOdometerDetailsViewController.swift
//  Quickride
//
//  Created by Rajesab on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalTaxiStartOdometerDetailsViewController: UIViewController {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var odometerReadingLabel: UILabel!
    
    var odometerReading: String?
    
    func initialiseData(odometerReading: String){
        self.odometerReading = odometerReading
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        odometerReadingLabel.text = odometerReading ?? ""
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    
    private func closeView(){
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.dismiss(animated: false, completion: nil)
        }
    }

    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
    }
    
    @IBAction func callCustomerSupportButtonTapped(_ sender: Any) {
        AppUtilConnect.callSupportNumber(phoneNumber: ConfigurationCache.getObjectClientConfiguration().quickRideSupportNumberForTaxi, targetViewController: self )
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        closeView()
    }
}
