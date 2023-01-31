//
//  CancelTaxiPoolViewController.swift
//  Quickride
//
//  Created by Ashutos on 7/4/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


class CancelTaxiPoolViewController: UIViewController {
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var popUpView: QuickRideCardView!
    @IBOutlet weak var cancelReasonTextView: UITextField!
    @IBOutlet weak var cancelReasonView: UIView!
    @IBOutlet weak var cancelReasonViewHeightConstarints: NSLayoutConstraint!
    @IBOutlet weak var cancelReasonShowingTableView: UITableView!
    @IBOutlet weak var cancelReasonTableViewHeightConstarints: NSLayoutConstraint!
    @IBOutlet weak var cancelBtn: QRCustomButton!
    @IBOutlet weak var feeMayApplyView: UIView!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var maxFeeLabel: UILabel!
    
    private var taxiPoolCancelReasonVM: TaxiPoolCancelReasonViewModel?
    private var isKeyBoardVisible = false
    
    func initializeDataBeforePresenting(taxiRide: TaxiRidePassenger?, completionHandler : rideCancellationTaxiPoolCompletionHandler?){
        taxiPoolCancelReasonVM = TaxiPoolCancelReasonViewModel(taxiRide:taxiRide,completionHandler: completionHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelReasonShowingTableView.rowHeight = UITableView.automaticDimension
        cancelReasonShowingTableView.delegate = self
        cancelReasonShowingTableView.dataSource = self
        self.cancelReasonShowingTableView.register(UINib(nibName: "TaxiPoolCancelReasonTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiPoolCancelReasonTableViewCell")
        taxiPoolCancelReasonVM?.prepareCancellationReasons()
        if taxiPoolCancelReasonVM?.isRequiredToShowFeeMayApplyView ?? false{
            taxiPoolCancelReasonVM?.getMaxCancellationFee(handler: { (maxFee) in
                if maxFee != 0{
                    self.maxFeeLabel.text = String(format: Strings.cancellation_max_fee, arguments: [String(maxFee)])
                }
                self.feeMayApplyView.isHidden = false
            })
        }else{
            feeMayApplyView.isHidden = true
        }
        setUpUI()
    }
    
    private func setUpUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.popUpView.center.y -= self.popUpView.bounds.height
            }, completion: nil)
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        cancelReasonViewHeightConstarints.constant = 0
        cancelReasonView.isHidden = true
        cancelReasonTableViewHeightConstarints.constant = CGFloat(((taxiPoolCancelReasonVM?.cancelReasonList.count ?? 0))*35 + 30)
        cancelReasonTextView.delegate = self
        cancelBtn.backgroundColor = .lightGray
        cancelBtn.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer) {
        closeView()
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func cancellationPolicyBtnPressed(_ sender: UIButton) {
        var url = ""
        var title = ""
        if taxiPoolCancelReasonVM?.taxiRide?.tripType == TaxiPoolConstants.TRIP_TYPE_OUTSTATION{
            url = AppConfiguration.outstation_taxi_cancel_url
            title = Strings.taxi_cancel_policy
        }else{
            if taxiPoolCancelReasonVM?.taxiRide?.getShareType() == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING{
                url = AppConfiguration.taxipool_cancel_url
                title = Strings.taxipool_cancel_policy
            }else{
                url = AppConfiguration.local_taxi_cancel_url
                title = Strings.taxi_cancel_policy
            }
        }
        let urlcomps = URLComponents(string :  url)
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: title, url: urlcomps!.url!, actionComplitionHandler: nil)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }
    }
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        if let text = taxiPoolCancelReasonVM?.cancelReason,let handler = taxiPoolCancelReasonVM?.rideCancellationTaxiPoolCompletionHandler{
            handler(text)
            closeView()
        }
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
}

extension CancelTaxiPoolViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxiPoolCancelReasonVM?.cancelReasonList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reasonCell = tableView.dequeueReusableCell(withIdentifier: "TaxiPoolCancelReasonTableViewCell", for: indexPath) as! TaxiPoolCancelReasonTableViewCell
        reasonCell.selectionStyle = .none
        reasonCell.setUpUI(selectedIndex: taxiPoolCancelReasonVM?.selectedIndex, index: indexPath.row, reasonText: taxiPoolCancelReasonVM?.cancelReasonList[indexPath.row] ?? "")
        if taxiPoolCancelReasonVM?.selectedIndex == indexPath.row, isRequiredToShowCallButtonForSelectedReason(index: indexPath.row) {
            reasonCell.callIconBtn.isHidden = false
            reasonCell.pleaseContact.isHidden = false
        }else {
            reasonCell.callIconBtn.isHidden = true
            reasonCell.pleaseContact.isHidden = true
        }
        
        return reasonCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taxiPoolCancelReasonVM?.selectedIndex = indexPath.row
        if indexPath.row == (taxiPoolCancelReasonVM?.cancelReasonList.count ?? 0) - 1 {//LastIndex
            cancelReasonView.isHidden = false
            cancelReasonViewHeightConstarints.constant = 40
            cancelReasonTextView.text = ""
            cancelBtn.backgroundColor = .lightGray
            cancelBtn.isUserInteractionEnabled = false
        } else {
            cancelReasonView.isHidden = true
            cancelReasonViewHeightConstarints.constant = 0
            taxiPoolCancelReasonVM?.cancelReason = taxiPoolCancelReasonVM?.cancelReasonList[indexPath.row]
            cancelBtn.backgroundColor = UIColor(netHex: 0x00B557)
            cancelBtn.isUserInteractionEnabled = true
        }
        cancelReasonShowingTableView.reloadData()
    }
    
    private func isRequiredToShowCallButtonForSelectedReason(index: Int) -> Bool {
        switch taxiPoolCancelReasonVM?.cancelReasonList [index] {
        case Strings.driver_refused_to_com_pickup, Strings.driver_asked_me_to_cancel, Strings.driver_not_reachable, Strings.driver_not_moving_towards_pickup_point, Strings.ETA_too_long, Strings.higher_fare:
            return true
        default :
            return false
        }
    }
}

extension CancelTaxiPoolViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            taxiPoolCancelReasonVM?.cancelReason = textField.text
            cancelBtn.backgroundColor = UIColor(netHex: 0x00B557)
            cancelBtn.isUserInteractionEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if currentCharacterCount > 18{
            cancelBtn.backgroundColor = UIColor(netHex: 0x00b557)
            cancelBtn.isUserInteractionEnabled = true
        }else{
            cancelBtn.backgroundColor = UIColor(netHex: 0xD3D3D3)
            cancelBtn.isUserInteractionEnabled = false
        }
        let newLength = currentCharacterCount + string.count - range.length
        if newLength > 250{
            return false
        }
        return true
    }
}
