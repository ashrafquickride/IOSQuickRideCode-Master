//
//  ContactPersistenceHelper.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 02/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class  ContactPersistenceHelper {
    static let contactGender : String = "contactGender"
    static let contactId : String = "contactId"
    static let contactImageURI : String = "contactImageURI"
    static let contactName : String = "contactName"
    static let contactNo : String = "contactNo"
    static let contactType : String = "contactType"
    static let supportCall : String = "supportCall"
    static let userId : String = "userId"
    static let refreshedDate : String = "refreshedDate"
    static let enableChatAndCall : String = "enableChatAndCall"
    
    static let contact_entity = "Contact"
    
    static func storeRidePartnerContact(contact : Contact)
    {
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let entity = NSEntityDescription.entity(forEntityName: ContactPersistenceHelper.contact_entity, in: managedContext)
            let ridePartnersContactObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            ridePartnersContactObject.setValue(contact.userId, forKey: userId)
            ridePartnersContactObject.setValue(contact.contactId, forKey: contactId)
            ridePartnersContactObject.setValue(contact.contactImageURI, forKey: contactImageURI)
            ridePartnersContactObject.setValue(contact.contactGender, forKey: contactGender)
            ridePartnersContactObject.setValue(contact.contactNo, forKey: contactNo)
            ridePartnersContactObject.setValue(contact.contactType, forKey: contactType)
            ridePartnersContactObject.setValue(contact.supportCall, forKey: supportCall)
            ridePartnersContactObject.setValue(contact.contactName, forKey: contactName)
            ridePartnersContactObject.setValue(NSDate(), forKey: refreshedDate)
            ridePartnersContactObject.setValue(contact.enableChatAndCall, forKey: enableChatAndCall)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
    static func getAllRidePartnersContacts() -> [String: Contact]
    {
        AppDelegate.getAppDelegate().log.debug("")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ContactPersistenceHelper.contact_entity)
        var returnRidePartnerContactObject = [String: Contact]()
        let ridePartnersContactObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        for i in 0 ..< ridePartnersContactObject.count {
            let contact : Contact = Contact()
            contact.userId = ridePartnersContactObject[i].value(forKey: userId) as? Double
            contact.contactId = ridePartnersContactObject[i].value(forKey: contactId) as? String
            if let contactGender = ridePartnersContactObject[i].value(forKey: contactGender) as? String{
               contact.contactGender = contactGender
            }
            if let contactName = ridePartnersContactObject[i].value(forKey: contactName) as? String{
                contact.contactName = contactName
            }
            contact.contactImageURI = ridePartnersContactObject[i].value(forKey: contactImageURI) as? String
            contact.contactNo = ridePartnersContactObject[i].value(forKey: contactNo) as? Double
            if let contactType = ridePartnersContactObject[i].value(forKey: contactType) as? String{
                contact.contactType = contactType
            }
            if let supportCall = ridePartnersContactObject[i].value(forKey: supportCall) as? String{
                contact.supportCall = supportCall
            }
            contact.refreshedDate = ridePartnersContactObject[i].value(forKey: refreshedDate) as? NSDate
            if let enableChatAndCall = ridePartnersContactObject[i].value(forKey: enableChatAndCall) as? Bool{
                contact.enableChatAndCall = enableChatAndCall
            }
            if let contactId = contact.contactId{
                returnRidePartnerContactObject[contactId] = contact
            }
        }
        return returnRidePartnerContactObject
    }
    static func executeFetchResult(managedContext : NSManagedObjectContext, fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> [NSManagedObject]{
        AppDelegate.getAppDelegate().log.debug("executeFetchResult()")
        var fetchResults = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        return fetchResults
    }
    
    static func deleteContact(contactId : String){
        
        AppDelegate.getAppDelegate().log.debug("\(contactId)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ContactPersistenceHelper.contact_entity)
                fetchRequest.predicate = NSPredicate(format: "\(ContactPersistenceHelper.contactId) = %@",argumentArray: [contactId])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func clearAllContacts()
    {
        AppDelegate.getAppDelegate().log.debug("")
        let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
        managedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ContactPersistenceHelper.contact_entity)
                fetchRequest.includesPropertyValues = false
                let deleteRequest = NSBatchDeleteRequest(fetchRequest : fetchRequest)
                    
                try managedObjectContext.execute(deleteRequest)
                CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
            } catch {
                AppDelegate.getAppDelegate().log.error("clearAllContacts() ,error : \(error)")
            }
        }
    }
}
