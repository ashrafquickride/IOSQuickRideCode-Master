//
//  EmergencyService.swift
//  Quickride
//
//  Created by QuickRideMac on 29/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import MessageUI

protocol EmergencyInitiator {
   func emergencyCompleted()
}


class EmergencyService : NSObject,CLLocationManagerDelegate,MFMessageComposeViewControllerDelegate {
    var isMessageComposerOpened = false
    var pendingContactsToProcess = [String]()
    var viewController : UIViewController?
    var presentLocation : Location?
    var lastKnownLocation : CLLocation?
    var locationManager : CLLocationManager = CLLocationManager()
    var urlToBeAttended : String?
    var noOfIntimations = 0
    var timerTask : Timer?
    var timeInterval : TimeInterval?
    
    init(viewController : UIViewController){
        super.init()
      let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences()
        self.viewController = viewController
        locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if ridePreferences?.locationUpdateAccuracy == 1{
            self.locationManager.distanceFilter = Double(AppConfiguration.MIN_DISTANCE_CHANGE_FOR_UPDATES_MEDIUM)
        }else if ridePreferences?.locationUpdateAccuracy == 2{
            self.locationManager.distanceFilter = Double(AppConfiguration.MIN_DISTANCE_CHANGE_FOR_UPDATES_HIGH)
        }
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            locationManager.requestLocation()
        }
        
    }
    
    func startEmergency(urlToBeAttended : String){
        
       AppDelegate.getAppDelegate().log.debug("startEmergency() \(urlToBeAttended)")
        self.urlToBeAttended = urlToBeAttended
        sendUserPresentLocationDetailsToDefaultEmergencyContactsAndUserEmergencyContact()
      
        
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        noOfIntimations = Int(clientConfiguration!.maxTimeEmergency/clientConfiguration!.timeDelayEmergency)
        if timeInterval != nil
        {
            timerTask = Timer.scheduledTimer(timeInterval: (timeInterval! * 60 * 1000)/1000, target: self, selector: #selector(EmergencyService.sendEmergencyContact), userInfo: nil, repeats: true)
        }
        else
        {
            timerTask = Timer.scheduledTimer(timeInterval: clientConfiguration!.timeDelayEmergency/1000, target: self, selector: #selector(EmergencyService.sendEmergencyContact), userInfo: nil, repeats: true)
            
        }
    }
    
    func stopEmergency()
    {
        if timerTask == nil
        {
            return
        }
        timerTask!.invalidate()
        timerTask = nil
        
    }

    @objc func sendEmergencyContact(){
       AppDelegate.getAppDelegate().log.debug("sendEmergencyContact()")
        noOfIntimations -= 1
        
        if noOfIntimations == 0{
            timerTask!.invalidate()
            let appDelegate = AppDelegate.getAppDelegate()
           let emergencyInitiator =  appDelegate.getEmergencyInitializer()
            if emergencyInitiator != nil{
                emergencyInitiator!.emergencyCompleted()
            }
        }else{
            sendUserPresentLocationDetailsToEmergencyConatct()
        }
    }
    
    func sendUserPresentLocationDetailsToEmergencyConatct(){
        AppDelegate.getAppDelegate().log.debug("sendUserPresentLocationDetailsToEmergencyConatct()")
      let securityPreferences = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences()
            if securityPreferences != nil && securityPreferences!.emergencyContact != nil && securityPreferences!.emergencyContact!.isEmpty == false{
                var contacts = [String]()
                contacts.append(EmergencyContactUtils.getFormattedEmergencyContactNumber(contactNumber: securityPreferences!.emergencyContact!))
                
                self.prepareLocationAndSendMessageToContacts(contacts: contacts)
                
            }
      
    }
    
    func sendUserPresentLocationDetailsToDefaultEmergencyContactsAndUserEmergencyContact(){
 AppDelegate.getAppDelegate().log.debug("sendUserPresentLocationDetailsToDefaultEmergencyContactsAndUserEmergencyContact()")
        var emergencyContacts = ConfigurationCache.getObjectClientConfiguration().defaultEmergencyContactList

        if emergencyContacts == nil{
            emergencyContacts = [String]()
        }
        let emergencyContact = UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences().emergencyContact
        if emergencyContact != nil && !emergencyContact!.isEmpty{
            emergencyContacts?.append(EmergencyContactUtils.getFormattedEmergencyContactNumber(contactNumber: emergencyContact!))
        }
        if emergencyContacts?.isEmpty == true{
            return
        }
        prepareLocationAndSendMessageToContacts(contacts: emergencyContacts!)
    }
    func prepareLocationAndSendMessageToContacts(contacts : [String]){
      AppDelegate.getAppDelegate().log.debug("prepareLocationAndSendMessageToContacts() \(contacts)")
        if lastKnownLocation == nil{
            sendEmergencyMessageToContacts(contacts: contacts)
        }else{
            if presentLocation == nil{
                LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.Emergency", coordinate: lastKnownLocation!.coordinate, handler: { (location, error) in
                    if UserDataCache.getInstance() == nil{
                        return
                    }
                    if location != nil{
                        self.presentLocation = location
                    }
                    self.sendEmergencyMessageToContacts(contacts: contacts)
                })
            }else{
                self.sendEmergencyMessageToContacts(contacts: contacts)
            }
        }
    }
    

    func sendEmergencyMessageToContacts( contacts : [String]){
      AppDelegate.getAppDelegate().log.debug("sendEmergencyMessageToContacts() \(contacts)")
        var emergencyContacts = contacts
        if isMessageComposerOpened == true{
            for contact in emergencyContacts{
                pendingContactsToProcess.append(contact)
            }
            return

        }
        if pendingContactsToProcess.isEmpty == false{
            for contact in pendingContactsToProcess{
                emergencyContacts.append(contact)
            }
        }
        let emergencyMessage = getEmergencyMessage()
            let messageViewConrtoller = MFMessageComposeViewController()
            
            if MFMessageComposeViewController.canSendText() {
                messageViewConrtoller.body = emergencyMessage
                messageViewConrtoller.recipients = emergencyContacts
                messageViewConrtoller.messageComposeDelegate = self
                ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: messageViewConrtoller, animated: false, completion: nil)
                isMessageComposerOpened = true
            }
        
    }
    func getEmergencyMessage() -> String{

      AppDelegate.getAppDelegate().log.debug("getEmergencyMessage()")
        var emergencyMessage = "\(UserDataCache.getInstance()!.getUserName()) \(QRSessionManager.getInstance()!.getCurrentSession().contactNo)"
        
        if presentLocation != nil {
            emergencyMessage = emergencyMessage+Strings.pull_stop
            emergencyMessage = emergencyMessage+Strings.last_known_location_is
            emergencyMessage = emergencyMessage+AppConfiguration.GOOGLE_MAPS_LOCATION_LINK
            emergencyMessage = emergencyMessage + "\(presentLocation!.latitude)"
            emergencyMessage = emergencyMessage + "\(presentLocation!.longitude)"
            emergencyMessage = emergencyMessage + "\(presentLocation!.completeAddress!)"
        }
        emergencyMessage = emergencyMessage+" \(Strings.at) \(NSDate())"
        if urlToBeAttended != nil && urlToBeAttended!.isEmpty == false{
            emergencyMessage = emergencyMessage+" "+Strings.you_can_track_the_rid_here+" "+urlToBeAttended!
        }
        return emergencyMessage
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        if lastKnownLocation != nil && locations.last!.distance(from: lastKnownLocation!) < 20{
            return
        }
        lastKnownLocation = locations.last
        presentLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled :
            UIApplication.shared.keyWindow?.makeToast( Strings.sending_sms_cancelled)
            controller.dismiss(animated: false, completion: nil)

        case .sent :
            UIApplication.shared.keyWindow?.makeToast( Strings.sms_sent)
            controller.dismiss(animated: false, completion: nil)

        case .failed :
            UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_failed)
            controller.dismiss(animated: false, completion: nil)

        default:
            break
        }
        isMessageComposerOpened = false

    }
    deinit {
        locationManager.delegate = nil
         timerTask?.invalidate()
    }
}
