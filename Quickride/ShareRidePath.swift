//
//  ShareRidePath.swift
//  Quickride
//
//  Created by QuickRideMac on 04/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Alamofire
import MessageUI
import ObjectMapper


public typealias receiveURL = (_ url : String) -> Void

class ShareRidePath :NSObject, MFMessageComposeViewControllerDelegate{
    
    static let SHARE_WHATSAPP="WHATSAPP"
    static let SHARE_SMS="SMS"
    var viewController : UIViewController?
    var rideId: String?

  
    init(viewController : UIViewController,rideId : String){
        self.viewController = viewController
        self.rideId = rideId
    }
  override init() {
    
  }
    
    func showShareOptions(){
      AppDelegate.getAppDelegate().log.debug("showShareOptions()")
        prepareRideTrackCoreURL(){ (url) -> Void in
            if !url.isEmpty {
                self.shareReferralContext(urlString: url,viewController: UIApplication.shared.keyWindow!.rootViewController!)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: UIApplication.shared.keyWindow!.rootViewController!, handler: nil)
            }
        }
    }
    
    func shareReferralContext(urlString : String, viewController: UIViewController){
        let message = prepareMessageForShare(rideTrackURL: urlString)
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            } else {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        viewController.present(avc, animated: true, completion: nil)
    }
    
    func shareThroughWhatsApp(rideTrackURL : String)
    {
      AppDelegate.getAppDelegate().log.debug("shareThroughWhatsApp()")
        if QRReachability.isConnectedToNetwork() == false{
            ErrorProcessUtils.displayNetworkError(viewController: viewController!, handler: nil)
            return
        }
        let urlStringEncoded = StringUtils.encodeUrlString(urlString: rideTrackURL)
        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded)")
        
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else{
            MessageDisplay.displayAlert(messageString: Strings.can_not_find_whatsup, viewController: viewController!,
                                        handler: nil)

        }
    }
    
    
    func message(phoneNumber:String?, message : String,vc : UIViewController) {
        let messageViewConrtoller = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            if phoneNumber != nil{
                messageViewConrtoller.recipients = [phoneNumber!]
            }
            messageViewConrtoller.messageComposeDelegate = self
            vc.present(messageViewConrtoller, animated: false, completion: nil)
            
        }
    }
    func prepareMessageForShare( rideTrackURL : String) -> String{
      AppDelegate.getAppDelegate().log.debug("regularRideEditAlertAction()")
        return Strings.sharepath_msg+" "+rideTrackURL
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func prepareRideTrackCoreURL(handler : @escaping receiveURL){
    AppDelegate.getAppDelegate().log.debug("prepareRideTrackCoreURL()")
        let pwaPath = AppConfiguration.pwaServerUrl + AppConfiguration.PWA_serverPort
        let longUrl = pwaPath + "/#/share?rideId=" + self.rideId!
        var googleAPIConfiguration = ConfigurationCache.getInstance()?.getGoogleAPIConfiguration()
        if googleAPIConfiguration != nil{
            googleAPIConfiguration = GoogleAPIConfiguration()
        }
        let shortDynamicLinkParams = ShortDynamicLinkParams()
        let dynamicLinkInfo = DynamicLinkInfo()
        dynamicLinkInfo.dynamicLinkDomain = googleAPIConfiguration!.googleDynamicLinksDomain
        dynamicLinkInfo.link = longUrl
        shortDynamicLinkParams.dynamicLinkInfo = dynamicLinkInfo
        
        var request = URLRequest(url: URL(string: "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key="+googleAPIConfiguration!.googleDynamicLinksWebApiKey)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let pjson = shortDynamicLinkParams.toJSONString(prettyPrint: false)
        let data = (pjson?.data(using: .utf8))! as Data
        var params = [String : String]()
        params["long_url"] = longUrl
        params["data"] = pjson
        request.httpBody = data
        Alamofire .request(request).responseJSON { (response) in
            if (response.result.error != nil) {
                handler(longUrl)
            }
            else{
                if let result = Mapper<ShortDynamicLinkResult>().map(JSONObject: response.result.value){
                    if let error = result.error{
                        APIFailureHandler.validateResponseAndReportFailure(errorCode: error.status, errorMessage: error.message, apiKey: googleAPIConfiguration!.googleDynamicLinksWebApiKey, apiName: APIFailureReport.DYNAMIC_LINKS_API, params: params)
                    }
                    if result.shortLink != nil{
                        handler(result.shortLink!)
                    }else{
                        handler(longUrl)
                    }
                }else{
                    handler(longUrl)
                }
            }
        }
    }
}
