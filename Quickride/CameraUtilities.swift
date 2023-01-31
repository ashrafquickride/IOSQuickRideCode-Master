//
//  CameraUtilities.swift
//  Quickride
//
//  Created by KNM Rao on 26/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import AVFoundation
class CameraUtilities {
  let cameraPermissionRequested = false
  
  static func checkCameraPermissionAndAlert(viewController : UIViewController)-> Bool{
    if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized
    {
     return true
      
    }
    else
    {
        MessageDisplay.displayErrorAlertWithAction(title: Strings.camera_permission_title, isDismissViewRequired : false, message1: Strings.camera_permission_message, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle : Strings.dont_allow_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
            if Strings.ok_caps == result{
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if settingsUrl != nil && UIApplication.shared.canOpenURL(settingsUrl! as URL){
                    UIApplication.shared.open(settingsUrl! as URL, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.enableCamerafromSettings)
                }
            }
        })
        return false
    }
    
  }
  
}
