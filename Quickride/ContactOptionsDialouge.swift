//
//  ContactOptionsDialouge.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 06/07/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import MessageUI

typealias DialogDismissCompletionHandler = ()->Void

class ContactOptionsDialouge: ModelViewController
{
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var nameofPerson: UILabel!
    
    @IBOutlet weak var alertDialogueView: UIView!
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var smsView: UIView!
    
    @IBOutlet weak var callView: UIView!
    
    @IBOutlet weak var callingNumberLbl: UILabel!
    
    @IBOutlet weak var addAlternateNumberView: UIView!
    
    @IBOutlet weak var smsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addAlternateNumberViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var callViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatImageView: UIImageView!
    
    @IBOutlet weak var smsImageView: UIImageView!
    
    @IBOutlet weak var callImageView: UIImageView!
    
    private var presentConatctUserBasicInfo : UserBasicInfo?
    private var supportCall : CommunicationType = CommunicationType.Chat
    private var delegate : CommunicationUtilsListener?
    private var isRideStarted = false
    private var dismissDelegate : DialogDismissCompletionHandler?
    private var ride: Ride?

    
    func initializeDataBeforePresentingView(ride: Ride?,presentConatctUserBasicInfo : UserBasicInfo,supportCall: CommunicationType, delegate : CommunicationUtilsListener?,isRideStarted : Bool,dismissDelegate : DialogDismissCompletionHandler?){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView() \(presentConatctUserBasicInfo) ")
        self.presentConatctUserBasicInfo = presentConatctUserBasicInfo
        self.supportCall = supportCall
        self.delegate = delegate
        self.isRideStarted = isRideStarted
        self.dismissDelegate = dismissDelegate
        self.ride = ride
    }

    override func viewDidLoad() {
         super.viewDidLoad()
         definesPresentationContext = true
         nameofPerson.text = Strings.contact+" "+presentConatctUserBasicInfo!.name!
         handleViewCustomizations()
         handleVisibilityOfViewsBasedOnSupportCallValue()
         addGestureRecognizers()
         ImageUtils.setTintedIcon(origImage: UIImage(named: "icon_call")!, imageView: callImageView, color: UIColor(netHex: 0x1F90FF))
         ImageUtils.setTintedIcon(origImage: UIImage(named: "sms_new")!, imageView: smsImageView, color: UIColor(netHex: 0x1F90FF))
         ImageUtils.setTintedIcon(origImage: UIImage(named: "ic_chat")!, imageView: chatImageView, color: UIColor(netHex: 0x1F90FF))
    }
    
    private func addGestureRecognizers(){
         dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactOptionsDialouge.dismissViewClicked(_:))))
         smsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactOptionsDialouge.smsViewClicked)))
         chatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactOptionsDialouge.chatViewClicked)))
         callView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactOptionsDialouge.callViewClicked)))
    }
    
    private func handleVisibilityOfViewsBasedOnSupportCallValue(){
        if supportCall == .Call{
            if let appStartUpData = SharedPreferenceHelper.getAppStartUpData(),appStartUpData.enableNumberMasking{
               smsView.isHidden = true
               smsViewHeightConstraint.constant = 0
               handleVisibilityOfAddAlternateNumberView()
            }else{
               smsView.isHidden = false
               smsViewHeightConstraint.constant = 50
               addAlternateNumberView.isHidden = true
               addAlternateNumberViewHeightConstraint.constant = 0
            }
          
        }else{
            callView.isHidden = true
            callViewHeightConstraint.constant = 0
            addAlternateNumberView.isHidden = true
            addAlternateNumberViewHeightConstraint.constant = 0
        }
    }
    
    private func handleVisibilityOfAddAlternateNumberView(){
        
        callView.isHidden = false
        callViewHeightConstraint.constant = 50
        
        if let alternateNum = UserDataCache.getInstance()?.currentUser?.alternateContactNo,alternateNum != 0{
            addAlternateNumberView.isHidden = true
            addAlternateNumberViewHeightConstraint.constant = 0
            callingNumberLbl.text = String(format: Strings.masked_contact_no_with_alternate_num_text, arguments: [NumberUtils.getMaskedMobileNumber(mobileNumber: UserDataCache.getInstance()?.currentUser?.contactNo),NumberUtils.getMaskedMobileNumber(mobileNumber: alternateNum)])
        }else{
            addAlternateNumberView.isHidden = false
            addAlternateNumberViewHeightConstraint.constant = 35
            addAlternateNumberView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ContactOptionsDialouge.addAlternateNumViewTapped(_:))))
            callingNumberLbl.text = String(format: Strings.masked_contact_no_text, arguments: [NumberUtils.getMaskedMobileNumber(mobileNumber: UserDataCache.getInstance()?.currentUser?.contactNo)])
         
        }
    }
    
    private func handleViewCustomizations(){
       ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogueView, cornerRadius: 5.0)
    }
    
    @objc func chatViewClicked()
    {
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(ride: ride, userId : presentConatctUserBasicInfo?.userId ?? 0,isRideStarted: self.isRideStarted, listener: nil)
        self.removeView()
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: viewController, animated: false)
        
        
    }
    
    @objc private func callViewClicked(){
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: presentConatctUserBasicInfo!.userId), refId: Strings.contact, name: presentConatctUserBasicInfo!.name ?? "", targetViewController: self)
        self.removeView()
    }
    @objc private func smsViewClicked()
    {
        let messageViewConrtoller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = ""
            UserDataCache.getInstance()?.getContactNo(userId: (StringUtils.getStringFromDouble(decimalNumber : presentConatctUserBasicInfo?.userId)), handler: { [weak self](contactNo) in
                messageViewConrtoller.recipients = [contactNo]
                messageViewConrtoller.messageComposeDelegate = self
                self?.present(messageViewConrtoller, animated: false, completion: nil)
            })
            
        }
    }
    override func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        AppDelegate.getAppDelegate().log.debug("messageComposeViewController()")
        switch result {
        case .cancelled :
            UIApplication.shared.keyWindow?.makeToast( Strings.sending_sms_cancelled)
            controller.dismiss(animated: false, completion: nil)
            
        case .sent :
            UIApplication.shared.keyWindow?.makeToast( Strings.sms_sent)
            controller.dismiss(animated: false, completion: nil)
            
        case .failed :
            UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_failed)
            controller.dismiss(animated: false, completion: nil)

        }
        
        self.removeView()
    }
    
    @objc private func dismissViewClicked(_ sender: UITapGestureRecognizer)
    {
        self.removeView()
    }
    
    @objc private func addAlternateNumViewTapped(_ sender : UITapGestureRecognizer){
        
        let addAlternateNumViewController = storyboard?.instantiateViewController(withIdentifier: "AddOrUpdateAlternateNumberViewController") as! AddOrUpdateAlternateNumberViewController
        self.present(addAlternateNumViewController, animated: false, completion: nil)
//        ViewControllerUtils.addSubView(viewControllerToDisplay: addAlternateNumViewController)
        self.removeView()
    }
    
    func displayView(){
        ViewControllerUtils.addSubView(viewControllerToDisplay: self)
    }
    
   private func removeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
        dismissDelegate?()
    }
    
}
