//
//  OrderCancellationViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
typealias orderCancellationComplitionHandler = (_ reason: String)-> Void

class OrderCancellationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reasonsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var reasonsTableView: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelButton: QRCustomButton!
    
    private var isKeyBoardVisible = false
    private var selectedIndex = -1
    private var handler: orderCancellationComplitionHandler?
    private var reasons = [String]()
    private var userType: String?
    
    func initialiseOrderCancellationView(userType: String,handler: @escaping orderCancellationComplitionHandler){
        self.userType = userType
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
        if userType == Order.SELLER{
            reasons = Strings.seller_order_cancellation_reasons
        }else{
            reasons = Strings.buyer_order_cancellation_reasons
        }
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        reasonTextField.delegate = self
        textFieldView.isHidden = true
        textFieldViewHeightConstraint.constant = 0
        reasonsTableViewHeightConstraint.constant = CGFloat(reasons.count*45)
        cancelButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
        cancelButton.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    @IBAction func cancelOrder(_ sender: Any) {
        self.view.endEditing(false)
        if selectedIndex < 0{
            return
        }
        if selectedIndex == reasons.count - 1{
            handler?(reasonTextField.text ?? "Other")
        }else if selectedIndex >= 0 && selectedIndex != reasons.count - 1{
            handler?(reasons[selectedIndex])
        }
        closeView()
    }
}
extension OrderCancellationViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortRideMatchTableViewCell", for: indexPath as IndexPath) as! SortRideMatchTableViewCell
        if reasons.endIndex <= indexPath.row{
            return cell
        }
        cell.initializeViews(optionTitle: reasons[indexPath.row], imageSelected: false)
        return cell
    }
}
extension OrderCancellationViewController: UITableViewDelegate{
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) as? SortRideMatchTableViewCell{
            selectedCell.selectionImage.image = UIImage(named: "ic_radio_button_checked")
               
        }
        if let prevSelectedCell = tableView.cellForRow(at: IndexPath(item: selectedIndex, section: 0))as? SortRideMatchTableViewCell{
            if selectedIndex != indexPath.row{
                prevSelectedCell.selectionImage.image = UIImage(named: "radio_button_1")
            }
        }
        selectedIndex = indexPath.row
        if indexPath.row == reasons.count - 1{
            textFieldView.isHidden = false
            textFieldViewHeightConstraint.constant = 50
            cancelButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
            cancelButton.isUserInteractionEnabled = false
        }else{
            textFieldView.isHidden = true
            textFieldViewHeightConstraint.constant = 0
            reasonTextField.text = ""
            reasonTextField.placeholder = Strings.type_your_message
            cancelButton.backgroundColor = UIColor(netHex: 0x26AA4F)
            cancelButton.isUserInteractionEnabled = true
            self.view.endEditing(false)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
extension OrderCancellationViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount > 0{
            cancelButton.backgroundColor = UIColor(netHex: 0x26AA4F)
            cancelButton.isUserInteractionEnabled = true
        }else{
            cancelButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
            cancelButton.isUserInteractionEnabled = false
        }
        let newLength = currentCharacterCount + string.count - range.length
        if newLength > 250{
            return false
        }
        return true
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 20
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 40
    }
}
