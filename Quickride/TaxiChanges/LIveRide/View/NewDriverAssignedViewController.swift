//
//  DriverAssignedNewViewController.swift
//  Quickride
//
//  Created by Rajesab on 13/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class NewDriverAssignedViewController: UIViewController {
    
    @IBOutlet weak var newDriverImage: UIImageView!
    @IBOutlet weak var newDriverNameLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var taxiRideGroup: TaxiRideGroup?
    
    func initialiseData(taxiRideGroup: TaxiRideGroup?){
        self.taxiRideGroup = taxiRideGroup
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        newDriverNameLabel.text = taxiRideGroup?.driverName?.capitalized ?? ""
        ImageCache.getInstance().setImageToView(imageView: newDriverImage, imageUrl: taxiRideGroup?.driverImageURI ?? "", gender: User.USER_GENDER_MALE, imageSize: ImageCache.DIMENTION_SMALL)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.closeView()
        }
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
