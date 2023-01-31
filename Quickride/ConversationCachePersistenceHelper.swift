//
//  ConversationCachePersistenceHelper.swift
//  Quickride
//
//  Created by QuickRideMac on 01/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class ConversationCachePersistenceHelper {
    
    static let CONVERSATION_CHAT_TABLE_NAME = "Conversation"
    static let ID = "uniqueID"
    
    static let CHAT_TIME = "chatTime"
    static let MESSAGE = "message"
    static let PHONE =  "phone"
    static let SOURCE_ID = "sourceId"
    static let SOURCE_NAME =  "sourceName"
    static let DEST_ID = "destId"
    static let MSG_TYPE = "msgType"
    static let MSG_STATUS = "msgStatus"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
    static let ADDRESS = "address"

    
    static func clearData(){
        AppDelegate.getAppDelegate().log.debug("")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CONVERSATION_CHAT_TABLE_NAME)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest : fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
                
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        } catch {
            AppDelegate.getAppDelegate().log.error("batch delete failed() ,error : \(error)")
            clearRecordByRecord(fetchRequest: fetchRequest)
        }
    }
    static func clearRecordByRecord(fetchRequest : NSFetchRequest<NSFetchRequestResult>){
        AppDelegate.getAppDelegate().log.debug("")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        do{
            let results = try managedContext.fetch(fetchRequest)
            for param in results {
                managedContext.delete(param as! NSManagedObject)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            
        } catch let error as NSError{
            AppDelegate.getAppDelegate().log.error("clearRecordByRecord Failed : \(error.localizedDescription)")
        }
    }
    static func removeAllConversationMessages(blockedUserId : Double){
        AppDelegate.getAppDelegate().log.debug("\(blockedUserId)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CONVERSATION_CHAT_TABLE_NAME)
                fetchRequest.predicate = NSPredicate(format: "\(SOURCE_ID) = %@ OR \(DEST_ID) = %@", argumentArray: [StringUtils.getStringFromDouble(decimalNumber : blockedUserId),StringUtils.getStringFromDouble(decimalNumber : blockedUserId)])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
            }
        }
    }
    
    static func updateChatMessageStatus( destId : Double,uniqueId : String, status : Int){
        AppDelegate.getAppDelegate().log.debug("\(destId) uniqueId: \(uniqueId) \(status)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do{
                let batchUpdateRequest = NSBatchUpdateRequest(entityName: CONVERSATION_CHAT_TABLE_NAME)
                batchUpdateRequest.predicate = NSPredicate(format: "\(DEST_ID) = %@ AND \(MSG_STATUS) != %@", argumentArray: [destId,ConversationMessage.MSG_STATUS_READ])
                batchUpdateRequest.propertiesToUpdate = [ConversationCachePersistenceHelper.MSG_STATUS : status]
                try managedContext.execute(batchUpdateRequest)
                
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            } catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("updateChatMessageStatus failed \(error.localizedDescription)")
            }
        }
    }
    
    static func getAllPersonalChatMessagesWithAPerson( phone : Double) -> [ConversationMessage]{
        AppDelegate.getAppDelegate().log.debug("\(phone)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()

        var conversation : [ConversationMessage] = [ConversationMessage]()
        var conversationObjects : [NSManagedObject] = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CONVERSATION_CHAT_TABLE_NAME)
        let predicate = NSPredicate(format: "\(PHONE) = %@", argumentArray: [StringUtils.getStringFromDouble(decimalNumber : phone)])
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: CHAT_TIME, ascending: true)
        var sortDescriptors = [NSSortDescriptor]()
        sortDescriptors.append(sortDescriptor)
        fetchRequest.sortDescriptors =  sortDescriptors
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            conversationObjects = results as! [NSManagedObject]
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        
        for i in 0 ..< conversationObjects.count  {
            let conversationMessage : ConversationMessage = ConversationMessage()
            conversationMessage.uniqueID = conversationObjects[i].value(forKey: ID) as? String
            conversationMessage.sourceId = conversationObjects[i].value(forKey: SOURCE_ID) as? Double
            conversationMessage.message = conversationObjects[i].value(forKey: MESSAGE) as? String
            conversationMessage.time = conversationObjects[i].value(forKey: CHAT_TIME) as? Double
            conversationMessage.destId = conversationObjects[i].value(forKey: DEST_ID) as? Double
            conversationMessage.msgStatus = conversationObjects[i].value(forKey: MSG_STATUS) as? Int
            conversationMessage.msgType = conversationObjects[i].value(forKey: MSG_TYPE) as? Int
            
            if let latitude = conversationObjects[i].value(forKey: LATITUDE) as? Double{
               conversationMessage.latitude = latitude
            }
          
            if let longitude = conversationObjects[i].value(forKey: LONGITUDE) as? Double{
                conversationMessage.longitude = longitude
            }
            
            if let address = conversationObjects[i].value(forKey: ADDRESS) as? String{
                conversationMessage.address = address
            }
           
            
            conversation.append(conversationMessage)
        }
        return conversation
    }
    static func addPersonalChatMessage(conversationMessage : ConversationMessage, phone : Double){
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage) \(phone)")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {

        let entity = NSEntityDescription.entity(forEntityName: CONVERSATION_CHAT_TABLE_NAME, in: managedContext)
        let conversationMessageNsManagedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        conversationMessageNsManagedObject.setValue(conversationMessage.uniqueID, forKey: ID)
        conversationMessageNsManagedObject.setValue(conversationMessage.sourceId, forKey: SOURCE_ID)
        conversationMessageNsManagedObject.setValue(conversationMessage.destId, forKey: DEST_ID)
        conversationMessageNsManagedObject.setValue(conversationMessage.msgType, forKey: MSG_TYPE)
        conversationMessageNsManagedObject.setValue(conversationMessage.msgStatus, forKey: MSG_STATUS)
        conversationMessageNsManagedObject.setValue(conversationMessage.message, forKey: MESSAGE)
        conversationMessageNsManagedObject.setValue(conversationMessage.time, forKey: CHAT_TIME)
        conversationMessageNsManagedObject.setValue(phone, forKey: PHONE)
        conversationMessageNsManagedObject.setValue(conversationMessage.latitude, forKey: LATITUDE)
        conversationMessageNsManagedObject.setValue(conversationMessage.longitude, forKey: LONGITUDE)
        conversationMessageNsManagedObject.setValue(conversationMessage.address, forKey: ADDRESS)

        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
}
