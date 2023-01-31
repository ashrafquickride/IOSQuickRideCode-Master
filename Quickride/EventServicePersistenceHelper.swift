
//
//  EventServicePersistenceHelper.swift
//  Quickride
//
//  Created by QuickRideMac on 11/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class EventServicePersistenceHelper {
    static let uniqueIDKey : String = "uniqueID"
    static let timeKey : String  = "time"
    static let EVENT_STORE_TABLE_NAME = "EventService"
    
    static func persistNewUniqueId ( uniqueId :  String) {
        AppDelegate.getAppDelegate().log.debug("persistNewUniqueId() \(uniqueId)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: EVENT_STORE_TABLE_NAME, in: managedContext)
            let eventModel = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            eventModel.setValue(uniqueId, forKey: uniqueIDKey)
            eventModel.setValue(NSDate(), forKey: timeKey)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func deleteUniqueId (uniqueId :String) {
        AppDelegate.getAppDelegate().log.debug("deleteUniqueId() \(uniqueId)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EVENT_STORE_TABLE_NAME)
            
            let predicate = NSPredicate(format: "\(uniqueIDKey)=='\(uniqueId)'")
            fetchRequest.predicate = predicate
            do{
                let results = try managedContext.fetch(fetchRequest)
                for i in 0 ..< results.count {
                    managedContext.delete(results[i] as! NSManagedObject)
                }
                
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.debug("deleteUniqueId Failed : \(error.localizedDescription)")
            }
        }
    }
    
    static func getAllMessageUniqueIDs() -> [String: EventServiceModel]{
        AppDelegate.getAppDelegate().log.debug("getAllMessageUniqueIDs()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EVENT_STORE_TABLE_NAME)
        let sortDescriptor = NSSortDescriptor(key: timeKey, ascending: false)
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(sortDescriptor)
        fetchRequest.sortDescriptors =  sortDescriptors
        var uniqueIDs = [String : EventServiceModel]()
        var eventStoreObjects = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            eventStoreObjects = results as! [NSManagedObject]
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        
        for i in 0 ..< eventStoreObjects.count  {
            let uniqueID = eventStoreObjects[i].value(forKey: uniqueIDKey)
            let time = eventStoreObjects[i].value(forKey: timeKey)
            if uniqueID != nil{
                let model = EventServiceModel(uniqueId: uniqueID as! String, time: time as? NSDate)
                uniqueIDs[uniqueID as! String] = model
                
            }
        }
        return uniqueIDs
    }
    static func clearEventStore() {
        AppDelegate.getAppDelegate().log.debug("clearEventStore()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:EVENT_STORE_TABLE_NAME)
        fetchRequest.includesPropertyValues = false
        managedContext.perform {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
                
        }
        
    }
    static func clearEventStoreOldMessagesBeforeTime(time : NSDate, managedContext: NSManagedObjectContext) {
        AppDelegate.getAppDelegate().log.debug("clearEventStoreOldMessagesBeforeTime()")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:EVENT_STORE_TABLE_NAME)
        let predicate = NSPredicate(format: "\(timeKey) < %@",argumentArray: [time])
        fetchRequest.predicate = predicate
        fetchRequest.includesPropertyValues = false
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
        }catch{
            AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
            clearRecordByRecord(fetchRequest: fetchRequest)
        }        
    }
    static func clearRecordByRecord(fetchRequest : NSFetchRequest<NSFetchRequestResult>){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform { 
            do{
                let results = try managedContext.fetch(fetchRequest)
                for i in 0 ..< results.count {
                    managedContext.delete(results[i] as! NSManagedObject)
                }
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("clearRecordByRecord Failed : \(error.localizedDescription)")
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
        
    }
}
