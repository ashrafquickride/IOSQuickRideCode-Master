//
//  ChangeLocationGuideLineViewController.swift
//  Quickride
//
//  Created by KNM Rao on 20/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ChangeLocationGuideLineViewController: UIViewController {
  
  
  @IBOutlet var changeLocationLabel: UIButton!
  
  @IBOutlet var changeLocationInfo: UILabel!
  
  @IBOutlet var gotItButton: UIButton!
  var titleString : String?
  var descriptionString: String?
  var presentView : UIView?
  
  
  func initializeDataBeforePresenting(title : String,description : String){
    titleString = title
    descriptionString = description
  }
  
  override func viewDidLoad(){
    handleBrandingChanges()
    changeLocationLabel.setTitle(titleString, for: .normal)
    ViewCustomizationUtils.addCornerRadiusToView(view: changeLocationLabel, cornerRadius: 5.0)
    changeLocationInfo.text = descriptionString
    ViewCustomizationUtils.addCornerRadiusToView(view: gotItButton, cornerRadius: 5.0)
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChangeLocationGuideLineViewController.dismissView(_:))))
  }
  
    func handleBrandingChanges()
    {
        gotItButton.backgroundColor = Colors.gotItBtnBackGroundColor
        
    }
    @objc func dismissView(_ gesture : UITapGestureRecognizer){
    presentView?.removeFromSuperview()
  }
  @IBAction func gotItButtonClicked(_ sender: Any) {
    presentView?.removeFromSuperview()
  }
}
