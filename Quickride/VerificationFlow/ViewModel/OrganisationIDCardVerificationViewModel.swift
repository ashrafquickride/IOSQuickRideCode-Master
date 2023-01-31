//
//  OrganisationIDCardVerificationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OrganisationIDCardVerificationViewModel {
    
    //MARK: Properties
    var frontSideImageUrl: String?
    var backSideImageUrl: String?
    var isCancelClicked = false
    var isFrontSide = false
    
    static let KEY_FAILED = "FAILED"
    static let KEY_SUCCESS = "SUCCESS"
    
    func checkAndSaveIdCardImage(isFrontSide: Bool, actualImage: UIImage, viewController: UIViewController){
        let image = ImageUtils.RBResizeImage(image: actualImage, targetSize: CGSize(width: 540, height: 540))
        
        ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: viewController, completionHandler: {(responseObject, error) in
            if self.isCancelClicked {
                return
            }
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if isFrontSide {
                    self.frontSideImageUrl = responseObject!["resultData"] as? String
                } else {
                    self.backSideImageUrl = responseObject!["resultData"] as? String
                }
                var userInfo = [String: Bool]()
                userInfo[OrganisationIDCardVerificationViewModel.KEY_SUCCESS] = isFrontSide
                NotificationCenter.default.post(name: .organisationIdImageSavingSucceded, object: nil, userInfo: userInfo)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                var userInfo = [String: Bool]()
                userInfo[OrganisationIDCardVerificationViewModel.KEY_FAILED] = isFrontSide
                NotificationCenter.default.post(name: .organisationIdImageSavingFailed, object: nil, userInfo: userInfo)
            }
        })
    }
    
    func initiateCompanyIdVerification(viewController: UIViewController) {
        if frontSideImageUrl == nil || backSideImageUrl == nil  {
           UIApplication.shared.keyWindow?.makeToast( "Please upload documents to proceed")
            return
        }
        QuickRideProgressSpinner.startSpinner()
        ProfileVerificationRestClient.initiateCompanyIdVerification(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", frontSideImageUrl: frontSideImageUrl ?? "", backSideImageUrl: backSideImageUrl ?? "") { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UserDataCache.getInstance()?.companyIdVerificationData = responseObject!["resultData"] as? CompanyIdVerificationData
                NotificationCenter.default.post(name: .organisationIdVerificationInitiated, object: nil)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
}
