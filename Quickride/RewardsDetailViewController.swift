//
//  RewardsDetailViewController.swift
//  Quickride
//
//  Created by Halesh on 29/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import MessageUI

class RewardsDetailViewController: UIViewController{
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var rewardImageView: UIImageView!
    
    @IBOutlet weak var referalCodeLbl: UILabel!
    
    @IBOutlet weak var referNowButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var stepOneTitle: UILabel!
    
    @IBOutlet weak var stepOneDescLbl: UILabel!
    
    @IBOutlet weak var stepTwoTitle: UILabel!
    
    @IBOutlet weak var stepTwoDescLbl: UILabel!
    
    @IBOutlet weak var stepThreeTitle: UILabel!
    
    @IBOutlet weak var stepThreeDescLbl: UILabel!
    
    @IBOutlet weak var checkSampleMailBtn: UIButton!
    
    @IBOutlet weak var referralCodeView: UIView!
    
    @IBOutlet weak var referralcodeViewHeightContsraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var buttonViewHieghtConstraints: NSLayoutConstraint!
    @IBOutlet weak var introLabel: UILabel!
    
    
    var shareAndEarnOffer : ShareAndEarnOffer?
    
    func initializeView(shareAndEarnOffer : ShareAndEarnOffer){
        self.shareAndEarnOffer = shareAndEarnOffer
    }
    override func viewDidLoad(){
        initializeViewBeforePresenting()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    func initializeViewBeforePresenting(){
        if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_ORGANIZATION{
            titleLbl.textColor = .white
            rewardImageView.backgroundColor = UIColor(netHex: 0x4d71a5)
            let attributedString = NSMutableAttributedString(string: Strings.company_referral_intro)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            introLabel.attributedText = attributedString
        }else if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_COMMUNITY{
            titleLbl.textColor = .black
            rewardImageView.backgroundColor = UIColor(netHex: 0xf2d6c8)
            let attributedString = NSMutableAttributedString(string: Strings.community_referral_intro)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            introLabel.attributedText = attributedString
        }
        titleLbl.text = shareAndEarnOffer?.title
        
        rewardImageView.image = shareAndEarnOffer?.rewardDetailIamge
        if shareAndEarnOffer!.referralCode{
            referralCodeView.isHidden = false
            referralcodeViewHeightContsraint.constant = 70
            referalCodeLbl.text = UserDataCache.getInstance()?.getReferralCode()
        }else{
            referralCodeView.isHidden = true
            referralcodeViewHeightContsraint.constant = 0
        }
        stepOneTitle.text = shareAndEarnOffer?.stepOneTitle
        stepTwoTitle.text = shareAndEarnOffer?.stepTwoTitle
        stepThreeTitle.text = shareAndEarnOffer?.stepThreeTitle
        stepOneDescLbl.text = shareAndEarnOffer?.stepOneText
        if shareAndEarnOffer?.stepTwoTitle == Strings.orgnisation_title2 || shareAndEarnOffer?.stepTwoTitle == Strings.community_title2{
            stepTwoDescLbl.attributedText = ViewCustomizationUtils.getAttributedString(string: shareAndEarnOffer!.stepTwoText, rangeofString: "sales@quickride.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 14)
            stepTwoDescLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RewardsDetailViewController.mailTapped(_:))))
        }else{
            stepTwoDescLbl.text = shareAndEarnOffer?.stepTwoText
        }
        stepThreeDescLbl.text = shareAndEarnOffer?.stepThreeText
        if shareAndEarnOffer!.sampleEmail{
            checkSampleMailBtn.isHidden = false
        }else{
            checkSampleMailBtn.isHidden = true
        }
        
        buttonView.isHidden = false
        buttonViewHieghtConstraints.constant = 75
        referNowButton.setTitle(shareAndEarnOffer?.buttonText, for: .normal)
        buttonView.addShadow()
    }
    
    override func viewDidLayoutSubviews(){
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: contentView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        ViewCustomizationUtils.addCornerRadiusToView(view: referNowButton, cornerRadius: 20)
    }
    
    @IBAction func termsAndCondiTapped(_ sender: Any) {
        let showTermsAndConditionsViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowTermsAndConditionsViewController") as! ShowTermsAndConditionsViewController
        showTermsAndConditionsViewController.initializeDataBeforePresenting(termsAndConditions: shareAndEarnOffer!.termsAndCondition, titleString: Strings.terms_and_conditions)
        ViewControllerUtils.addSubView(viewControllerToDisplay: showTermsAndConditionsViewController)
        showTermsAndConditionsViewController.view!.layoutIfNeeded()
    }
    
    @IBAction func referNowTapped(_ sender: Any) {
        if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_FRIENDS{
            InstallReferrer.prepareURLForDeepLink(referralCode:self.referalCodeLbl.text!) { (urlString)  in
                if urlString != nil{
                    self.shareReferralContext(urlString: urlString!)
                }else{
                    MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
                }
            }            
        }else{
            if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_ORGANIZATION{
                composeMail(subject: Strings.organisation_email_subject, mailBody: Strings.organisation_mail_body)
            }else if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_COMMUNITY{
                composeMail(subject: Strings.community_email_subject, mailBody: Strings.community_mail_body)
            }
        }
    }
    
    func shareReferralContext(urlString : String){
        let message = String(format: Strings.share_and_earn_msg, arguments: [self.referalCodeLbl.text!,urlString,UserDataCache.getInstance()!.userProfile!.userName!])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        self.present(avc, animated: true, completion: nil)
    }
    
    @IBAction func checkSampleEmailTapped(_ sender: Any) {
        let showSampleEmailViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowSampleEmailViewController") as! ShowSampleEmailViewController
        
        ViewControllerUtils.addSubView(viewControllerToDisplay: showSampleEmailViewController)
    }
    
    @objc func mailTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_ORGANIZATION{
            composeMail(subject: Strings.organisation_email_subject, mailBody: Strings.organisation_mail_body)
        }else if shareAndEarnOffer?.type == RewardsTermsAndConditions.REFER_COMMUNITY{
            composeMail(subject: Strings.community_email_subject, mailBody: Strings.community_mail_body)
        }
    }
    
    private func composeMail(subject: String,mailBody: String){
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: subject, toRecipients: [],ccRecipients: [AppConfiguration.sales_email],mailBody: mailBody)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
//MARK: MFMailComposeViewControllerDelegate
extension RewardsDetailViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
