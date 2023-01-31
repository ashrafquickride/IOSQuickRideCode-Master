//
//  LocationCoreDataHelper.swift
//  Quickride
//
//  Created by Vinutha on 11/15/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class LocationCoreDataHelper {
    
    static let LOCATION_INFO_TABLE = "Location"
    static let ID = "id"
    static let LATITUDE = "latitude"
    static let LONGITUDE = "longitude"
    static let COUNTRY = "country"
    static let STATE = "state"
    static let CITY = "city"
    static let AREA_NAME = "areaName"
    static let STREET_NAME = "streetName"
    static let LOCATION_NAME = "locationName"
    static let FORMATTED_ADDRESS = "formattedAddress"
    static let CREATION_DATE = "creationDate"
    static let RECENT_USED_TIME = "recentUsedTime"
    
    static let TABLE_SIZE = 50
    
    static func getLocationInfo(latitude : Double,longitude : Double) -> Location?{
    
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: LOCATION_INFO_TABLE)
        let predicate = NSPredicate(format: "\(LATITUDE) = %@ AND \(LONGITUDE) = %@",argumentArray: [latitude,longitude])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        var fetchResults = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        for result in fetchResults {
             return prepareLocationFromNSManagedObject(result: result)
        }
        return nil
    }
    static func getLocationInfo(address : String) -> Location?{
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: LOCATION_INFO_TABLE)
        let predicate = NSPredicate(format: "\(FORMATTED_ADDRESS) = %@",argumentArray: [address])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        var fetchResults = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        for result in fetchResults {
            return prepareLocationFromNSManagedObject(result: result)
        }
        return nil
    }
    static func prepareLocationFromNSManagedObject(result : NSManagedObject) -> Location{
        let location = Location()
        if let id = result.value(forKey: ID) as? Double{
          location.id = id
        }
        if let latitude = result.value(forKey: LATITUDE) as? Double{
            location.latitude = latitude
        }
        
        if let longitude = result.value(forKey: LONGITUDE) as? Double{
            location.longitude = longitude
        }
        location.country = result.value(forKey: COUNTRY) as? String
        location.state = result.value(forKey: STATE) as? String
        location.city = result.value(forKey: CITY) as? String
        location.areaName = result.value(forKey: AREA_NAME) as? String
        location.streetName = result.value(forKey: STREET_NAME) as? String
        location.shortAddress = result.value(forKey: LOCATION_NAME) as? String
        location.completeAddress = result.value(forKey: FORMATTED_ADDRESS) as? String
        return location
    }
    static func saveLocationInfo(location : Location) {
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let managedEntity = NSEntityDescription.entity(forEntityName: LOCATION_INFO_TABLE, in: managedContext)
            
            let managedObject = NSManagedObject(entity: managedEntity!, insertInto: managedContext)
            
            managedObject.setValue(location.id, forKey: ID)
            managedObject.setValue(location.latitude, forKey: LATITUDE)
            managedObject.setValue(location.longitude, forKey: LONGITUDE)
            managedObject.setValue(location.country, forKey: COUNTRY)
            managedObject.setValue(location.state, forKey: STATE)
            managedObject.setValue(location.city, forKey: CITY)
            managedObject.setValue(location.areaName, forKey: AREA_NAME)
            managedObject.setValue(location.streetName, forKey: STREET_NAME)
            managedObject.setValue(location.shortAddress, forKey: LOCATION_NAME)
            managedObject.setValue(location.completeAddress, forKey: FORMATTED_ADDRESS)
            managedObject.setValue(NSDate().getTimeStamp(), forKey: CREATION_DATE)
            managedObject.setValue(NSDate().getTimeStamp(), forKey: RECENT_USED_TIME)
            
            let count = fetchCountOfLocationTable(managedContext: managedContext, tableName: LOCATION_INFO_TABLE)
            if count != nil && count! > TABLE_SIZE{
                removeLeastUsedLocationEntity()
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    static func fetchCountOfLocationTable(managedContext : NSManagedObjectContext,tableName : String) -> Int?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        do {
            return try managedContext.count(for: fetchRequest)
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    static func removeLeastUsedLocationEntity(){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: LOCATION_INFO_TABLE)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: RECENT_USED_TIME, ascending: true)]
        fetchRequest.fetchLimit = 1
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
        }catch{
            AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
        }
    }
    
    static func updateRecentUsedTime(id : Double,date : Double){
    
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: LOCATION_INFO_TABLE)
            fetchRequest.predicate = NSPredicate(format: "\(ID) == %@",argumentArray: [id])
            var fetchResults = [NSManagedObject]()
            do {
                fetchResults =
                    try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError {
                AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
            }
            
            for result in fetchResults{
                
                result.setValue(NSDate().getTimeStamp(), forKey: RECENT_USED_TIME)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }

}
