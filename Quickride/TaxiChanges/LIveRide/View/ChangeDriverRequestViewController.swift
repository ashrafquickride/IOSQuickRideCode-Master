//
//  ChangeDriverRequestViewController.swift
//  Quickride
//
//  Created by Rajesab on 13/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ChangeDriverRequestViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    private var changeDriverRequestViewModel = ChangeDriverRequestViewModel()
    
    func initialiseDataBfrPresentingView(taxiRidePassenger: TaxiRidePassenger?,complitionHandler: @escaping complitionHandler){
        self.changeDriverRequestViewModel = ChangeDriverRequestViewModel(taxiRidePassenger: taxiRidePassenger, complitionHandler: complitionHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @IBAction func cancelChangeDriverRequestButtonTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        changeDriverRequestViewModel.cancelRequestedChangeDriver(driverChangeReason: "", taxiGroupId: changeDriverRequestViewModel.taxiRidePassenger?.taxiGroupId ?? 0, taxiRidePassengerId: changeDriverRequestViewModel.taxiRidePassenger?.id ?? 0, customerId: changeDriverRequestViewModel.taxiRidePassenger?.userId ?? 0, status: TaxiTripChangeDriverInfo.FIELD_DRIVER_CHANGE_STATUS_CANCELLED, complition: { (result) in
                                                            QuickRideProgressSpinner.stopSpinner()
                                                                    self.closeView()
                                                                    self.changeDriverRequestViewModel.complitionHandler?(result) })
    }
    @IBAction func okGotItButtonTapped(_ sender: Any) {
        closeView()
    }
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
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
}

