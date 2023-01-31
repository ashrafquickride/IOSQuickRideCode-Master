//
//  SaveCustomizedRouteViewController.swift
//  Quickride
//
//  Created by Admin on 24/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias saveCustomizedRouteCompletionHandler = (_ routeName : String) -> Void

class SaveCustomizedRouteViewController : UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var routeNameTextField: UITextField!
    @IBOutlet weak var alertViewVerticalAlignmentConstant: NSLayoutConstraint!
    
    //MARK: Properties
    private var handler : saveCustomizedRouteCompletionHandler?
    private var suggestedRouteName : String?
    
    //MARK: Initializer Method
    func initializeDataBeforePresenting(suggestedRouteName : String,handler : saveCustomizedRouteCompletionHandler?) {
        self.suggestedRouteName = suggestedRouteName
        self.handler = handler
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
      super.viewDidLoad()
      setupUI()
    }
    
    private func setupUI() {
        routeNameTextField.delegate = self
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SaveCustomizedRouteViewController.backgroundViewTapped(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        routeNameTextField.text = suggestedRouteName
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CustomExtensionUtility.changeBtnColor(sender: self.saveBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addCornerRadiusToView(view: self.saveBtn, cornerRadius: 8.0)
    }
    
    //MARK: Methods
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
  
   
    //MARK: Actions
    @IBAction func saveBtnClicked(_ sender: Any) {
        if routeNameTextField.text == nil || routeNameTextField.text!.isEmpty {
            MessageDisplay.displayAlert(messageString: Strings.please_enter_route_name, viewController: self, handler: nil)
            return
        }
        handler?(routeNameTextField.text!)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
   @IBAction func cancelBtnClicked(_ sender: Any) {
        handler = nil
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

//MARK: TextFieldDelegate
extension SaveCustomizedRouteViewController : UITextFieldDelegate {
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         self.view.endEditing(false)
         return true
     }
     
    func textFieldDidBeginEditing(_ textField: UITextField) {
        alertViewVerticalAlignmentConstant.constant = -100
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
        alertViewVerticalAlignmentConstant.constant = 0
    }
}
