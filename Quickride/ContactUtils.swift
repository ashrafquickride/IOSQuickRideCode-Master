//
//  ContactUtils.swift
//  Quickride
//
//  Created by HK on 18/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Contacts

class ContactUtils {
    
    static func getRidePartnerContacts() -> [Contact]{
        guard let ridePartners = UserDataCache.getInstance()?.getRidePartnerContacts() else { return [Contact]()}
        var ridePartnerContacts = [Contact]()
        for ridePartner in ridePartners{
            if UserDataCache.getInstance()?.isBlockedUser(userId: Double(ridePartner.contactId ?? "") ?? 0) == true{
                continue
            }
            if ridePartner.contactNo != nil && ridePartner.contactType == Contact.RIDE_PARTNER{
                ridePartnerContacts.append(ridePartner)
            }
        }
        ridePartnerContacts.sort(by: { $0.contactName < $1.contactName})
        return ridePartnerContacts
    }
    
    static func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
        case .denied,.restricted:
            showCameraPermissionReason(isRequiredToGoSettings: true, completionHandler: completionHandler)
        case .notDetermined:
            showCameraPermissionReason(isRequiredToGoSettings: false, completionHandler: completionHandler)
        default:
            completionHandler(false)
        }
    }
    
    static func showCameraPermissionReason(isRequiredToGoSettings: Bool,completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        let permissionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AppPermissionsConfirmationViewController") as! AppPermissionsConfirmationViewController
        permissionVC.showConfirmationView(permissionType: .Contacts,isRequiredToGoSettings: isRequiredToGoSettings) { (isConfirmed) in
            if isConfirmed{
                CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                    if !access {
                        DispatchQueue.main.async{ () -> Void in
                            completionHandler(access)
                        }
                    }
                })
            }else{
                completionHandler(false)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: permissionVC)
    }
    
}
