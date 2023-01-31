//
//  TaxiExtraChargesInfoViewController.swift
//  Quickride
//
//  Created by Rajesab on 25/03/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiExtraChargesInfoViewController: UIViewController {
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tollIncludedView: UIView!
    @IBOutlet weak var tollIncludedViewHeightConstraint: NSLayoutConstraint!
    
    var isTollIncluded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        if let isTollIncluded = isTollIncluded, isTollIncluded {
            tollIncludedView.isHidden = false
            tollIncludedViewHeightConstraint.constant = 45
        } else{
            tollIncludedView.isHidden = true
            tollIncludedViewHeightConstraint.constant = 0
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(RentalRulesAndRestrictionsViewController.backGroundViewTapped(_:))))
    }
     
    func initialissData(isTollIncluded: Bool?){
        self.isTollIncluded = isTollIncluded
    }
    
    @objc func backGroundViewTapped(_ gesture: UITapGestureRecognizer){
        self.closeView()
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        closeView()
    }
    
}
