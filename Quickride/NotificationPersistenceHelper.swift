//
//  NotificationPersistenceHelper.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 21/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class NotificationPersistenceHelper{
    
    static let notificationId : String = "notificationId"
    static let time : String  = "time"
    static let type : String = "type"
    static let priority : String = "priority"
    static let msgClassName : String = "msgClassName"
    static let msgObjectJson : String = "msgObjectJson"
    static let groupName : String = "groupName"
    static let groupValue : String = "groupValue"
    static let title : String = "title"
    static let descriptions : String = "descriptions"
    static let iconUri : String = "iconUri"
    static let isActionRequired  : String = "isActionRequired"
    static let isActionTaken : String = "isActionTaken"
    static let isBigPictureRequired : String = "isBigPictureRequired"
    static let status_Key : String = "status"
    static let uniqueID : String = "uniqueID"
    static let sendFrom : String = "sendFrom"
    static let expiry : String = "expiry"
    static let payloadType  = "payloadType"
    static let sendTo = "sendTo"
    
    static let UserNotification_entity = "UserNotification"
    
    static func saveUserNotificationObject(userNotification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("saveUserNotificationObject()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: NotificationPersistenceHelper.UserNotification_entity, in: managedContext)
            let userNotificationObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            
            userNotificationObject.setValue(userNotification.notificationId, forKey: notificationId)
            userNotificationObject.setValue(userNotification.time, forKey: time)
            userNotificationObject.setValue(userNotification.type, forKey: type)
            userNotificationObject.setValue(userNotification.priority, forKey: priority)
            userNotificationObject.setValue(userNotification.msgClassName, forKey: msgClassName)
            userNotificationObject.setValue(userNotification.msgObjectJson, forKey: msgObjectJson)
            userNotificationObject.setValue(userNotification.groupName, forKey: groupName)
            userNotificationObject.setValue(userNotification.groupValue, forKey: groupValue)
            userNotificationObject.setValue(userNotification.title, forKey: title)
            userNotificationObject.setValue(userNotification.description, forKey: descriptions)
            userNotificationObject.setValue(userNotification.iconUri, forKey: iconUri)
            userNotificationObject.setValue(userNotification.isActionRequired, forKey: isActionRequired)
            userNotificationObject.setValue(userNotification.isActionTaken, forKey: isActionTaken)
            userNotificationObject.setValue(userNotification.isBigPictureRequired, forKey: isBigPictureRequired)
            userNotificationObject.setValue(userNotification.uniqueId, forKey: uniqueID)
            userNotificationObject.setValue(userNotification.status, forKey: status_Key)
            userNotificationObject.setValue(userNotification.sendFrom, forKey: sendFrom)
            userNotificationObject.setValue(userNotification.expiry, forKey: expiry)
            userNotificationObject.setValue(userNotification.payloadType, forKey: payloadType)
            userNotificationObject.setValue(userNotification.sendTo, forKey: sendTo)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            
            
        }
    }
    static func updateNotification(notification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("updateNotification()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
                fetchRequest.predicate = NSPredicate(format: "\(notificationId) == %@",argumentArray: [notification.notificationId!])
                
                
                if let fetchResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]{
                    if fetchResults.count != 0{
                        let managedObject : NSManagedObject? = fetchResults[0]
                        managedObject!.setValue(notification.notificationId, forKey: notificationId)
                        managedObject!.setValue(notification.time, forKey: time)
                        managedObject!.setValue(notification.type, forKey: type)
                        managedObject!.setValue(notification.priority, forKey: priority)
                        managedObject!.setValue(notification.msgClassName, forKey: msgClassName)
                        managedObject!.setValue(notification.msgObjectJson, forKey: msgObjectJson)
                        managedObject!.setValue(notification.groupName, forKey: groupName)
                        managedObject!.setValue(notification.groupValue, forKey: groupValue)
                        managedObject!.setValue(notification.title, forKey: title)
                        managedObject!.setValue(notification.description, forKey: descriptions)
                        managedObject!.setValue(notification.iconUri, forKey: iconUri)
                        managedObject!.setValue(notification.isActionRequired, forKey: isActionRequired)
                        managedObject!.setValue(notification.isActionTaken, forKey: isActionTaken)
                        managedObject!.setValue(notification.isBigPictureRequired, forKey: isBigPictureRequired)
                        managedObject!.setValue(notification.uniqueId, forKey: uniqueID)
                        managedObject!.setValue(notification.status, forKey: status_Key)
                        managedObject!.setValue(notification.sendFrom, forKey: sendFrom)
                        managedObject!.setValue(notification.expiry, forKey: expiry)
                        managedObject!.setValue(notification.payloadType, forKey: payloadType)
                        managedObject!.setValue(notification.sendTo, forKey: sendTo)
                    }
                    CoreDataHelper.saveWorkerContext(workerContext: managedContext)
                }
            }catch let error as NSError{
                print("error in updating UserNotification for notification Id \(String(describing: notification.notificationId)):  : \(error)")
            }
        }
        
    }
    
    static func getAllUserNotification() -> [Int:UserNotification]{
        AppDelegate.getAppDelegate().log.debug("getAllUserNotification()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
        
        var returnUserNotificationObject = [Int : UserNotification]()
        let predicate = NSPredicate(format: "\(status_Key) != %@", argumentArray: [UserNotification.NOT_STATUS_CLOSED])
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: time, ascending: false)
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(sortDescriptor)
        fetchRequest.sortDescriptors = sortDescriptors
        
        let userNotificationObjects = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        
        for i in 0 ..< userNotificationObjects.count {
            
            let userNotification : UserNotification = UserNotification()
            userNotification.notificationId = userNotificationObjects[i].value(forKey: notificationId) as? Int
            userNotification.time = userNotificationObjects[i].value(forKey: time) as? Double
            userNotification.type = userNotificationObjects[i].value(forKey: type) as? String
            if let priority = userNotificationObjects[i].value(forKey: priority) as? Int{
                userNotification.priority = priority
            }
            userNotification.msgClassName = userNotificationObjects[i].value(forKey: msgClassName) as? String
            userNotification.msgObjectJson = userNotificationObjects[i].value(forKey: msgObjectJson) as? String
            userNotification.groupName = userNotificationObjects[i].value(forKey: groupName) as? String
            userNotification.groupValue = userNotificationObjects[i].value(forKey: groupValue) as? String
            userNotification.title = userNotificationObjects[i].value(forKey: title) as? String
            userNotification.description = userNotificationObjects[i].value(forKey: descriptions) as? String
            userNotification.iconUri = userNotificationObjects[i].value(forKey: iconUri) as? String
            if let isActionRequired = userNotificationObjects[i].value(forKey: isActionRequired) as? Bool{
                userNotification.isActionRequired = isActionRequired
            }
            if let isActionTaken = userNotificationObjects[i].value(forKey: isActionTaken) as? Bool{
                userNotification.isActionTaken = isActionTaken
            }
            if let isBigPictureRequired = userNotificationObjects[i].value(forKey: isBigPictureRequired) as? Bool{
                userNotification.isBigPictureRequired = isBigPictureRequired
            }
            
            if let sendFrom = userNotificationObjects[i].value(forKey: sendFrom) as? Double{
                userNotification.sendFrom = sendFrom
            }
            
            if let expiry = userNotificationObjects[i].value(forKey: expiry) as? Double{
                 userNotification.expiry = expiry
            }
            if let payloadType = userNotificationObjects[i].value(forKey: payloadType) as? String{
                userNotification.payloadType = payloadType
            }
            if let sendTo = userNotificationObjects[i].value(forKey: sendTo) as? Double{
                userNotification.sendTo = sendTo
            }
            if userNotification.notificationId == nil{
                continue
            }
            returnUserNotificationObject[userNotification.notificationId!] = userNotification
            
        }
        return returnUserNotificationObject
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
    
    static func deleteNotification(notificationId:Int){
        
        AppDelegate.getAppDelegate().log.debug("deleteNotification()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
                fetchRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.notificationId) = %@",argumentArray: [notificationId])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    static func removeOlderNotificationsBeforeTime( time : Int){
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
            fetchRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.time) < %@",argumentArray: [time])
            
            do{
                let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                try managedContext.execute(batchDelete)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
                
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.debug("removeOlderNotificationsBeforeTime Failed : \(error.localizedDescription)")
            }
        }
    }
    
    static func clearAllNotifications()
    {
        AppDelegate.getAppDelegate().log.debug("clearAllNotifications()")
        let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
        managedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
                fetchRequest.includesPropertyValues = false
                let deleteRequest = NSBatchDeleteRequest(fetchRequest : fetchRequest)
                    
                try managedObjectContext.execute(deleteRequest)
                CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
            } catch {
                AppDelegate.getAppDelegate().log.error("clearAllNotifications() ,error : \(error)")
            }
        }
    }
    
    
    
    static func purgeOldestNotification() -> Int?
    {
        AppDelegate.getAppDelegate().log.debug("purgeOldestNotification()")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        
        do{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: NotificationPersistenceHelper.time, ascending: true)]
            fetchRequest.fetchLimit = 1
            
            
            var results = try managedContext.fetch(fetchRequest)
            if results.isEmpty == false {
                let notificationId = (results[0] as AnyObject).value(forKey: NotificationPersistenceHelper.notificationId) as? Int
                managedContext.delete(results[0] as! NSManagedObject)
                return notificationId
                
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        } catch let error as NSError{
            AppDelegate.getAppDelegate().log.error("Fetch Failed : \(error.localizedDescription)")
        }
        return nil
        
    }
    static func isNotificationAlreadyPresent(uniqueId :Double?) -> Bool{
        
        AppDelegate.getAppDelegate().log.debug("uniqueId : \(String(describing: uniqueId))")
        if uniqueId == nil{
            return false
        }
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
        fetchRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.uniqueID) = %@", argumentArray: [uniqueId!])
        do{
            let results = try managedContext.fetch(fetchRequest)
            
            return  !results.isEmpty
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.error("Fetch Failed : \(error.localizedDescription)")
        }
        return false
    }
    
    static func deleteNotificationsOfAGroup(groupName:String, groupValue:String){
        AppDelegate.getAppDelegate().log.debug("groupName : \(String(describing: groupName)) groupValue : \(String(describing: groupValue))")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do{
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NotificationPersistenceHelper.UserNotification_entity)
                fetchRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.groupName) = %@ AND \(NotificationPersistenceHelper.groupValue) = %@", argumentArray: [groupName,groupValue])
                
                try managedContext.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest))
                    
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("deleteNotificationsOfAGroup : \(error.localizedDescription)")
            }
        }
    }
    static func updateNotificationsOfAGroup(groupName:String, groupValue:String){
        AppDelegate.getAppDelegate().log.debug("updateNotificationsOfAGroup()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do{
                let batchUpdateRequest = NSBatchUpdateRequest(entityName: NotificationPersistenceHelper.UserNotification_entity)
                batchUpdateRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.groupName) = %@ AND \(NotificationPersistenceHelper.groupValue) = %@ AND \(NotificationPersistenceHelper.status_Key) != %@", argumentArray: [groupName,groupValue,UserNotification.NOT_STATUS_CLOSED])
                batchUpdateRequest.propertiesToUpdate = [status_Key : UserNotification.NOT_STATUS_CLOSED]
                try managedContext.execute(batchUpdateRequest)
                
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("updateNotificationsOfAGroup \(error.localizedDescription)")
            }
        }
        
    }
    
    static func updateNotificationStatus(notificationId:Int,status : String){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do{
                let batchUpdateRequest = NSBatchUpdateRequest(entityName: NotificationPersistenceHelper.UserNotification_entity)
                batchUpdateRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.notificationId) = %@", argumentArray: [notificationId])
                batchUpdateRequest.propertiesToUpdate = [status_Key : status]
                
                
                try managedContext.execute(batchUpdateRequest)
                
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.debug("updateNotificationStatus \(error.localizedDescription)")
            }
        }
        
    }
    
    static func updateNotificationsOfAGroup(groupValue:String){
        AppDelegate.getAppDelegate().log.debug("updateNotificationsOfAGroup()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        
        managedContext.perform {
            
            
            do{
                let batchUpdateRequest = NSBatchUpdateRequest(entityName: NotificationPersistenceHelper.UserNotification_entity)
                batchUpdateRequest.predicate = NSPredicate(format: "\(NotificationPersistenceHelper.groupValue) = %@ AND \(NotificationPersistenceHelper.status_Key) != %@", argumentArray: [groupValue,UserNotification.NOT_STATUS_CLOSED])
                batchUpdateRequest.propertiesToUpdate = [status_Key : UserNotification.NOT_STATUS_CLOSED]
                
                try managedContext.execute(batchUpdateRequest)
                
                CoreDataHelper.saveWorkerContext(workerContext:
                    
                    managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("updateNotificationsOfAGroup \(error.localizedDescription)")
            }
        }
        
    }
    
}
