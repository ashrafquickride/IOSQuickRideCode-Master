//
//  VerificationStatusViewController.swift
//  Quickride
//
//  Created by Halesh on 07/01/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class VerificationStatusViewController: UIViewController {
    
    //MARK: Ooulets
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var counterSlider: UISlider!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: Propertise
    private var verificationStatusViewModel = VerificationStatusViewModel()
    
    func initializeVerificationView(companyName: String, status: String,emailDomain: String){
        verificationStatusViewModel = VerificationStatusViewModel(companyName: companyName, status: status, emailDomain: emailDomain)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        verificationStatusViewModel.getCompanyDomainStatus()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(companyDomainStatusReceived(_:)), name: .companyDomainStatusReceived, object: verificationStatusViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(companyDomainStatusFailed(_:)), name: .companyDomainStatusFailed, object: verificationStatusViewModel)
        setUpUI()
    }
    
    private func setUpUI(){
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(backGroundTapped)))
        companyNameLabel.text = (verificationStatusViewModel.companyName ?? "") + " - "
        if verificationStatusViewModel.status == ProfileVerificationData.REJECTED{
            descriptionLabel.text = String(format: Strings.verification_hold_status, arguments: [(verificationStatusViewModel.companyName ?? "")])
            verificationStatusLabel.textColor = UIColor(netHex: 0xce3939)
            counterSlider.minimumTrackTintColor = UIColor(netHex: 0xd65b5b)
            counterSlider.setThumbImage(UIImage(named: "red_border_icon"), for: .normal)
            verificationStatusLabel.text = Strings.verification_on_rejected
        }else{
            descriptionLabel.text = String(format: Strings.verification_process_status, arguments: [(verificationStatusViewModel.companyName ?? ""),(verificationStatusViewModel.companyName ?? "")])
            verificationStatusLabel.textColor = UIColor(netHex: 0xd27902)
            counterSlider.minimumTrackTintColor = UIColor(netHex: 0x00b501)
            counterSlider.setThumbImage(UIImage(named: "green_border_icon"), for: .normal)
            verificationStatusLabel.text = Strings.verification_in_process
        }
        setSliderDependingOnCount()
    }
    
    private func setSliderDependingOnCount(){
        let count = verificationStatusViewModel.companyVerificationStatus?.verifiedCount ?? 0
        counterSlider.trackRect(forBounds: CGRect(x: 0, y: 0, width: 25, height: 25))
        if count > 0{
            if count == 1{
                counterLabel.text = String(format: "Your profile created", arguments: [String(count)])
                counterSlider.setValue(Float(count + 1), animated: false)
            }else{
                counterLabel.text = String(format: Strings.riders_joined, arguments: [String(count)])
                counterSlider.setValue(Float(count), animated: false)
            }
            counterLabel.isHidden = false
        }else{
            counterSlider.setValue(Float(count), animated: false)
            counterLabel.isHidden = true
        }
    }
    
    @IBAction func referNowTapped(_ sender: Any) {
        guard let referralCode = UserDataCache.getInstance()?.getReferralCode() else { return }
        InstallReferrer.prepareURLForDeepLink(referralCode: referralCode) { (urlString)  in
            if urlString != nil{
                self.shareReferralContext(urlString: urlString!, referralCode: referralCode)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String,referralCode: String){
        let message = String(format: Strings.share_and_earn_msg, arguments: [referralCode,urlString,UserDataCache.getInstance()!.userProfile!.userName!])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
               UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            }
            else{
               UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.present(avc, animated: true, completion: nil)
    }
    
    @objc func backGroundTapped(_ getsture: UITapGestureRecognizer) {
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
    
    @objc func companyDomainStatusReceived(_ notification: Notification) {
        setSliderDependingOnCount()
    }
    
    @objc func companyDomainStatusFailed(_ notification: Notification) {
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject , error: error, viewController: self, handler: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
