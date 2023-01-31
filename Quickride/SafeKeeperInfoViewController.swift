//
//  SafeKeeperInfoViewController.swift
//  Quickride
//
//  Created by Vinutha on 20/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SafeKeeperInfoViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    private var name: String?
    
    //MARK: Initializer
    func initializeData(name: String?) {
        self.name = name
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        titleLabel.text = String(format: Strings.safe_keeper, arguments: [name ?? ""])
        subTitleLabel.text = String(format: Strings.has_confirmed, arguments: [name ?? ""])
    }
    
    //MARK: Methods
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    //MARK: Actions
    @IBAction func okButtonTapped(_ sender: UIButton) {
        removeView()
    }


}
