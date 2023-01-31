//
//  AppStoreRatingViewController.swift
//  Quickride
//
//  Created by Ashutos on 30/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol AppStoreRatingViewControllerDelegate: class {
    func rateUsInAppStoreClicked()
    func supportEmailClicked()
}

class AppStoreRatingViewController: UIViewController {
    
    // MARK: OUTLETS
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var enjoyingQuickrideAskingView: UIView!
    @IBOutlet weak var goodTimeView: UIView!
    @IBOutlet weak var appstoreRatingGivingView: UIView!
    
    @IBOutlet weak var rateUsOrUnhappyButton: UIButton!
    @IBOutlet weak var unHappyImageView: UIImageView!
    @IBOutlet weak var happyImageView: UIImageView!
    @IBOutlet weak var happyUnhappyShowingLabel: UILabel!
    @IBOutlet weak var messageShowingLabel: UILabel!
    
    //MARK: Variables
    private var appStoreRatingViewModel = AppStoreRatingViewModel()
    private var viewNeedToShow =  UIView()
    weak var delegate: AppStoreRatingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func initialiseView(status: Int) {
        appStoreRatingViewModel.viewShowingStatus = status
    }
    
    private func setUpUI() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backGroundViewTapped(_:))))
        if appStoreRatingViewModel.viewShowingStatus == 1 {
            appstoreRatingGivingView.isHidden = true
            goodTimeView.isHidden = true
            viewNeedToShow = enjoyingQuickrideAskingView
        } else {
            appstoreRatingGivingView.isHidden = true
            enjoyingQuickrideAskingView.isHidden = true
            viewNeedToShow = goodTimeView
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.viewNeedToShow.center.y -= self.viewNeedToShow.bounds.height
            }, completion: nil)
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if viewNeedToShow != enjoyingQuickrideAskingView {
            appStoreRatingViewModel.setSkipDate()
        }
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.viewNeedToShow.center.y += self.viewNeedToShow.bounds.height
            self.viewNeedToShow.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    //MARK: Action
    
    @IBAction func notHappyButtonpressed(_ sender: UIButton) {
        appStoreRatingViewModel.setPopShowingDate()
        setDataToView(status: false)
    }
    
    @IBAction func happyBtnPressed(_ sender: UIButton) {
        appStoreRatingViewModel.setPopShowingDate()
        if appStoreRatingViewModel.getAppStoreRatingShownDateStatus() {
            appStoreRatingViewModel.setAppStoreRatingShownDate()
            setDataToView(status: true)
        } else {
            UIApplication.shared.keyWindow?.makeToast( Strings.glad_you_like_it)
            removeView()
        }
    }
    @IBAction func rateUsBtnPressed(_ sender: UIButton) {
        removeView()
        if sender.titleLabel?.text == Strings.rate_us_in_appstore {
            delegate?.rateUsInAppStoreClicked()
        } else {
            delegate?.supportEmailClicked()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        appStoreRatingViewModel.setSkipDate()
        removeView()
    }
    
    private func setDataToView(status: Bool) {
        if status {
            happyImageView.image = UIImage(named: "happy_active")
            unHappyImageView.image = UIImage(named: "sad_inactive")
            happyUnhappyShowingLabel.text = Strings.happy_selected_text
            messageShowingLabel.text = Strings.valuable_review
            happyUnhappyShowingLabel.textColor = UIColor.init(netHex: 0x19AC4A)
            rateUsOrUnhappyButton.setTitle(Strings.rate_us_in_appstore, for: .normal)
        } else {
            happyImageView.image = UIImage(named: "happy_inactive")
            unHappyImageView.image = UIImage(named: "sad_active")
            happyUnhappyShowingLabel.text = Strings.not_really
            messageShowingLabel.text = Strings.regret_to_hear
            happyUnhappyShowingLabel.textColor = UIColor.init(netHex: 0xFD5D5D)
            rateUsOrUnhappyButton.setTitle(Strings.what_went_wrong, for: .normal)
        }
        enjoyingQuickrideAskingView.isHidden = true
        appstoreRatingGivingView.isHidden = false
    }
}
