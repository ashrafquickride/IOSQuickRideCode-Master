//
//  EditGroupNameViewController.swift
//  Quickride
//
//  Created by rakesh on 3/27/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol GroupNameUpdateDelegate{
    func groupNameUpdated(updatedGroup : Group)
}

class EditGroupNameViewController : ModelViewController{
    
    @IBOutlet weak var grpNameTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var editNameViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var groupNameView: UIView!
   
    @IBOutlet weak var backgroundView: UIView!
    var isKeyBoardVisible = false
    var group : Group?
    var delegate : GroupNameUpdateDelegate?
    
    
    func initializeDataBeforePresenting(group : Group,delegate : GroupNameUpdateDelegate){
        self.group = group
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grpNameTextField.text = group!.name
        ViewCustomizationUtils.addCornerRadiusToView(view: doneBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: groupNameView, cornerRadius: 8.0)
         backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditGroupNameViewController.backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(EditGroupNameViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditGroupNameViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        
        if grpNameTextField.text == nil || grpNameTextField.text!.isEmpty{
            MessageDisplay.displayAlert( messageString: Strings.enter_name, viewController: self,handler: nil)
            return
        }
        
        if grpNameTextField.text != group!.name{
            
           group!.name = grpNameTextField.text
           QuickRideProgressSpinner.startSpinner()
            GroupRestClient.updateGroup(group: group!, viewController: self, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
              if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                self.group!.lastRefreshedTime = NSDate()
                UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: self.group!)
                self.delegate!.groupNameUpdated(updatedGroup: self.group!)
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
       editNameViewCenterYConstraint.constant = -120
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            editNameViewCenterYConstraint.constant = 0
            return
        }
    }

    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func backGroundViewTapped(_ sender : UITapGestureRecognizer){
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    
    
}
