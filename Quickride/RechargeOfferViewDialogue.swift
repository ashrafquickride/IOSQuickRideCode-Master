//
//  RechargeOfferViewDialogue.swift
//  Quickride
//
//  Created by KNM Rao on 09/12/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit


class RechargeOfferViewDialogue : ModelViewController {
  
  @IBOutlet weak var backgroundView: UIView!
  
  @IBOutlet weak var offerTitle: UILabel!
  
  @IBOutlet weak var offerImage: UIImageView!
  
  @IBOutlet weak var offerDescription: UILabel!
  
  @IBOutlet weak var alertview: UIView!
  
  @IBOutlet weak var offerMessage: UILabel!
  
  var offer : Offer?
  
  func initialize(offer:Offer)
  {
    self.offer = offer
  }
  
  override func viewDidLoad(){
    super.viewDidLoad()
    ViewCustomizationUtils.addCornerRadiusToView(view: alertview, cornerRadius: 7.0)
    
    if offer!.offerImageUri != nil && offer!.offerImageUri!.isEmpty == false
    {
      offerImage.isHidden = false
        ImageCache.getInstance().setImageToView(imageView: offerImage, imageUrl: offer!.offerImageUri!,placeHolderImg: nil,imageSize: ImageCache.ORIGINAL_IMAGE)
    }else{
      offerImage.isHidden = true
    }
    
    if offer!.offerTitle != nil && offer!.offerTitle!.isEmpty == false
    {
      offerTitle.isHidden = false
      offerTitle.text = offer?.offerTitle!
      offerTitle.adjustsFontSizeToFitWidth = true
    }else{
      offerTitle.isHidden = true
    }
    
    if offer!.offerMessage != nil  && offer!.offerMessage!.isEmpty == false{
      offerMessage.isHidden = false
      offerMessage.text = offer!.offerMessage!
    }else{
      offerMessage.isHidden = true
    }
    
    if offer!.termsAndCondtions != nil && offer!.termsAndCondtions!.isEmpty == false
    {
      offerDescription.isHidden = false
      offerDescription.text = offer!.termsAndCondtions!
    }else{
      offerDescription.isHidden = true
    }
    backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RechargeOfferViewDialogue.backGroundViewTapped(_:))))
  }
  
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
  
}





