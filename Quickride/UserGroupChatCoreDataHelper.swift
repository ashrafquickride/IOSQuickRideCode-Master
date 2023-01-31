//
//  UserGroupChatCoreDataHelper.swift
//  Quickride
//
//  Created by QuickRideMac on 3/20/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import CoreData
import Foundation

class UserGroupChatCoreDataHelper {
    
    static let GROUP_CONVERSATION_TABLE_NAME = "GroupConversationMessage"
    
    
    static func addGroupConversationMessage(message : GroupConversationMessage){
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: GROUP_CONVERSATION_TABLE_NAME, in: managedContext)
            let managedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            managedObject.setValue(message.uniqueID, forKey: QuickRideMessageEntity.UNIQUE_ID)
            managedObject.setValue(message.id, forKey: GroupConversationMessage.FLD_ID)
            managedObject.setValue(message.groupId, forKey: GroupConversationMessage.FLD_GROUP_ID)
            managedObject.setValue(message.senderId, forKey: GroupConversationMessage.FLD_SENDER_ID)
            managedObject.setValue(message.senderName, forKey: GroupConversationMessage.FLD_SENDER_NAME)
            managedObject.setValue(message.message, forKey: GroupConversationMessage.FLD_MESSAGE)
            managedObject.setValue(message.time, forKey: GroupConversationMessage.FLD_TIME)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
   

    static func getChatMessagesForGroup( groupId : Double) -> [GroupConversationMessage]{
        AppDelegate.getAppDelegate().log.debug("\(groupId)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        
        var messages = [GroupConversationMessage]()
        var conversationObjects = [NSManagedObject]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: GROUP_CONVERSATION_TABLE_NAME)
        let predicate = NSPredicate(format: "\(GroupConversationMessage.FLD_GROUP_ID) = %@", argumentArray: [StringUtils.getStringFromDouble(decimalNumber : groupId)])
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: GroupConversationMessage.FLD_TIME, ascending: true)
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
            let message = GroupConversationMessage()
            message.uniqueID = conversationObjects[i].value(forKey: QuickRideMessageEntity.UNIQUE_ID) as? String
            message.id = conversationObjects[i].value(forKey: GroupConversationMessage.FLD_ID) as! Double
            message.groupId = conversationObjects[i].value(forKey: GroupConversationMessage.FLD_GROUP_ID) as! Double
            message.senderId = conversationObjects[i].value(forKey: GroupConversationMessage.FLD_SENDER_ID) as! Double
            message.senderName = conversationObjects[i].value(forKey: GroupConversationMessage.FLD_SENDER_NAME) as? String
            message.message = (conversationObjects[i].value(forKey: GroupConversationMessage.FLD_MESSAGE) as! String)
            message.time = conversationObjects[i].value(forKey: GroupConversationMessage.FLD_TIME) as! Double
            messages.append(message)
        }
        return messages
    }
    static func deleteChatMessagesOfGroup(groupId : Double){
        let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: GROUP_CONVERSATION_TABLE_NAME)
        let predicate = NSPredicate(format: "\(GroupConversationMessage.FLD_GROUP_ID) = %@", argumentArray: [StringUtils.getStringFromDouble(decimalNumber : groupId)])
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest : fetchRequest)
        do {
            try managedObjectContext.execute(deleteRequest)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
        } catch {
            AppDelegate.getAppDelegate().log.error("batch delete failed() ,error : \(error)")
            clearRecordByRecord(fetchRequest: fetchRequest)
        }
    }
    static func clearData(){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: GROUP_CONVERSATION_TABLE_NAME)
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
}
