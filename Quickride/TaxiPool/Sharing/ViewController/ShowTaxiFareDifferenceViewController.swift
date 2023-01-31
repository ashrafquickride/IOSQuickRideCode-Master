//
//  ShowTaxiFareDifferenceViewController.swift
//  Quickride
//
//  Created by HK on 03/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias confirmHandler = (_ result: Bool) -> Void

class ShowTaxiFareDifferenceViewController: UIViewController {
    
    @IBOutlet weak var exclusiveAmountLabel: UILabel!
    @IBOutlet weak var sharingAmountLabel: UILabel!
    @IBOutlet weak var payableAmountLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    private var sharingAmount = 0.0
    private var exclusiveAmount = 0.0
    private var confirmHandler: confirmHandler?
    
    func showDiffrence(sharingAmount: Double,exclusiveAmount: Double,confirmHandler: @escaping confirmHandler){
        self.sharingAmount = sharingAmount
        self.exclusiveAmount = exclusiveAmount
        self.confirmHandler = confirmHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
        exclusiveAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(exclusiveAmount)])
        sharingAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(sharingAmount)])
        var difference = exclusiveAmount - sharingAmount
        payableAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(difference.roundToPlaces(places: 1))])
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        confirmHandler?(false)
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
        confirmHandler?(true)
        closeView()
    }
}
