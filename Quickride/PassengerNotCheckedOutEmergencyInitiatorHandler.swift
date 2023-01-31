//
//  PassengerNotCheckedOutEmergencyInitiatorHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 4/18/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerNotCheckedOutEmergencyInitiatorHandler: NotificationHandler,EmergencyInitiator,SelectContactDelegate {
  
  static let MAX_TIME_IN_MINS_TO_CONSIDER_EMERGENCY_EXHAUSTED : Int = 5
  static let MAX_TIME_TO_WAIT_FOR_RESPONSE_OF_EMERGENCY_INITIATION_IN_MINS : Double = 3
  var riderRideId : String?
  var emergencyInitiatedTime : String?
  var timeInterval : TimeInterval?
  var emergencyService : EmergencyService?
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard  let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let messageObjJson = clientNotification.msgObjectJson, let notificationDynamicDataObj = Mapper<PassengerNotCheckedOutEmergencyInitiatorDynamicData>().map(JSONString: messageObjJson) else {
                return handler(false)
            }
           
            self.riderRideId = notificationDynamicDataObj.riderRideId!
            self.emergencyInitiatedTime = notificationDynamicDataObj.emergencyTime
           
            if self.riderRideId == nil || self.emergencyInitiatedTime == nil{
                return handler(false)
            }
            let ride = myActiveRidesCache.getPassengerRideByRiderRideId(riderRideId: Double(self.riderRideId!)!)
            if ride != nil && ((DateUtils.getDateFromString(date: self.emergencyInitiatedTime, dateFormat: DateUtils.DATE_FORMAT_ddMMyyyyHHmm)?.addMinutes(minutesToAdd: PassengerNotCheckedOutEmergencyInitiatorHandler.MAX_TIME_IN_MINS_TO_CONSIDER_EMERGENCY_EXHAUSTED))?.getTimeStamp())! >= DateUtils.getCurrentTimeInMillis()
            {
                self.timeInterval = PassengerNotCheckedOutEmergencyInitiatorHandler.MAX_TIME_TO_WAIT_FOR_RESPONSE_OF_EMERGENCY_INITIATION_IN_MINS
                self.checkForTheEmergencyContact()
               handler(true)
            }
            handler(false)
        }

    }
  
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
    ContainerTabBarViewController.indexToSelect = 1
     let centerNavigationController = UINavigationController(rootViewController: routeViewController)
    AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController

  }
  override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
    
    let dynamicParams : String? = userNotification.msgObjectJson
    if (dynamicParams != nil) {
      let notificationDynamicDataObj = Mapper<PassengerNotCheckedOutEmergencyInitiatorDynamicData>().map(JSONString: dynamicParams!)! as PassengerNotCheckedOutEmergencyInitiatorDynamicData
      self.riderRideId = notificationDynamicDataObj.riderRideId!
    }
    checkForTheEmergencyContact()
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
    ContainerTabBarViewController.indexToSelect = 1
     let centerNavigationController = UINavigationController(rootViewController: routeViewController)
    AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController

  }
  override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
    if emergencyService != nil{
      emergencyService!.stopEmergency()
    }
    super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
  }
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.yes
  }
  override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.no
  }
  
  func checkForTheEmergencyContact(){
    let emergencyContactNo = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
    if emergencyContactNo == nil || emergencyContactNo!.isEmpty {
      self.navigateToEmergencyContactSelection()
    }else{
      self.initiateEmergency()
    }
  }
  override func getParams(notification: UserNotification) -> NSDictionary {
    var params = [String : String]()
    params[Ride.FLD_RIDER_RIDE_ID] = notification.msgObjectJson
    return params as NSDictionary
  }
  func navigateToEmergencyContactSelection(){
    let selectContactViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SelectContactViewController") as! SelectContactViewController
    selectContactViewController.initializeDataBeforePresenting(selectContactDelegate: self, requiredContacts: Contacts.mobileContacts)
    selectContactViewController.modalPresentationStyle = .overFullScreen
    ViewControllerUtils.presentViewController(currentViewController: nil,viewControllerToBeDisplayed: selectContactViewController, animated: false, completion: nil)
  }
  func selectedContact(contact: Contact) {
    
    let emergencyContact = EmergencyContactUtils.getEmergencyContactNumberWithName(contact: contact)
    UserDataCache.getInstance()?.updateUserProfileWithTheEmergencyContact(emergencyContact: emergencyContact,viewController : ViewControllerUtils.getCenterViewController())
    initiateEmergency()
  }
  
  func initiateEmergency(){
    
    AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: self)
    
    self.emergencyService =  EmergencyService(viewController: ViewControllerUtils.getCenterViewController())
    if self.timeInterval != nil
    {
      self.emergencyService!.timeInterval = PassengerNotCheckedOutEmergencyInitiatorHandler.MAX_TIME_TO_WAIT_FOR_RESPONSE_OF_EMERGENCY_INITIATION_IN_MINS
    }
    let shareRidePath = ShareRidePath(viewController: ViewControllerUtils.getCenterViewController(), rideId: riderRideId!)
    shareRidePath.prepareRideTrackCoreURL { (url) in
      self.emergencyService!.startEmergency(urlToBeAttended: url)
    }
  }
  func emergencyCompleted() {
    
    AppDelegate.getAppDelegate().setEmergencyInitializer(emergencyInitiator: nil)
  }
}

public class PassengerNotCheckedOutEmergencyInitiatorDynamicData : NSObject, Mappable {
  var riderRideId : String?
  var emergencyTime : String?
  
  public required init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    riderRideId <- map[Ride.FLD_RIDER_RIDE_ID]
    emergencyTime <- map["emergencyTime"]
  }
    public override var description: String { 
        return "riderRideId: \(String(describing: self.riderRideId))," + "emergencyTime: \(String(describing: self.emergencyTime)),"
    }
}
