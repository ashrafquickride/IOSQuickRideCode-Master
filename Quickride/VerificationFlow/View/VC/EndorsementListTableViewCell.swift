//
//  EndorsementListTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsementListTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var favouriteImage: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var callChatView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var requestSentView: UIView!
    @IBOutlet weak var menuButtonYConstraint: NSLayoutConstraint!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var callChatViewWidthConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    private var cellViewModel = EndorsementListTableViewCellViewModel()
    private var viewController: UIViewController?
    
    //MARK: Initializer
    func initializeView(endorsableUser: EndorsableUser?, endorsementVerificationInfo: EndorsementVerificationInfo?, viewController: UIViewController) {
        cellViewModel.initialiseData(endorsableUser: endorsableUser, endorsementVerificationInfo: endorsementVerificationInfo)
        self.viewController = viewController
        setUpUI()
    }
    
    //MARK: Methods
    private func setUpUI() {
        pendingLabel.isHidden = true
        if let endorsableUser = cellViewModel.endorsableUser, tag == 0 {
            setUiUsingEndorsableUser(endorsableUser: endorsableUser)
        } else if let endorsementVerificationInfo = cellViewModel.endorsementVerificationInfo, tag == 1 {
            setUiUsingEndorsementData(endorsementVerificationInfo: endorsementVerificationInfo)
        }
    }
    
    private func setUiUsingEndorsableUser(endorsableUser: EndorsableUser) {
        contactNameLabel.text = endorsableUser.name
        companyNameLabel.text = endorsableUser.companyName
        ImageCache.getInstance().setImageToView(imageView: contactImage, imageUrl: endorsableUser.imageURI, gender: endorsableUser.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
        if UserDataCache.getInstance()?.isFavouritePartner(userId: endorsableUser.userId ?? 0) == true {
            favouriteImage.isHidden = false
        }else{
            favouriteImage.isHidden = true
        }
        requestSentView.isHidden = true
        menuButtonYConstraint.constant = 0
        if endorsableUser.endorsementStatus == nil {
            requestButton.isHidden = false
            callChatView.isHidden = true
            callChatViewWidthConstraint.constant = 108
        } else if EndorsableUser.STATUS_INITIATED.caseInsensitiveCompare(endorsableUser.endorsementStatus!) == ComparisonResult.orderedSame {
            requestButton.isHidden = true
            menuButtonYConstraint.constant = 8
            callChatView.isHidden = false
            requestSentView.isHidden = false
            callChatViewWidthConstraint.constant = 108
            checkCallChatOptionAvailability(endorsableUser: endorsableUser)
        } else if EndorsableUser.STATUS_REJECTED.caseInsensitiveCompare(endorsableUser.endorsementStatus!) == ComparisonResult.orderedSame {
            callChatView.isHidden = true
            requestButton.isHidden = true
            pendingLabel.isHidden = false
            pendingLabel.text = EndorsableUser.STATUS_REJECTED.capitalizingFirstLetter()
            callChatViewWidthConstraint.constant = 108
        } else if EndorsableUser.STATUS_VERIFIED.caseInsensitiveCompare(endorsableUser.endorsementStatus!) == ComparisonResult.orderedSame {
            requestButton.isHidden = true
            callChatView.isHidden = true
            callChatViewWidthConstraint.constant = 0
        } else {
            requestButton.isHidden = false
            callChatView.isHidden = true
            callChatViewWidthConstraint.constant = 108
        }
    }
    
    private func setUiUsingEndorsementData(endorsementVerificationInfo: EndorsementVerificationInfo) {
        contactNameLabel.text = endorsementVerificationInfo.name
        companyNameLabel.text = endorsementVerificationInfo.companyName
        ImageCache.getInstance().setImageToView(imageView: contactImage, imageUrl: endorsementVerificationInfo.imageURI, gender: endorsementVerificationInfo.gender ?? "U", imageSize: ImageCache.DIMENTION_TINY)
        if UserDataCache.getInstance()?.isFavouritePartner(userId: endorsementVerificationInfo.userId ?? 0) == true {
            favouriteImage.isHidden = false
        }else{
            favouriteImage.isHidden = true
        }
        requestButton.isHidden = true
        callButton.isHidden = true
        chatButton.isHidden = true
        requestSentView.isHidden = true
        menuButtonYConstraint.constant = 0
        if endorsementVerificationInfo.endorsementStatus == nil {
            callChatView.isHidden = true
            callChatViewWidthConstraint.constant = 0
        } else if EndorsableUser.STATUS_INITIATED.caseInsensitiveCompare(endorsementVerificationInfo.endorsementStatus!) == ComparisonResult.orderedSame {
            callChatView.isHidden = false
            menuButton.isHidden = false
            pendingLabel.isHidden = false
            pendingLabel.text = EndorsableUser.PENDING
            callChatViewWidthConstraint.constant = 108
        } else if EndorsableUser.STATUS_REJECTED.caseInsensitiveCompare(endorsementVerificationInfo.endorsementStatus!) == ComparisonResult.orderedSame {
            callChatView.isHidden = true
            pendingLabel.isHidden = false
            callChatViewWidthConstraint.constant = 108
            pendingLabel.text = EndorsableUser.STATUS_REJECTED.capitalizingFirstLetter()
        } else {
            callChatView.isHidden = true
            callChatViewWidthConstraint.constant = 0
        }
    }
    
    private func checkCallChatOptionAvailability(endorsableUser: EndorsableUser){
        if endorsableUser.enableChatAndCall == true {
            if endorsableUser.callSupport != UserProfile.SUPPORT_CALL_NEVER{
                callButton.backgroundColor = UIColor(netHex: 0x2196f3)
            }else{
                callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            }
            chatButton.backgroundColor = UIColor(netHex: 0x19ac4a)
        }else{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    //MARK: Actions
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        cellViewModel.requestForEndorsement()
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("callButtonClicked()")
        if let endorsableUser = cellViewModel.endorsableUser {
            if let callDisableMsg = cellViewModel.getErrorMessageForCall(endorsableUser: endorsableUser){
                UIApplication.shared.keyWindow?.makeToast(callDisableMsg)
                return
            }
            AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: endorsableUser.userId), refId: "",  name: endorsableUser.name , targetViewController: viewController!)
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        if let endorsableUser = cellViewModel.endorsableUser {
            if let chatDisableMsg = cellViewModel.getErrorMessageForChat(endorsableUser: endorsableUser) {
               UIApplication.shared.keyWindow?.makeToast( chatDisableMsg )
                return
            }
            let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
            chatConversationDialogue.initializeDataBeforePresentingView(ride: nil, userId: endorsableUser.userId ?? 0, isRideStarted: false, listener: nil)
            viewController?.navigationController?.pushViewController(chatConversationDialogue, animated: true)
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.request_again, style: .default) { action -> Void in
            self.cellViewModel.requestForEndorsement()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        viewController?.present(actionSheetController, animated: true)
    }
}
