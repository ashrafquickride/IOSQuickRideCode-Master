//
//  PendingVerifyTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PendingVerifyTableViewCell: UITableViewCell {
    

    @IBOutlet weak var endorcementRequestLabel: UILabel!
    @IBOutlet weak var contactNamelabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var rerequestButton: UIButton!
    @IBOutlet weak var contactCompanyLabel: UILabel!
    
    @IBOutlet weak var pendingStatusLabel: UILabel!
    var viewController: UIViewController?
    let endoViewModel = EndorsementListTableViewCellViewModel()
    
    //Intialiser
    func initializeData(endorsableUser: EndorsableUser?, endorsementVerificationInfo: EndorsementVerificationInfo?, viewController: UIViewController){
        endoViewModel.initialiseData(endorsableUser: endorsableUser, endorsementVerificationInfo: endorsementVerificationInfo)
        self.viewController = viewController
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        endorcementRequestLabel.isHidden = true
        setup()
       
        
    }

    func setup(){
    if let endorsementVerificationInfo =  endoViewModel.endorsementVerificationInfo {
        setUiUsingEndorsementData(endorsementVerificationInfo: endorsementVerificationInfo)
    }
    }
    
    private func setUiUsingEndorsementData(endorsementVerificationInfo: EndorsementVerificationInfo) {
        contactNamelabel.text = endorsementVerificationInfo.name
        contactCompanyLabel.text = endorsementVerificationInfo.companyName
        ImageCache.getInstance().setImageToView(imageView: profileImage, imageUrl: endorsementVerificationInfo.imageURI, gender: endorsementVerificationInfo.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
    
        if endorsementVerificationInfo.endorsementStatus == nil {
          //it is logic
        } else if EndorsableUser.STATUS_INITIATED.caseInsensitiveCompare(endorsementVerificationInfo.endorsementStatus!) == ComparisonResult.orderedSame {

            pendingStatusLabel.text = EndorsableUser.PENDING
        } else if EndorsableUser.STATUS_REJECTED.caseInsensitiveCompare(endorsementVerificationInfo.endorsementStatus!) == ComparisonResult.orderedSame {
            pendingStatusLabel.text = EndorsableUser.STATUS_REJECTED.capitalizingFirstLetter()
        } else {
            
        }
    }
    
    
    @IBAction func rerequestTapped(_ sender: Any) {
    
    
    let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let firstAction: UIAlertAction = UIAlertAction(title: Strings.request_again, style: .default) { action -> Void in
        self.endoViewModel.requestForEndorsement()
    }
    let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
    actionSheetController.addAction(firstAction)
    actionSheetController.addAction(cancelAction)
    viewController?.present(actionSheetController, animated: true)
    
}
    
}
