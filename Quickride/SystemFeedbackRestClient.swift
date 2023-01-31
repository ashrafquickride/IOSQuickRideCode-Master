//
//  SystemFeedbackRestClient.swift
//  Quickride
//
//  Created by KNM Rao on 05/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class SystemFeedbackRestClient {
  
  public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
  
  public static func submitSystemFeedback(phoneNumber: String, currentTimeStamp : String, userRating : String, comments: String, uiViewController: UIViewController, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("submitSystemFeedback() \(phoneNumber) \(currentTimeStamp) \(userRating) \(comments)")
    let  submitSystemFeedbackUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userSystemFeedback
    var params = [String : String]()
    params[SystemFeedback.FLD_FEEDBACK_BY] = phoneNumber
    params[SystemFeedback.FLD_FEEDBACK_TIME] = currentTimeStamp
    
    params[SystemFeedback.FLD_RATING] = userRating
    
    params[SystemFeedback.FLD_EXTRA_INFO] = comments
    HttpUtils.putRequestWithBody(url: submitSystemFeedbackUrl, targetViewController: uiViewController, handler: completionHandler, body: params)
  }
  
  
  public static func postSystemFeedbackWithBody(targetViewController: UIViewController, body : Dictionary<String, String> , completionHandler:  @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("postSystemFeedbackWithBody()")
    let postSystemFeedbackWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.systemFeedback
       HttpUtils.postRequestWithBody(url: postSystemFeedbackWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
  public static func postUserFeedbackWithBody(targetViewController: UIViewController, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("postUserFeedbackWithBody()")
    let postUserFeedbackWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + AppConfiguration.saveUserFeedback
     HttpUtils.postRequestWithBody(url: postUserFeedbackWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
  }
  
}
