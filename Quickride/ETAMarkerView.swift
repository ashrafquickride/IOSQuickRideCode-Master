
//
//  ETAMarkerView.swift
//  Quickride
//
//  Created by KNM Rao on 29/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ETAMarkerView: UIView {
  
  @IBOutlet var etaMarkerImage: UIImageView!

  @IBOutlet var backGroundView: UIView!
  
  @IBOutlet var etaLabel: UILabel!
  
  @IBOutlet var etaSubtitle: UILabel!

  func initializeViews(){
   
    
  }
  func setEtaTitle(title : String){
      etaLabel.text = title
    let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 7)!]
    let rect = etaLabel.text!.boundingRect(with: CGSize(width: self.frame.size.width - 20, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
    backGroundView.frame = CGRect(x: backGroundView.frame.origin.x, y: backGroundView.frame.origin.y, width: rect.width + 20, height: backGroundView.frame.height)
    }
  func setEta(etaDuration : Int?){
    if etaDuration == nil{
        etaLabel.text = "--"
        etaSubtitle.text = Strings.MINS
    }else{
      etaLabel.text = "\(etaDuration!)"
      etaSubtitle.text = Strings.MINS
    }
  }
}
