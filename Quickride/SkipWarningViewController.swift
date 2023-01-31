//
//  SkipWarningViewController.swift
//  Quickride
//
//  Created by Admin on 27/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class SkipWarningViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var dontSkipBtn: UIButton!
    
    var isFromSignUpFlow = true
    
    func initialiseData(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        animateUI()
    }
    
    //MARK: Methods
    private func setUpUI() {
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 15.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: dontSkipBtn, cornerRadius: 5.0)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:))))
    }
    
    private func animateUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: {
                        self.alertView.frame = CGRect(x: 0, y: -300, width: self.alertView.frame.width, height: self.alertView.frame.height)
                        self.alertView.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func backgroundViewTapped(_ gesture: UITapGestureRecognizer) {
       closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.alertView.center.y += self.alertView.bounds.height
            self.alertView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    //MARK: Actions
    @IBAction func dontSkipBtnClicked(_ sender: Any) {
        closeView()
    }
    
    @IBAction func skipAnywaysBtnClicked(_ sender: Any) {
        let addProfileScreen = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProfilePictureViewController") as! AddProfilePictureViewController
        self.navigationController?.pushViewController(addProfileScreen, animated: false)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.SIGN_UP_SKIPPED, params: ["UserID" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
    }
}
