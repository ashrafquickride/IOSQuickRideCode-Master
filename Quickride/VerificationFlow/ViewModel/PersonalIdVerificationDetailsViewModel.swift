//
//  PersonalIdVerificationDetailsViewModel.swift
//  Quickride
//
//  Created by Vinutha on 14/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class PersonalIdVerificationDetailsViewModel {
    
    //MARK: Properties
    var personalIdDetail: PersonalIdDetail?
    var responseError : ResponseError?
    var error : NSError?
    var frontDocImageURI: String?
    var backDocImageURI: String?
    
    //MARK: Initialiser
    func initialiseData(personalIdDetail: PersonalIdDetail) {
        self.personalIdDetail = personalIdDetail
    }
    
    //MARK: Methods
    func saveDocumentImage() {
        let queue = DispatchQueue.main
        let group = DispatchGroup()
        group.enter()
        queue.async {
            if let imageUri = self.personalIdDetail?.frontSideDocImageUri, let image = UIImage(contentsOfFile: imageUri) {
                let resizedImage = ImageUtils.RBResizeImage(image: image, targetSize: CGSize(width: 540, height: 540))
                ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: resizedImage), targetViewController: nil, completionHandler: {(responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                        self.frontDocImageURI = responseObject!["resultData"] as? String
                        self.responseError = nil
                        self.error = nil
                    } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        self.responseError = responseError
                        self.error = error
                    }else{
                        self.responseError = nil
                        self.error = error
                    }
                    group.leave()
                })
            } else {
                group.leave()
            }
        }
        group.enter()
        queue.async(group: group) {
            if let imageUri = self.personalIdDetail?.backSideDocImageUri, let image = UIImage(contentsOfFile: imageUri) {
                let resizedImage = ImageUtils.RBResizeImage(image: image, targetSize: CGSize(width: 540, height: 540))
                ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: resizedImage), targetViewController: nil, completionHandler: {(responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                        self.backDocImageURI = responseObject!["resultData"] as? String
                        self.responseError = nil
                        self.error = nil
                    } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                        
                        let responseError =  Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        self.responseError = responseError
                        self.error = error
                    }else{
                        self.responseError = nil
                        self.error = error
                    }
                    group.leave()
                })
            } else {
                group.leave()
            }
        }
        group.notify(queue: queue) {
            if self.responseError != nil || self.error != nil {
                ErrorProcessUtils.handleResponseError(responseError: self.responseError, error: self.error, viewController: nil)
                NotificationCenter.default.post(name: .personalIdDetailStoringFailed, object: nil)
            }
            else{
                self.storePersonalIdDetails()
            }
        }
    }
    
    private func storePersonalIdDetails() {
        var documentImage = frontDocImageURI
        if backDocImageURI != nil && documentImage != nil {
            documentImage! += ",\(String(describing: backDocImageURI))"
        }
        ProfileVerificationRestClient.storeGovtIDVerificationDetails(personalIdDetail: personalIdDetail!, documentImageUrl: documentImage) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                NotificationCenter.default.post(name: .personalIdDetailStored, object: nil)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                NotificationCenter.default.post(name: .personalIdDetailStoringFailed, object: nil)
            }
        }
    }
}
