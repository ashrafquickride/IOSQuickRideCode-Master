//
//  EditGroupDescriptionViewController.swift
//  Quickride
//
//  Created by rakesh on 3/27/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol  GroupDescriptionUpdateDelegate {
    func groupDescriptionUpdated(updatedGroup : Group)
}

class EditGroupDescriptionViewController : ModelViewController{
    

    @IBOutlet weak var groupDescriptionView: UIView!
    
    @IBOutlet weak var backGroundView: UIView!
    

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var editDescriptionViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    
  
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    var group : Group?
    var delegate : GroupDescriptionUpdateDelegate?
    var isKeyBoardVisible = false
    
    static let MAX_NO_CHARACTERS = 35
    func initializeDataBeforePresenting(group : Group,delegate : GroupDescriptionUpdateDelegate){
        self.group = group
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.becomeFirstResponder()
        descriptionTextView.selectedTextRange = descriptionTextView.textRange(from: descriptionTextView.beginningOfDocument, to: descriptionTextView.endOfDocument)
        
        if group!.description!.count > EditGroupDescriptionViewController.MAX_NO_CHARACTERS{
            textViewHeightConstraint.constant = 50
        }else{
             textViewHeightConstraint.constant = 30
        }
        descriptionTextView.text = group!.description
        ViewCustomizationUtils.addCornerRadiusToView(view: doneBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: groupDescriptionView, cornerRadius: 8.0)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditGroupDescriptionViewController.backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(EditGroupDescriptionViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditGroupDescriptionViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        
        if descriptionTextView.text == nil || descriptionTextView.text!.isEmpty{
            MessageDisplay.displayAlert( messageString: Strings.enter_description, viewController: self,handler: nil)
            return
        }
        
        if descriptionTextView.text != group!.description{
            
            group!.description = descriptionTextView.text
            QuickRideProgressSpinner.startSpinner()
            GroupRestClient.updateGroup(group: group!, viewController: self, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.group!.lastRefreshedTime = NSDate()
                    UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: self.group!)
                    self.delegate!.groupDescriptionUpdated(updatedGroup: self.group!)
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }else{
             self.view.removeFromSuperview()
            self.removeFromParent()
        }
    
 }
    

    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    
    }
    
  
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        textField.endEditing(true)
        return false
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        editDescriptionViewCenterYConstraint.constant = -120
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            editDescriptionViewCenterYConstraint.constant = 0
            return
        }
    }
    
    
    @objc func backGroundViewTapped(_ sender : UITapGestureRecognizer){
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    
}
