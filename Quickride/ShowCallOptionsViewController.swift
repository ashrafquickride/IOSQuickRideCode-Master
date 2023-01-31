//
//  ShowCallOptionsViewController.swift
//  Quickride
//
//  Created by Ashutos on 21/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias callOptionChoosen = (_ completed : Bool) -> Void

class ShowCallOptionsViewController: UIViewController {
   
    //MARK:
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var callOptionPopUpView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var callOptionInfoLabel: UILabel!
    
    //MARK: variables
    private var isInfoShown = false
    private var handler: callOptionChoosen?
    private var name: String?
    private var isNumberMaskingEnable : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func initialiseData(name: String,handler: callOptionChoosen?) {
        self.handler = handler
        self.name = name
    }
    
    private func setUpUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.callOptionPopUpView.center.y -= self.callOptionPopUpView.bounds.height
            }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundtapped(_:))))
         nameLabel.text = String(format: Strings.calling_x, arguments: [name ?? ""])
        infoShown()
    }
    
    private func infoShown() {
        if isInfoShown {
            stackViewHeight.constant = 45
            callOptionInfoLabel.isHidden = false
        } else {
           stackViewHeight.constant = 25
           callOptionInfoLabel.isHidden = true
        }
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        if isInfoShown {
            isInfoShown = false
        } else {
            isInfoShown = true
        }
        infoShown()
    }
    
    @IBAction func virtualCallOptionPressed(_ sender: UIButton) {
        isNumberMaskingEnable = true
        updateUserSecurityPreference(status: true, receiver: self)
    }
    
    @IBAction func directCallOptionPressed(_ sender: UIButton) {
        isNumberMaskingEnable = false
        updateUserSecurityPreference(status: false, receiver: self)
    }
    
    @objc private func backgroundtapped(_ sender: UITapGestureRecognizer) {
        //TODO: hide view
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.callOptionPopUpView.center.y += self.callOptionPopUpView.bounds.height
            self.callOptionPopUpView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func updateUserSecurityPreference(status: Bool,receiver: SecurityPreferencesUpdateReceiver?) {
        var securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences()
        if securityPreferences == nil {
            securityPreferences = securityPreferences!.copy() as? SecurityPreferences
        }
        if status {
            securityPreferences?.numSafeguard = SecurityPreferences.SAFEGAURD_STATUS_VIRTUAL
        }else{
            securityPreferences?.numSafeguard = SecurityPreferences.SAFEGAURD_STATUS_DIRECT
        }
      SecurityPreferencesUpdateTask(viewController: self, securityPreferences: securityPreferences!, securityPreferencesUpdateReceiver: receiver).updateSecurityPreferences()
    }
}

extension ShowCallOptionsViewController: SecurityPreferencesUpdateReceiver {
    func securityPreferenceUpdated() {
        removeView()
        handler?(isNumberMaskingEnable ?? false)
    }
}
