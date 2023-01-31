//
//  HowItWorkPopUpForShareAndEarnViewController.swift
//  Quickride
//
//  Created by Ashutos on 07/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HowItWorkPopUpForShareAndEarnViewController: UIViewController {
    
    @IBOutlet weak var stepOneTitle: UILabel!
    
    @IBOutlet weak var stepOneDescLbl: UILabel!
    
    @IBOutlet weak var stepTwoTitle: UILabel!
    
    @IBOutlet weak var stepTwoDescLbl: UILabel!
    
    @IBOutlet weak var stepThreeTitle: UILabel!
    
    @IBOutlet weak var stepThreeDescLbl: UILabel!
    
    @IBOutlet weak var backgroundview: UIView!
    
    @IBOutlet weak var PopUpView: UIView!
    
    private var shareAndEarnOffer : ShareAndEarnOffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func initializeView(shareAndEarnOffer : ShareAndEarnOffer){
        self.shareAndEarnOffer = shareAndEarnOffer
    }
    
    private func setUpUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.PopUpView.center.y -= self.PopUpView.bounds.height
            }, completion: nil)
        ViewCustomizationUtils.addCornerRadiusToView(view: PopUpView, cornerRadius: 20)
        backgroundview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backGroundViewTapped(_:))))
        stepOneTitle.text = shareAndEarnOffer?.stepOneTitle
        stepTwoTitle.text = shareAndEarnOffer?.stepTwoTitle
        stepThreeTitle.text = shareAndEarnOffer?.stepThreeTitle
        stepOneDescLbl.text = shareAndEarnOffer?.stepOneText
        if shareAndEarnOffer?.stepTwoTitle == Strings.orgnisation_title2 || shareAndEarnOffer?.stepTwoTitle == Strings.community_title2{
            stepTwoDescLbl.attributedText = ViewCustomizationUtils.getAttributedString(string: shareAndEarnOffer!.stepTwoText, rangeofString: "sales@quickride.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 14)
        }else{
            stepTwoDescLbl.text = shareAndEarnOffer?.stepTwoText
        }
        stepThreeDescLbl.text = shareAndEarnOffer?.stepThreeText
    }
    
    @IBAction func termsAndConditionBtnPressed(_ sender: UIButton) {
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTermsAndConditionsViewController") as! ShowTermsAndConditionsViewController
        showTermsAndConditionsViewController.initializeDataBeforePresenting(termsAndConditions: shareAndEarnOffer!.termsAndCondition, titleString: Strings.terms_and_conditions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
    }
    
    @objc private func backGroundViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        removeView()
    }
    
    private func removeView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.PopUpView.center.y += self.PopUpView.bounds.height
            self.PopUpView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
