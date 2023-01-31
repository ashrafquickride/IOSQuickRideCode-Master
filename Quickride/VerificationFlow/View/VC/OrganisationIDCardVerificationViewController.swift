//
//  OrganisationIDCardVerificationViewController.swift
//  Quickride
//
//  Created by Vinutha on 04/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI

class OrganisationIDCardVerificationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var uploadFrontCard: UIButton!
    @IBOutlet weak var uploadBackCard: UIButton!
    @IBOutlet weak var sendEmail: UIButton!
    @IBOutlet weak var changeFrontCard: UIButton!
    @IBOutlet weak var changeBackCard: UIButton!
    @IBOutlet weak var frontSideUploadSuccessImageView: UIImageView!
    @IBOutlet weak var backSideUploadSuccessImageView: UIImageView!
    @IBOutlet weak var emailSentImageView: UIImageView!
    @IBOutlet weak var frontSideUploadingProgressView: UIView!
    @IBOutlet weak var frontSideUploadingProgressBar: UIProgressView!
    @IBOutlet weak var backSideUploadingProgressView: UIView!
    @IBOutlet weak var backSideUploadingProgressBar: UIProgressView!
    @IBOutlet weak var idVerificationStatusView: UIView!
    @IBOutlet weak var cancelFrontCard: UIButton!
    @IBOutlet weak var cancelBackCard: UIButton!
    
    var pagehidding = false
    
    //MARK: Properties
    private var orgIdCardVerificationViewModel = OrganisationIDCardVerificationViewModel()
    private var quickRideProgressBar1 : QuickRideProgressBar?
    private var quickRideProgressBar2 : QuickRideProgressBar?
    
    
    
    func pageissue(myagree : Bool){
        self.pagehidding = myagree
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    private func setupUI() {
        uploadFrontCard.isUserInteractionEnabled = true
        uploadBackCard.isUserInteractionEnabled = true
        sendEmail.isUserInteractionEnabled = true
        cancelFrontCard.isUserInteractionEnabled = true
        cancelBackCard.isUserInteractionEnabled = true
        quickRideProgressBar1 = QuickRideProgressBar(progressBar: frontSideUploadingProgressBar)
        quickRideProgressBar2 = QuickRideProgressBar(progressBar: backSideUploadingProgressBar)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(idVerificationInitiated(_:)), name: .organisationIdVerificationInitiated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageSavingSucceded(_:)), name: .organisationIdImageSavingSucceded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(imageSavingFailed(_:)), name: .organisationIdImageSavingFailed, object: nil)
    }
    
    @objc func idVerificationInitiated(_ notification : NSNotification) {
        emailSentImageView.isHidden = false
        sendEmail.setImage(UIImage(named: "mail_icon_black"), for: .normal)
        sendEmail.setTitleColor(UIColor.black, for: .normal)
        idVerificationStatusView.isHidden = false
        changeFrontCard.isHidden = true
        changeBackCard.isHidden = true
        uploadFrontCard.isUserInteractionEnabled = false
        uploadBackCard.isUserInteractionEnabled = false
        sendEmail.isUserInteractionEnabled = false
    }
    
    @objc func imageSavingSucceded(_ notification : NSNotification) {
        if let userInfo = notification.userInfo, let isFrontSide = userInfo[OrganisationIDCardVerificationViewModel.KEY_SUCCESS] as? Bool {
            stopProgressBar(isFrontSide: isFrontSide)
            if isFrontSide {
                changeFrontCard.isHidden = false
                uploadFrontCard.setTitle(Strings.front_side_id_card_uploaded, for: .normal)
                frontSideUploadSuccessImageView.isHidden = false
            } else {
                changeBackCard.isHidden = false
                uploadBackCard.setTitle(Strings.back_side_id_card_uploaded, for: .normal)
                backSideUploadSuccessImageView.isHidden = false
            }
        }
    }
    
    @objc func imageSavingFailed(_ notification : NSNotification) {
        if let userInfo = notification.userInfo, let isFrontSide = userInfo[OrganisationIDCardVerificationViewModel.KEY_FAILED] as? Bool {
            stopProgressBar(isFrontSide: isFrontSide)
            if isFrontSide {
                changeFrontCard.isHidden = true
                uploadFrontCard.setTitle(Strings.upload_front_side_id_card, for: .normal)
                uploadFrontCard.setImage(UIImage(named: "front_side_id_card_blue"), for: .normal)
                uploadFrontCard.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            } else {
                changeBackCard.isHidden = true
                uploadBackCard.setTitle(Strings.upload_back_side_id_card, for: .normal)
                uploadBackCard.setImage(UIImage(named: "back_side_id_card_blue"), for: .normal)
                uploadBackCard.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            }
        }
    }
    
    private func stopProgressBar(isFrontSide: Bool) {
        frontSideUploadingProgressView.isHidden = true
        backSideUploadingProgressView.isHidden = true
        if isFrontSide {
            quickRideProgressBar1?.stopProgressBar()
        } else {
            quickRideProgressBar2?.stopProgressBar()
        }
    }
    
    private func handleImageSelection(isFrontSide: Bool){
        orgIdCardVerificationViewModel.isFrontSide = isFrontSide
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: self,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    private func handleCancelUpload(isFrontSide: Bool) {
        orgIdCardVerificationViewModel.isCancelClicked = true
        stopProgressBar(isFrontSide: isFrontSide)
        if isFrontSide {
            self.uploadFrontCard.setTitle(Strings.upload_front_side_id_card, for: .normal)
            self.uploadFrontCard.setImage(UIImage(named: "front_side_id_card_blue"), for: .normal)
            self.uploadFrontCard.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        } else {
            self.uploadBackCard.setTitle(Strings.upload_back_side_id_card, for: .normal)
            self.uploadBackCard.setImage(UIImage(named: "back_side_id_card_blue"), for: .normal)
            self.uploadBackCard.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        }
    }
    
    //MARK: Actions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func uploadFrontCardClicked(_ sender: UIButton) {
        handleImageSelection(isFrontSide: true)
    }
    
    @IBAction func uploadBackCardClicked(_ sender: UIButton) {
        handleImageSelection(isFrontSide: false)
    }
    
    @IBAction func sendEmailClicked(_ sender: UIButton) {
        orgIdCardVerificationViewModel.initiateCompanyIdVerification(viewController: self)
    }
    
    @IBAction func changeFrontSideIdCardClicked(_ sender: UIButton) {
        handleImageSelection(isFrontSide: true)
    }
    
    @IBAction func changeBackSideIdCardClicked(_ sender: UIButton) {
        handleImageSelection(isFrontSide: false)
    }
    
    @IBAction func frontSideUploadingCancelClicked(_ sender: UIButton) {
        handleCancelUpload(isFrontSide: true)
    }
    
    @IBAction func backSideUploadingCancelClicked(_ sender: UIButton) {
        handleCancelUpload(isFrontSide: false)
    }
    
    @IBAction func contactSupportClicked(_ sender: UIButton) {
        sendEmailToSupport()
    }
}
//MARK: MFMailComposerDelegate
extension OrganisationIDCardVerificationViewController : MFMailComposeViewControllerDelegate {
    private func sendEmailToSupport(){
        AppDelegate.getAppDelegate().log.debug("sendEmailToSupport()")
        if MFMailComposeViewController.canSendMail() {
            let userProfile = UserDataCache.getInstance()?.userProfile
            let mailComposeViewController = MFMailComposeViewController()
            var subject = ""
            if userProfile?.userName != nil{
                subject = subject+(userProfile?.userName)!
            }
            subject = subject + " - " + QRSessionManager.getInstance()!.getCurrentSession().contactNo
            if userProfile?.email != nil{
                subject = subject + " - "+(userProfile?.emailForCommunication)!
            }
            if userProfile?.userId != nil{
                subject = subject + " - UserId - \(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId))"
            }
            let modelName = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            subject = subject + " - Device Information : "+modelName+","+systemVersion+"- QR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            subject = subject + " - Issue Type: Company ID card Verification"
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self
            var recepients = [String]()
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            recepients.append(clientConfiguration!.verificationSupportMail)
            mailComposeViewController.setToRecipients(recepients)
            if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
            }
            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast(Strings.cant_send_mail)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
extension OrganisationIDCardVerificationViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if image != nil{
            if orgIdCardVerificationViewModel.isFrontSide {
                self.uploadFrontCard.setTitle(Strings.front_side_id_card_uploading, for: .normal)
                self.uploadFrontCard.setImage(UIImage(named: "front_side_id_card_black"), for: .normal)
                self.uploadFrontCard.setTitleColor(UIColor.black, for: .normal)
                self.frontSideUploadingProgressView.isHidden = false
                self.quickRideProgressBar1?.startProgressBar()
            } else {
                self.uploadBackCard.setTitle(Strings.back_side_id_card_uploading, for: .normal)
                self.uploadBackCard.setImage(UIImage(named: "back_side_id_card_black"), for: .normal)
                self.uploadBackCard.setTitleColor(UIColor.black, for: .normal)
                self.backSideUploadingProgressView.isHidden = false
                self.quickRideProgressBar2?.startProgressBar()
            }
            self.orgIdCardVerificationViewModel.checkAndSaveIdCardImage(isFrontSide: orgIdCardVerificationViewModel.isFrontSide, actualImage: image!, viewController: self)
        }
    }
}
