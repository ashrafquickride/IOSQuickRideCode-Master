//
//  LogOutTask.swift
//  Quickride
//
//  Created by QuickRideMac on 7/28/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import NetCorePush
import ObjectMapper

class LogOutTask {
  var viewController : UIViewController?
  init(viewController : UIViewController){
    self.viewController = viewController
  }
  func userLogOutTask()
  {
    AppDelegate.getAppDelegate().log.debug("logout()")
    NetCoreInstallation.sharedInstance().netCorePushLogout(nil)
    NetCoreSharedManager.sharedInstance().clearIdentity()
    self.removeIOSDeviceKey()
    SessionManagerController.sharedInstance.clearUserSession()
    UserMessageTopicListener().unSubscribeToProfileUpdateTopic()
    NotificationStore.getInstance().clearUserSession()
    ContactPersistenceHelper.clearAllContacts()
    UserCoreDataHelper.clearRecentLocations()
    MyRoutesCache.clearCache()
    DispatchQueue.main.async(execute: {
        ConversationCachePersistenceHelper.clearData()
        UserGroupChatCache.clearUserSession()
    })
    EventServiceStore.getInstance().clearUniqueIDSFromPersistence()
    self.handleLogFiles()
    UserRestClient.getContactNoForDeviceId(deviceId: DeviceUniqueIDProxy().getDeviceUniqueId() ?? "", appName: AppConfiguration.APP_NAME) { (responseObject, error) in
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
            UserDataCache.contactNo = responseObject!["resultData"] as? Double
        }
    }
    GCDUtils.GlobalMainQueue.async() { () -> Void in
        let appDelegate = UIApplication.shared.delegate
        
        appDelegate?.window!!.rootViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "startcontroller")
        
    }
  }
  
    func handleLogFiles() {
        let cacheDirectory: NSURL = {
            let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            return urls[urls.endIndex - 1] as NSURL
        }()
        let logPathBackup = cacheDirectory.appendingPathComponent(AppDelegate.logFileName_Backup)
        let data = NSData(contentsOf:  logPathBackup!)
        if data != nil{
            do {
                try FileManager.default.removeItem(at: logPathBackup!)
            }catch{
                print(error)
            }
        }
        let logPath = cacheDirectory.appendingPathComponent(AppDelegate.logFileName)
        let logData = NSData(contentsOf:  logPath!)
        if logData != nil{
            do {
                try FileManager.default.removeItem(at: logPath!)
            }catch{
                print(error)
            }
        }
        
    }
  
  func removeIOSDeviceKey(){
    var requestbody : [String : String] = [String : String]()
    DeviceRegistrationHelper.isDeviceTokenRegistered = false
    requestbody["phone"] = QRSessionManager.getInstance()!.getUserId()
    requestbody["clientIosKey"] =  nil
    UserRestClient.saveDeviceToken(targetViewController: self.viewController, requestBody: requestbody, completionHandler: { (registrationResponseObject, registrationError) -> Void in
    })
  }
}
