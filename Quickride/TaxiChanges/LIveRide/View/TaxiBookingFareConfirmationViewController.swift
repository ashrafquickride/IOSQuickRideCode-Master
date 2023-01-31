//
//  TaxiBookingDetailsAndFareUpdateViewController.swift
//  Quickride
//
//  Created by Rajesab on 29/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiBookingFareConfirmationViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tripFareLabel: UILabel!
    @IBOutlet weak var confirmFareButton: QRCustomButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    var tripFare : Double?
    
    private var actionComplitionHandler: actionComplitionHandler?
    
    func initialiseData(tripFare: Double?, complition: @escaping actionComplitionHandler){
        self.tripFare = tripFare
        self.actionComplitionHandler = complition
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        tripFareLabel.text =
        
        String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: tripFare)])
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
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
        }
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }

    @IBAction func confirmFareButtonTapped(_ sender: Any) {
        actionComplitionHandler!(true)
        closeView()
    }
    @IBAction func goBackButtonTapped(_ sender: Any) {
        actionComplitionHandler!(false)
        closeView()
    }
}
