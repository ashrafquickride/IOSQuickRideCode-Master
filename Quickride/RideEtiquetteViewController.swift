//
//  RideEtiquetteViewController.swift
//  Quickride
//
//  Created by iDisha on 09/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideEtiquetteViewController: UIViewController {
    
    @IBOutlet var imageViewEtiquette: UIImageView!
    
    @IBOutlet var buttonSelect: UIButton!
    
    @IBOutlet var buttonIAgree: UIButton!
    
    @IBOutlet var viewEtiuetteAgree: UIView!
    
    @IBOutlet var etiquetteDetailView: UIView!
    
    @IBOutlet var viewEtiuetteLoading: UIView!
    
    @IBOutlet var buttonIAgreeTopSpaceConstraint: NSLayoutConstraint!
    
    var rideEtiquette: RideEtiquette?
    var isUserAgreed: Bool?
    var isFromSignUpFlow: Bool?
    
    func initializeView(rideEtiquette: RideEtiquette, isFromSignUpFlow: Bool){
        self.rideEtiquette = rideEtiquette
        self.isFromSignUpFlow = isFromSignUpFlow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewEtiuetteAgree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RideEtiquetteViewController.viewIAgreeTapped(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        viewEtiuetteLoading.isHidden = false
        self.isUserAgreed = false
        CustomExtensionUtility.changeBtnColor(sender: self.buttonIAgree, color1: UIColor.lightGray, color2: UIColor.lightGray)
        self.buttonIAgree.isUserInteractionEnabled = false
        ImageCache.getInstance().getImageFromCache(imageUrl: self.rideEtiquette!.imageUri!, imageSize: ImageCache.ORIGINAL_IMAGE) { (image, imageURI) in
            self.viewEtiuetteLoading.isHidden = true
            self.imageViewEtiquette.image = image?.roundedCornerImage
            self.isUserAgreed = true
            CustomExtensionUtility.changeBtnColor(sender: self.buttonIAgree, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            self.buttonIAgree.isUserInteractionEnabled = true
            self.buttonSelect.setImage(UIImage(named: "ride_tick"), for: .normal)
            self.buttonIAgree.isHidden = false
            if self.rideEtiquette!.severity == RideEtiquette.SEVERITY_LOW{
                self.buttonIAgreeTopSpaceConstraint.constant = 60
                self.viewEtiuetteAgree.isHidden = true
                self.buttonIAgree.setTitle(Strings.continue_text_caps, for: .normal)
            }
            else{
                self.buttonIAgreeTopSpaceConstraint.constant = 100
                self.viewEtiuetteAgree.isHidden = false
                self.buttonIAgree.setTitle("I AGREE", for: .normal)
            }
        }
        ViewCustomizationUtils.addBorderToView(view: buttonSelect, borderWidth: 1.0, color: UIColor(netHex: 0x707070))
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: etiquetteDetailView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
    }
    
    @objc func viewIAgreeTapped(_ gesture: UITapGestureRecognizer){
        if isUserAgreed! {
            isUserAgreed = false
            buttonSelect.setImage(nil, for: .normal)
            CustomExtensionUtility.changeBtnColor(sender: self.buttonIAgree, color1: UIColor.lightGray, color2: UIColor.lightGray)
            buttonIAgree.isUserInteractionEnabled = false
        }
        else{
            isUserAgreed = true
            buttonSelect.setImage(UIImage(named: "ride_tick"), for: .normal)
            CustomExtensionUtility.changeBtnColor(sender: self.buttonIAgree, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            buttonIAgree.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func buttonAgreeTapped(_ sender: Any) {
        if isUserAgreed == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.click_checkbox_to_agree, point: CGPoint(x: self.view.frame.size.width/2, y: self.buttonIAgree.center.y + 50), title: nil, image: nil, completion: nil)
            return
        }
        UserRestClient.updateDisplayedRideEtiquette(userId: QRSessionManager.getInstance()?.getUserId(), etiquetteId: StringUtils.getStringFromDouble(decimalNumber: rideEtiquette!.id), targetViewController: self) { (responseObject, error) in
            
        }
        SharedPreferenceHelper.storeRideEtiquette(rideEtiquette: nil)
        RideManagementUtils.NavigateToRespectivePage(oldViewController: self, handler: nil)
        
    }
    
}
