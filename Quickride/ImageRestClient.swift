//
//  ImageRestClient.swift
//  Quickride
//
//  Created by KNM Rao on 25/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Alamofire

public class ImageRestClient{
  
  // A generic defination for completion handler closure
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  
  private static let baseServerUrl : String = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath
  private static let saveImage : String = "QRImage"
  private static let updateImage : String = "QRImage/update"
  private static let USER_PHOTO_STRING = "photo"

  
  public static func saveImage(photo : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("saveImage()")
    var params = [String : String]()
    params[USER_PHOTO_STRING] = photo
    let saveImageUrl = baseServerUrl + saveImage
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: saveImageUrl, params: params, requestType: .post, encodingType: URLEncoding.httpBody, targetViewController: targetViewController, handler: completionHandler)
    
  }
    public static func updateImage(photoDictionary : [String : String], targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("updateImage()")
        let updateImageUrl = baseServerUrl + updateImage
        HttpUtils.postJSONRequestWithBody(url: updateImageUrl, targetViewController: targetViewController, handler: completionHandler, body: photoDictionary)
    }
}
