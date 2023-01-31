//
//  RideLevelInsuranceViewController.swift
//  Quickride
//
//  Created by Admin on 29/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


typealias nomineeDetailsCompletionHandler = (_ nomineeDetails : NomineeDetails?)->Void

class RideLevelInsuranceViewController : UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var insuranceDetailsView: UIView!
    
    @IBOutlet weak var insuranceTitleLabel: UILabel!
    
    @IBOutlet weak var insuranceSelectionBtn: UIButton!
    
    @IBOutlet weak var insuranceDescriptionText: UILabel!
    
    @IBOutlet weak var requestClaimBtn: UIButton!
    
    @IBOutlet weak var requestClaimBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewPolicyBtn: UIButton!
    
    @IBOutlet weak var viewPolicyWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var insuranceSetttingsBtn: UIButton!
    
    @IBOutlet weak var insurancePolicySettingsBtn: UIButton!
    
    @IBOutlet weak var insurancePolicySettingsBtnWidthConstraint: NSLayoutConstraint!
    
     @IBOutlet weak var insuranceSelectionBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var insuranceSelectionViewHeightConstraint: NSLayoutConstraint!
    
    var policyUrl : String?
    var isPolicyEnabled = true
    var passengerRideId : Double?
    var riderId : Double?
    var rideId : Double?
    var dismissHandler : DialogDismissCompletionHandler?
    var isInsuranceClaimed = false
    var insurancePoints : Double?
    
    func initializeDataBeforePresenting(policyUrl : String?,passengerRideId : Double?,riderId : Double?,rideId : Double?,isInsuranceClaimed : Bool,insurancePoints : Double?,dismissHandler : DialogDismissCompletionHandler?){
        self.policyUrl = policyUrl
        self.passengerRideId = passengerRideId
        self.riderId = riderId
        self.rideId = rideId
        self.isInsuranceClaimed = isInsuranceClaimed
        self.insurancePoints = insurancePoints
        self.dismissHandler = dismissHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if riderId != nil{
            insuranceSelectionBtn.isHidden = true
            insuranceDescriptionText.isHidden = true
            insuranceTitleLabel.text = Strings.trip_insurance
            if !isInsuranceClaimed{
              requestClaimBtn.isHidden = false
            }else{
              requestClaimBtn.isHidden = true
            }
            insuranceSelectionViewHeightConstraint.constant = 80
            insuranceSelectionBtnHeightConstraint.constant = 10
        }else{
            insuranceSelectionBtn.isHidden = false
            insuranceDescriptionText.isHidden = false
            insuranceTitleLabel.text = Strings.your_trip_is_insured
            insuranceSelectionBtn.setImage(UIImage(named: "insurance_tick"), for: .normal)
            insuranceDescriptionText.text = String(format: Strings.insurance_amount_text_after_applying, arguments: ["\u{20B9}"])
            requestClaimBtn.isHidden = true
            insuranceSelectionViewHeightConstraint.constant = 130
            insuranceSelectionBtnHeightConstraint.constant = 50
        }
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideLevelInsuranceViewController.backgroundViewTapped(_:))))
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: {
                        self.insuranceDetailsView.frame = CGRect(x: 0, y: -300, width: self.insuranceDetailsView.frame.width, height: self.insuranceDetailsView.frame.height)
                        self.insuranceDetailsView.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: insuranceDetailsView, cornerRadius: 20.0, corner1: .topLeft, corner2: .topRight)
    }
    
    @IBAction func claimBtnClicked(_ sender: Any) {
        if UserDataCache.getInstance()?.getNomineeDetails() != nil{
            let insuranceClaimViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InsuranceClaimViewController") as! InsuranceClaimViewController
            insuranceClaimViewController.initializeDataBeforePresenting(passengerRideId: self.passengerRideId, riderId: self.riderId, rideId: self.rideId, dismissHandler: {
                self.dismissHandler?()
                self.view.removeFromSuperview()
                self.removeFromParent()
            })
            
            let displayViewController = ViewControllerUtils.getCenterViewController()
            if let navigationController = displayViewController.navigationController{
                navigationController.view.addSubview(insuranceClaimViewController.view)
                navigationController.addChild(insuranceClaimViewController)
            }else{
                self.view.addSubview(insuranceClaimViewController.view)
                self.addChild(insuranceClaimViewController)
            }
           
        }else{
            self.moveToRidePreferences()
        }
        
    }
    
    @IBAction func insuranceSettingBtnClicked(_ sender: Any) {
        self.moveToRidePreferences()
    }
    
    func moveToRidePreferences(){
        
        self.view.removeFromSuperview()
        self.removeFromParent()
        
        let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.my_prefernces_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QRRidePreferencesViewController") as! QRRidePreferencesViewController
        
        if self.navigationController != nil{
            self.navigationController!.pushViewController(ridePreferencesViewController, animated: false)
        }else{
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: ridePreferencesViewController, animated: false)
        }
        
    }
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        if !self.isPolicyEnabled{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.cancelRideInsurance(passengerRideId: self.passengerRideId!, viewController: self, handler: { [weak self] (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self?.closeView()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
                
            })
        }else{
            self.closeView()
        }
   }
    
    func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {
            self.insuranceDetailsView.center.y += self.insuranceDetailsView.bounds.height
            self.insuranceDetailsView.layoutIfNeeded()
        }) { (value) in
            self.dismissHandler?()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    
    @IBAction func insuranceSelectionBtnClicked(_ sender: Any) {
        if isPolicyEnabled == false{
            isPolicyEnabled = true
            insuranceTitleLabel.text = Strings.your_trip_is_insured
            insuranceSelectionBtn.setImage(UIImage(named: "insurance_tick"), for: .normal)
            insuranceDescriptionText.text = String(format: Strings.insurance_amount_text_after_applying, arguments: ["\u{20B9}"])
            viewPolicyBtn.isHidden = false
            viewPolicyWidthConstraint.constant = 110
            requestClaimBtnWidthConstraint.constant = 100
            insuranceSetttingsBtn.isHidden = false
            insurancePolicySettingsBtn.isHidden = true
            insurancePolicySettingsBtnWidthConstraint.constant = 0
        }else{
            isPolicyEnabled = false
            insuranceTitleLabel.text = Strings.add_trip_insurance
            insuranceSelectionBtn.setImage(UIImage(named: "insurance_tick_disabled"), for: .normal)
            insuranceDescriptionText.text = String(format: Strings.insurance_amount_text, arguments: ["\u{20B9}"])
            viewPolicyBtn.isHidden = true
            viewPolicyWidthConstraint.constant = 0
            requestClaimBtnWidthConstraint.constant = 0
            insuranceSetttingsBtn.isHidden = true
            insurancePolicySettingsBtn.isHidden = false
            insurancePolicySettingsBtnWidthConstraint.constant = 100
        }
    }
    
    func displayView(){
        if ViewControllerUtils.getCenterViewController().navigationController != nil{
            ViewControllerUtils.getCenterViewController().view.addSubview(self.view)
            ViewControllerUtils.getCenterViewController().navigationController!.addChild(self)
            ViewControllerUtils.getCenterViewController().view.layoutIfNeeded()
        }else{
            ViewControllerUtils.getCenterViewController().view.addSubview(self.view)
            ViewControllerUtils.getCenterViewController().addChild(self)
            ViewControllerUtils.getCenterViewController().view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewPolicyBtnClicked(_ sender: Any) {
        if let url = policyUrl{
            FileUtils.downloadFileFromUrl(urlString: url, fileName: Strings.ride_level_insurance, viewController: self)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.download_failed)
        }
        
    }
    
    
}
