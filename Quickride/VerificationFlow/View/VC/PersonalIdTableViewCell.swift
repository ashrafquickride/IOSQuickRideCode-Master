//
//  PersonalIdTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PersonalIdTableViewCell: UITableViewCell {

    @IBOutlet weak var orSticker: UILabel!
    @IBOutlet weak var personalIdView: UIView!
    
    var orhide = false
    var isFromSignUpFlow = true
  
    func intialiseData(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow = isFromSignUpFlow
        forHiddingLabel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.personalIdView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(personalIdTapped(_:))))
    }
    
    func forHiddingLabel(){
    if isFromSignUpFlow == true{
        orSticker.isHidden = false
    } else {
        orSticker.isHidden = true
    }
    }

    @objc func personalIdTapped(_ gesture: UITapGestureRecognizer){

     let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.IntialDateHidding(isFromSignUpFlow: isFromSignUpFlow)
        self.parentViewController?.navigationController?.pushViewController(personalIdVerificationViewController, animated: false)
    }
    
}
