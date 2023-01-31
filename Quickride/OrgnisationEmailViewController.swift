//
//  OrgnisationEmailViewController.swift
//  Quickride
//
//  Created by Halesh on 31/03/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import TransitionButton


class OrgnisationEmailViewController: UIViewController {
    
    //MARK:Outlets
    @IBOutlet weak var backgroundView: UIView!    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpUI()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
    }
    
    private func SetUpUI(){
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backGroundViewTapped(_:))))
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
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
