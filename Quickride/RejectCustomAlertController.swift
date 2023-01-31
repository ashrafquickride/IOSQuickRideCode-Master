//
//  RejectCustomAlertController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 19/06/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public typealias RejectCustomAlertControllerHandler = (_ text : String, _ result : String) -> Void

class RejectCustomAlertController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var setTitle: UILabel!
    
    @IBOutlet weak var reasonTextField: UITextField!
    
    @IBOutlet weak var positiveButton: UIButton!
    
    @IBOutlet weak var negativeButton: UIButton!
    
    @IBOutlet weak var alertDialogueView: UIView!
    
  @IBOutlet var rejectReasonsButton: UIButton!
    @IBOutlet weak var alertDialogueViewCenterYConstraint: NSLayoutConstraint!
  
    var isKeyBoardVisible = false
    var reasonSelectionEnable = true
    var titleMessage : String?
    var positiveBtnTitle : String?
    var negativeBtnTitle : String?
    var viewController : UIViewController?
    var rideType: String?

    var completionHandler : RejectCustomAlertControllerHandler?
    
       override func viewDidLoad()
    {
       definesPresentationContext = true
       reasonTextField.delegate = self
        setTitle.text = titleMessage
        positiveButton.setTitle(positiveBtnTitle, for: UIControl.State.normal)
        negativeButton.setTitle(negativeBtnTitle, for: UIControl.State.normal)
        NotificationCenter.default.addObserver(self, selector: #selector(RejectCustomAlertController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RejectCustomAlertController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        handleBrandingChangesBasedOnTarget()
      if rideType == nil{
        rejectReasonsButton.isHidden = true
      }else{
        rejectReasonsButton.isHidden = false
      }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func handleBrandingChangesBasedOnTarget()
    {
            ViewCustomizationUtils.addCornerRadiusToView(view: alertDialogueView, cornerRadius: 5.0)
            ViewCustomizationUtils.addCornerRadiusToView(view: positiveButton, cornerRadius: 2.0)
    }
    
    
    func initializeDataBeforePresentingView(title : String?, positiveBtnTitle : String?, negativeBtnTitle : String?, viewController: UIViewController?, rideType : String?, handler : @escaping RejectCustomAlertControllerHandler)
    {
        self.titleMessage = title
        self.positiveBtnTitle = positiveBtnTitle
        self.negativeBtnTitle = negativeBtnTitle
        self.viewController = viewController
        self.completionHandler = handler
        self.rideType = rideType
        if viewController?.navigationController != nil{
          viewController?.navigationController!.view.addSubview(self.view!)
            viewController?.navigationController!.addChild(self)
        }else{
          viewController?.view.addSubview(self.view!)
            viewController?.addChild(self)
        }
    }

    @IBAction func reasonButtonTapped(_ sender: Any) {
        displayReasonsForRejection()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
        
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            alertDialogueViewCenterYConstraint.constant = -keyBoardSize.height/2
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        alertDialogueViewCenterYConstraint.constant = 0
    }

    
    func displayReasonsForRejection(){
       
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let listOfReasons : [String]?
        if rideType == Ride.RIDER_RIDE
        {
            listOfReasons = Strings.rejectReasonsForRider
        }
        else
        {
            listOfReasons = Strings.rejectReasonsForPassenger
        }
        for reason in listOfReasons!
        {
            let action = UIAlertAction(title: reason, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.reasonTextField.text = reason
                })
                optionMenu.addAction(action)
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        let height : NSLayoutConstraint = NSLayoutConstraint(item: optionMenu.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: self.viewController!.view.frame.height * 0.50)
        optionMenu.view.addConstraint(height)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }

    @IBAction func positiveActionTapped(_ sender: Any) {
        self.view?.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(reasonTextField.text!,positiveBtnTitle!)
    }
    
    @IBAction func negativeActionTapped(_ sender: Any) {
        self.view?.removeFromSuperview()
        self.removeFromParent()
        completionHandler?(reasonTextField.text!,negativeBtnTitle!)
    }
    
}
