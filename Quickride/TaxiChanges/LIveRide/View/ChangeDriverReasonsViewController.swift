//
//  ChangeDriverReasonsViewController.swift
//  Quickride
//
//  Created by Rajesab on 22/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias complitionHandler = (_ result : TaxiRidePassengerDetails?) -> Void

class ChangeDriverReasonsViewController: UIViewController {

    @IBOutlet weak var changeDriverButton: UIButton!
    @IBOutlet weak var reasonsListTableView: UITableView!
    @IBOutlet weak var reasonsListTableViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var reasonTextFieldViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var reasonTextFieldView: UIView!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    private var changeDriverReasonsViewModel = ChangeDriverReasonsViewModel()
    private var isKeyBoardVisible = false

    func prepareData(taxiRidePassenger: TaxiRidePassenger?, complitionHandler: @escaping complitionHandler) {
        self.changeDriverReasonsViewModel = ChangeDriverReasonsViewModel(taxiRidePassenger: taxiRidePassenger, complitionHandler: complitionHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        reasonsListTableView.register(UINib(nibName: "BadRatingReasonTableViewCell", bundle: nil), forCellReuseIdentifier: "BadRatingReasonTableViewCell")
        reasonsListTableViewHeightConstraints.constant = CGFloat(Strings.change_driver_reason_list.count*45)
        reasonsListTableView.delegate = self
        reasonsListTableView.dataSource = self
        reasonTextField.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        reasonTextFieldViewHeightConstraints.constant = 0
        changeDriverButton.backgroundColor = .lightGray
        changeDriverButton.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    @objc func handleApiFailureError(_ notification: Notification){
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 15
            
        }
    }
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 15
    }

    @IBAction func changeDriverButtonTapped(_ sender: Any) {
        var reason = Strings.other
        if changeDriverReasonsViewModel.selectedIndex != (Strings.change_driver_reason_list.count - 1){
            reason = Strings.change_driver_reason_list[changeDriverReasonsViewModel.selectedIndex]
        }else if reasonTextField.text?.isEmpty == false {
            reason = reasonTextField.text ?? ""
        }
        QuickRideProgressSpinner.startSpinner()
        changeDriverReasonsViewModel.requestChangeDriver(driverChangeReason: reason, taxiGroupId: changeDriverReasonsViewModel.taxiRidePassenger?.taxiGroupId ?? 0, taxiRidePassengerId: changeDriverReasonsViewModel.taxiRidePassenger?.id ?? 0, customerId: changeDriverReasonsViewModel.taxiRidePassenger?.userId ?? 0, status: TaxiTripChangeDriverInfo.FIELD_DRIVER_CHANGE_STATUS_ACTIVE, complition: { (result) in
                                                            QuickRideProgressSpinner.stopSpinner()
                                                            self.closeView()
                                                            self.changeDriverReasonsViewModel.complitionHandler?(result) })
    }
    private func animateView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
                       }, completion: nil)
    }
    
    private func closeView(){
        NotificationCenter.default.removeObserver(self)
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

extension ChangeDriverReasonsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Strings.change_driver_reason_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BadRatingReasonTableViewCell", for: indexPath) as! BadRatingReasonTableViewCell
        cell.setUpUI(selectedIndex: changeDriverReasonsViewModel.selectedIndex, index: indexPath.row, reasonText: Strings.change_driver_reason_list[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeDriverReasonsViewModel.selectedIndex = indexPath.row
        changeDriverButton.backgroundColor = UIColor(netHex: 0x00B557)
        changeDriverButton.isUserInteractionEnabled = true
        if indexPath.row == (Strings.change_driver_reason_list.count) - 1 {//LastIndex
            reasonTextFieldView.isHidden = false
            reasonTextFieldViewHeightConstraints.constant = 40
            reasonTextField.text = ""
        } else {
            reasonTextField.endEditing(true)
            reasonTextFieldView.isHidden = true
            reasonTextFieldViewHeightConstraints.constant = 0
        }
        reasonsListTableView.reloadData()
    }
}
extension ChangeDriverReasonsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if reasonTextField.text == nil || reasonTextField.text?.isEmpty == true || reasonTextField.text == Strings.tell_us_the_reason {
            reasonTextField.text = ""
        }
    }
}
extension Notification.Name{
    static let newDriverAlloted = NSNotification.Name("newDriverAlloted")
}

