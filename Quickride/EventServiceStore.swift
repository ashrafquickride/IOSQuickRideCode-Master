//
//  EventServiceStore.swift
//  Quickride
//
//  Created by QuickRideMac on 11/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class EventServiceStore {
    
    var uniqueIDS = [String : EventServiceModel]()
    static var eventStore : EventServiceStore? = nil
    
    static func getInstance() -> EventServiceStore{
        if eventStore == nil{
            eventStore = EventServiceStore()
        }
        return eventStore!
    }
    static func getInstanceIfExists() -> EventServiceStore?{
        
        return eventStore
    }
    init()  {
        self.loadAllMessagesFromPersistence()
        
    }
    
    
    func removeEldestEntry() {
        if uniqueIDS.isEmpty == true{
            return
        }
        var date : NSDate?
        var oldestEntity : String?
        for uniqueId in uniqueIDS {
            if uniqueId.1.time != nil
            {
                if date == nil || date!.timeIntervalSince1970 > (uniqueId.1.time!.timeIntervalSince1970){
                    oldestEntity = uniqueId.0
                    date = uniqueId.1.time
                }
            }
        }
        if oldestEntity != nil{
            EventServicePersistenceHelper.deleteUniqueId(uniqueId: oldestEntity!)
            uniqueIDS.removeValue(forKey: oldestEntity!)
        }
    }
    
    func isDuplicateMessage( newMessageId : String) -> Bool {
        return uniqueIDS.keys.contains(newMessageId)
    }
    
    func addNewMessageID(uniqueID : String) {
        AppDelegate.getAppDelegate().log.debug("\(uniqueID)")
        uniqueIDS[uniqueID] = EventServiceModel(uniqueId: uniqueID, time: NSDate())
        EventServicePersistenceHelper.persistNewUniqueId(uniqueId: uniqueID)
        if uniqueIDS.count >= AppConfiguration.maximumEventStoreEntities{
            removeEldestEntry()
        }
    }
    
    func removeMessage( uniqueID : String) {
        
        uniqueIDS.removeValue(forKey: uniqueID)
        
        EventServicePersistenceHelper.deleteUniqueId(uniqueId: uniqueID)
    }
    
    func loadAllMessagesFromPersistence() {
        
        let minDate = NSDate().addHours(hoursToAdd: -AppConfiguration.THRESHOLD_TIME_TO_STORE_EVENT_ENTITIES_IN_HOURS)
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            EventServicePersistenceHelper.clearEventStoreOldMessagesBeforeTime(time: minDate, managedContext: managedContext)
            self.uniqueIDS = EventServicePersistenceHelper.getAllMessageUniqueIDs()
        }
    }
    
    func clearUniqueIDSFromPersistence() {
        EventServicePersistenceHelper.clearEventStore()
        uniqueIDS.removeAll()
    }
}
