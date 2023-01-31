//
//  ShowSampleEmailViewController.swift
//  Quickride
//
//  Created by Halesh on 02/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ShowSampleEmailViewController: UIViewController {
    
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowSampleEmailViewController.backGroundTapped(_:))))
    }
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: contentView, cornerRadius: 10, corner1: .topLeft, corner2: .topRight)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        closeView() 
    }
    @objc func backGroundTapped(_ gesture : UITapGestureRecognizer){
        closeView()
    }
    func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
