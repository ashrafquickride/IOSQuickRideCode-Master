//
//  QuickSharePersistanceHelper.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class QuickSharePersistanceHelper: CoreDataHelper {
    
    //Tables
    static let categoryTable = "Category"
    
    //ForKeys
    static let code = "code"
    static let creationDate = "creationDate"
    static let displayName = "displayName"
    static let id = "id"
    static let imageURL = "imageURL"
    static let bookingAmountForRent = "bookingAmountForRent"
    static let bookingAmountForSale = "bookingAmountForSale"
    static let cancellationCharge = "cancellationCharge"
    static let depositForRent = "depositForRent"
    static let modifiedDate = "modifiedDate"
    
    static func storeAvailableCategoryList(categories: [CategoryType]){
        clearTableForEntity(entityName: categoryTable)
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for category in categories{
                prepareCategoryEntityAndStore(category: category, managedContext: managedContext)
            }
        }
    }
    
    static func prepareCategoryEntityAndStore(category: CategoryType,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: categoryTable, in: managedContext)
        let categoryObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        categoryObject.setValue(category.code, forKey: code)
        categoryObject.setValue(category.creationDate, forKey: creationDate)
        categoryObject.setValue(category.displayName, forKey: displayName)
        categoryObject.setValue(category.id, forKey: id)
        categoryObject.setValue(category.imageURL, forKey: imageURL)
        categoryObject.setValue(category.bookingAmountForRent, forKey: bookingAmountForRent)
        categoryObject.setValue(category.bookingAmountForSale, forKey: bookingAmountForSale)
        categoryObject.setValue(category.cancellationCharge, forKey: cancellationCharge)
        categoryObject.setValue(category.depositForRent, forKey: depositForRent)
        categoryObject.setValue(category.modifiedDate, forKey: modifiedDate)
        
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getAvailableCategoryList() -> [CategoryType]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: categoryTable)
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        var categories  = [CategoryType]()
        if let categoryObjects = userManagedObjects{
            for categoryObject in categoryObjects {
                var category = CategoryType()
                category.code = categoryObject.value(forKey: code) as? String
                category.creationDate = categoryObject.value(forKey: creationDate) as? Double ?? 0
                category.displayName = categoryObject.value(forKey: displayName) as? String
                category.id = categoryObject.value(forKey: id) as? String
                category.imageURL = categoryObject.value(forKey: imageURL) as? String
                category.bookingAmountForRent = categoryObject.value(forKey: bookingAmountForRent) as? Int ?? 0
                category.bookingAmountForSale = categoryObject.value(forKey: bookingAmountForSale) as? Int ?? 0
                category.cancellationCharge = categoryObject.value(forKey: cancellationCharge) as? Int ?? 0
                category.depositForRent = categoryObject.value(forKey: depositForRent) as? Int ?? 0
                category.modifiedDate = categoryObject.value(forKey: modifiedDate) as? Double ?? 0
                categories.append(category)
            }
        }
        return categories
    }
    
    static func executeFetchResultAll(managedContext : NSManagedObjectContext, fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> [NSManagedObject]?{
        AppDelegate.getAppDelegate().log.debug("executeFetchResultAll()")
        var fetchResults = [NSManagedObject]()
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            fetchResults = results as! [NSManagedObject]
            
        } catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Could not fetch \(error), \(error.userInfo)")
        }
        
        if fetchResults.count != 0{
            return fetchResults
        }else{
            return nil
        }
    }
    static func clearTableForEntity(entityName : String){
        AppDelegate.getAppDelegate().log.debug("clearTableForEntity() \(entityName)")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do{
            let deleteFetchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try managedContext.execute(deleteFetchRequest)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch{
            AppDelegate.getAppDelegate().log.debug("deleteFetchRequest Failed : \(error)")
        }
    }
}
