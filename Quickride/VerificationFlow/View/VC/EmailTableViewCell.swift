//
//  EmailTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EmailTableViewCell: UITableViewCell {

    @IBOutlet weak var companyLabelName: UILabel!

    @IBOutlet weak var emailView: UIView!
    
    @IBOutlet weak var verifiedEmail: UIButton!
    
    @IBOutlet weak var orSticker: UILabel!
    var isFromSignUpFlow = false
  
    func intialiseData(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow = isFromSignUpFlow
        forLabelHidding()
    }
    
    func forLabelHidding(){
    if isFromSignUpFlow  == true {
                orSticker.isHidden = false
        
            } else {
                orSticker.isHidden = true
            }
}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateEmail()
        self.emailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailTapped(_:))))
    }
    
    func updateEmail(){
    if let email =  UserDataCache.getInstance()?.getLoggedInUserProfile()?.email, !email.isEmpty {
        companyLabelName.text = email
    }
    
      if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified,(profileVerificationData.profVerifSource == 1 || profileVerificationData.profVerifSource == 2 || profileVerificationData.profVerifSource == 4) {
          verifiedEmail.isHidden = false
            verifiedEmail.setTitle(Strings.verified_organisation, for: .normal)
            verifiedEmail.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            verifiedEmail.setImage(UIImage(named: "green_with_border"), for: .normal)

       } else {

            verifiedEmail.isHidden = true

            getCompanyIdVerificationDataAndSetupUI()
        }
        
    }
    private func getCompanyIdVerificationDataAndSetupUI() {
        if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified, profileVerificationData.profVerifSource == 3 {
             verifiedEmail.isHidden = false
             verifiedEmail.setTitle(Strings.verified_identity_card, for: .normal)
             verifiedEmail.setImage(UIImage(named: "green_with_border"), for: .normal)
             verifiedEmail.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)

        } else {
            UserDataCache.getInstance()?.getCompanyIdVerificationData(handler: {(companyIdVerificationData) in


            })
        }
    }
    
    @objc func emailTapped(_ gesture: UITapGestureRecognizer){
    let verifyOrganisationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyOrganisationViewController") as! VerifyOrganisationViewController
        
        
        verifyOrganisationViewController.IntialDateHidding(isFromSignUpFlow: isFromSignUpFlow)
        
        self.parentViewController?.navigationController?.pushViewController(verifyOrganisationViewController, animated: false)
    
}
}
