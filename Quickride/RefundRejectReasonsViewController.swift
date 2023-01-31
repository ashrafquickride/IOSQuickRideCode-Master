//
//  RefundRejectReasonsViewController.swift
//  Quickride
//
//  Created by Vinutha on 09/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias refundRejectionComplitionHandler = (_ reason: String?) -> Void

class RefundRejectReasonsViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reasonsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var reasonsTableView: UITableView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rejectButton: QRCustomButton!
    
    private var reasons = [String]()
    private var selectedIndex = -1
    private var isKeyBoardVisible = false
    private var actionName: String?
    private var handler: refundRejectionComplitionHandler?
    
    func initializeReasons(reasons: [String], actionName: String, handler: @escaping refundRejectionComplitionHandler){
        self.reasons = reasons
        self.actionName = actionName
        self.handler = handler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        setupUI()
    }
    
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
        }, completion: nil)
    }
    
    private func setupUI() {
        rejectButton.setTitle(actionName, for: .normal)
        reasonTextField.delegate = self
        textFieldView.isHidden = true
        textFieldViewHeightConstraint.constant = 0
        rejectButton.isUserInteractionEnabled = false
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideCancellationAndUnJoinViewController.backGroundViewTapped(_:))))
        reasonsTableViewHeightConstraint.constant = CGFloat(reasons.count*45)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func rejectTappedTapped(_ sender: Any){
        self.view.endEditing(false)
        if selectedIndex < 0 || (selectedIndex == reasons.count - 1 && reasonTextField.text?.isEmpty == true){
            return
        }
        if selectedIndex == reasons.count - 1{
            handler?(reasonTextField.text)
        }else if selectedIndex >= 0 && selectedIndex != reasons.count - 1{
            handler?(reasons[selectedIndex])
        }
        closeView()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount > 1{
            rejectButton.backgroundColor = UIColor(netHex: 0xE20000)
            rejectButton.isUserInteractionEnabled = true
        }else{
            rejectButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
            rejectButton.isUserInteractionEnabled = false
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
}

extension RefundRejectReasonsViewController: UITableViewDataSource{
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
extension RefundRejectReasonsViewController: UITableViewDelegate{
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
            rejectButton.backgroundColor = UIColor(netHex: 0xD3D3D3)
            rejectButton.isUserInteractionEnabled = false
        }else{
            textFieldView.isHidden = true
            textFieldViewHeightConstraint.constant = 0
            reasonTextField.text = ""
            reasonTextField.placeholder = Strings.type_your_message
            rejectButton.backgroundColor = UIColor(netHex: 0xE20000)
            rejectButton.isUserInteractionEnabled = true
            self.view.endEditing(false)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
}
