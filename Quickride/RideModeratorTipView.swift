//
//  RideModeratorTipView.swift
//  Quickride
//
//  Created by Vinutha on 07/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideModeratorTipView: UIView {
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var knowMoreButton: UIButton!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var notchImageView: UIImageView!
    
    //MARK: Properties
    var handler: alertControllerActionHandler?
    
    //MARK: Initializer
    func initializeData(message: String, firstAction: String?, secondAction: String?, x: CGFloat, y: CGFloat, viewController: UIViewController, hanlder: alertControllerActionHandler?) {
        self.nameLabel.text = message
        okButton.setTitle(firstAction, for: .normal)
        knowMoreButton.setTitle(secondAction, for: .normal)
        self.handler = hanlder
        notchImageView.image = notchImageView.image!.withRenderingMode(.alwaysTemplate)
        notchImageView.tintColor = UIColor.darkGray
        self.frame = CGRect(x: x, y: y, width: tipViewWidthConstraint.constant, height: tipView.frame.size.height)
        viewController.view.addSubview(self)
    }
    
    //MARK: Actions
    @IBAction func okActionTapped(_ sender: UIButton) {
        self.removeFromSuperview()
        handler?(okButton.titleLabel?.text ?? "")
    }
    
    @IBAction func knowMoreTapped(_ sender: UIButton) {
        
        self.removeFromSuperview()
        handler?(knowMoreButton.titleLabel?.text ?? "")
    }
}

