//
//  ReferenceRequestTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ReferenceRequestTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var endorcementView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.endorcementView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endorcementTapped(_:))))

    }
    
    @objc func endorcementTapped(_ gesture: UITapGestureRecognizer){
        
      if SharedPreferenceHelper.getDisplayStatusForEndorsementInfoView() {
            let endorsementListViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorsementListViewController") as! EndorsementListViewController
          self.parentViewController?.navigationController?.pushViewController(endorsementListViewController, animated: false)
        } else {
            let verifyByEndorsementInfoViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyByEndorsementInfoViewController") as! VerifyByEndorsementInfoViewController
            ViewControllerUtils.addSubView(viewControllerToDisplay: verifyByEndorsementInfoViewController)
        }
       
}
    
}
    


