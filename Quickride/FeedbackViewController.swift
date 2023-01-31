//
//  FeedbackViewController.swift
//  Quickride
//
//  Created by KNM Rao on 26/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import MessageUI


class FeedbackViewController: UIViewController, UITextViewDelegate, SelectContactDelegate {
    
    @IBOutlet weak var txtComments: UITextView!
    
    var userId : String!
    var clientConfiguration : ClientConfigurtion?
    var isKeyBoardVisible = false
    
    @IBOutlet weak var fbButton: UIButton!
    
    
    @IBOutlet weak var ratingBar: RatingBar!
    
    
    @IBOutlet weak var appStoreView: UIImageView!
    
    @IBOutlet weak var likeUsLabel: UILabel!
    // Branding related outlets
    
    @IBOutlet weak var btnSubmitFeedback: UIButton!
    
    @IBOutlet weak var rateUsLabel: UILabel!

  
  @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
  private var  modelLessDialogue: ModelLessDialogue?

  
    override func viewDidLoad() {
        super.viewDidLoad()
        handleBrandingChanges()
        definesPresentationContext = true
        self.userId = QRSessionManager.getInstance()?.getUserId()
        
        clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        
        self.txtComments.text = Strings.comments
        txtComments.textColor = UIColor.lightGray
        self.txtComments.delegate = self
        self.txtComments.layer.cornerRadius = 2.0
        self.txtComments.layer.borderWidth = 1.0
        self.txtComments.layer.borderColor = UIColor.lightGray.cgColor
        
        self.btnSubmitFeedback.layer.cornerRadius = 5.0
        ratingBar.imageDark = UIImage(named: "ratingbar_star_dark_big")!
        ratingBar.imageLight = UIImage(named: "ratingbar_star_light_big")!
        
        appStoreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedbackViewController.AppStoreTapped(_:))))
        appStoreView.layer.cornerRadius = appStoreView.bounds.size.width/2.0
        appStoreView.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func handleBrandingChanges()
    {
        btnSubmitFeedback.backgroundColor = Colors.feedbackButtonBackGroundColor
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
        txtComments.endEditing(true)
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        
       topSpaceConstraint.constant = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        self.txtComments.endEditing(true)
        return true
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
      topSpaceConstraint.constant = 53

    }
    
    
    
    @IBAction func btnSubmitFeedbackTapped(_ sender: Any) {
        doSubmitFeedback()
    }
    
    @objc func AppStoreTapped(_ gesture : UITapGestureRecognizer){
        
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            
        }
    }
    private func doSubmitFeedback() {
        AppDelegate.getAppDelegate().log.debug("doSubmitFeedback()")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        if (txtComments.text == nil || txtComments.text.isEmpty == true || txtComments.text == Strings.comments) && (self.ratingBar.rating == 1 || self.ratingBar.rating == 2)
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.please_enter_comments)
            return
        }
        QuickRideProgressSpinner.startSpinner()
        self.txtComments.resignFirstResponder()
        let comment = txtComments.text!
        AppDelegate.getAppDelegate().log.debug(comment)
        var bodyParams : [String : String] = [String : String]()
        bodyParams["feedbackby"] = self.userId
        bodyParams["feedbacktime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.getTimeInUTC(time: NSDate().getTimeStamp()), timeFormat: "ddMMyyyyHHmm")
        bodyParams["rating"] = String(describing: self.ratingBar.rating)
        bodyParams["extrainfo"] = comment
        
        SystemFeedbackRestClient.postSystemFeedbackWithBody(targetViewController: self, body: bodyParams) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                self.txtComments.endEditing(false)
                UIApplication.shared.keyWindow?.makeToast( "Thank you for your feedback!")
                if(self.ratingBar.rating == 5)
                {
                    self.displayAppPlayReviewToast()
                    return
                }
                self.navigationController?.popViewController(animated: false)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    private func displayAppPlayReviewToast()
    {
        modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
        modelLessDialogue?.initializeViews(message: Strings.can_you_help, actionText: Strings.review_play_store)
        modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileEditingVC(_:))))
        modelLessDialogue?.isUserInteractionEnabled = true
        modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
        self.view.addSubview(modelLessDialogue!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.removeModelLessDialogue()
        }
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func profileEditingVC(_ recognizer: UITapGestureRecognizer) {
        let url = NSURL(string: AppConfiguration.application_link)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Textfield delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("textViewShouldBeginEditing()")
        if txtComments.text == nil || txtComments.text.isEmpty == true || txtComments.text == Strings.comments{
            
            txtComments.text = ""
            txtComments.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("textViewDidChange()")
        if(txtComments.text.isEmpty == true){
            txtComments.textColor = UIColor.lightGray
            txtComments.text = Strings.comments
            txtComments.endEditing(true)
            resignFirstResponder()
        }else{
            txtComments.textColor = UIColor.black
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var threshold : Int?
        if textView == txtComments{
            threshold = 512
        }else{
            return true
        }
        let currentCharacterCount = textView.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.count - range.length
        return newLength <= threshold!
    }
    @IBAction func fbButtonTapped(_ sender: Any) {
        
        AppDelegate.getAppDelegate().log.debug("btnLike()")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        let url = NSURL(string : AppConfiguration.facebook_page)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func rateaUserClicked(_ sender: Any) {
        let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
        selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.rideParticipants)
        selectContactViewController.modalPresentationStyle = .overFullScreen
        self.present(selectContactViewController, animated: false, completion: nil)
    }
    
    func selectedContact(contact: Contact) {
        if contact.contactType == Contact.RIDE_PARTNER{
        let viewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
            viewController.initializeDataAndPresent(name: contact.contactName,imageURI: contact.contactImageURI,gender: contact.contactGender,userId:Double(contact.contactId!)!, rideId: nil)
        self.navigationController?.view.addSubview(viewController.view)
        self.navigationController?.addChild(viewController)
        }
        else{
            UIApplication.shared.keyWindow?.makeToast( Strings.not_registered)
        }
    }
}
