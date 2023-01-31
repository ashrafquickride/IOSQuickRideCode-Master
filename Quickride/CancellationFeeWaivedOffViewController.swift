//
//  CancellationFeeWaivedOffViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancellationFeeWaivedOffViewController: UIViewController {

    
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelInfoLabel: UILabel!
    @IBOutlet weak var waivedOffImage: UIImageView!
    @IBOutlet weak var gotItButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        ViewCustomizationUtils.addBorderToView(view: gotItButton, borderWidth: 1, color: UIColor(netHex: 0x007AFF))
        gotItButton.layer.shadowColor = UIColor(netHex: 0xD0D0D0).cgColor
        gotItButton.layer.shadowOffset = CGSize(width: 0,height: 1)
        gotItButton.layer.shadowRadius = 3
        gotItButton.layer.shadowOpacity = 1
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
    
    @IBAction func cancellationPolicyTapped(_ sender: Any){
        
    }
    
    @IBAction func gotItButtonTapped(_ sender: Any){
        closeView()
    }

}
