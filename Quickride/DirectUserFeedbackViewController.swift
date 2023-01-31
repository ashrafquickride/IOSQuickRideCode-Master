//
//  DirectUserFeedbackViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/01/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class DirectUserFeedbackViewController : ModelViewController, UITextFieldDelegate{
    
    @IBOutlet weak var commentsTextField: UITextField!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var ratingBar: RatingBar!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var alertViewYPosition: NSLayoutConstraint!
    
    @IBOutlet weak var submitButton: UIButton!{
        didSet{
            ViewCustomizationUtils.addCornerRadiusToView(view: submitButton, cornerRadius: 10.0)
        }
    }
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var negativeActionButton: UIButton!{
        didSet{
            negativeActionButton.addShadow()
        }
    }
    
    private var isKeyBoardVisible = false
    private var name : String = ""
    private var imageURL : String?
    private var gender : String = ""
    private var userId : Double = 0
    private var rideId: Double?
    
    func initializeDataAndPresent(name : String,imageURI : String?,gender : String,userId : Double, rideId: Double?)
    {
        self.name = name
        self.imageURL = imageURI
        self.gender = gender
        self.userId = userId
        self.rideId = rideId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTextField.delegate = self
        userName.text = name
        ratingBar.imageDark = UIImage(named: "ratingbar_star_dark_big")!
        ratingBar.imageLight = UIImage(named: "ratingbar_star_light_big")!
        ImageCache.getInstance().setImageToView(imageView: self.userImage, imageUrl: imageURL, gender: gender,imageSize: ImageCache.DIMENTION_SMALL)
        alertView.layer.cornerRadius = 10
        ViewCustomizationUtils.addCornerRadiusToView(view: submitButton, cornerRadius: 2.0)
        NotificationCenter.default.addObserver(self, selector: #selector(DirectUserFeedbackViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DirectUserFeedbackViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DirectUserFeedbackViewController.backGroundViewTapped(_:))))
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        if (commentsTextField.text == nil || commentsTextField.text!.isEmpty) && (self.ratingBar.rating == 1 || self.ratingBar.rating == 2)
        {
            UIApplication.shared.keyWindow?.makeToast( Strings.please_enter_comments)
            return
        }
        if self.ratingBar.rating == 0{
            UIApplication.shared.keyWindow?.makeToast( Strings.please_rate_user)
            return
        }
        
        let userFeedback = UserFeedback(rideid: self.rideId, feedbackbyphonenumber: Double(QRSessionManager.getInstance()!.getUserId())!, feedbacktophonenumber:Double(userId), rating:Float(self.ratingBar.rating), extrainfo: commentsTextField.text!, feebBackToName: name,feebBackToImageURI : imageURL,feedBackToUserGender : gender, feedBackCommentIds: nil)
        
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.saveUserDirectFeedback(targetViewController: self, body: userFeedback.getParams(), completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.user_feedback_submitted)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
            else{
                 ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        alertViewYPosition.constant = -120
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            alertViewYPosition.constant = 0
            return
        }
    }
    @IBAction func skipButtonClicked(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @objc func backGroundViewTapped(_ sender :UITapGestureRecognizer)
    {   
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
}
