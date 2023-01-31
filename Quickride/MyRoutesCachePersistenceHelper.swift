//
//  MyRoutesCachePersistenceHelper.swift
//  Quickride
//
//  Created by KNM Rao on 21/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class MyRoutesCachePersistenceHelper {
    
    static let distance = "distance"
    static let routeId = "routeId"
    static let duration = "duration";
    static let waypoints = "waypoints"
    static let routeType = "routeType"
    static let fromLatitude = "fromLatitude"
    static let fromLongitude = "fromLongitude"
    static let toLatitude = "toLatitude"
    static let toLongitude = "toLongitude"
    static let overviewPolyline = "overviewPolyline"
    static let time = "time"
    static let userId = "userId"
    static let id = "id"
    static let fromLocation = "fromLocation"
    static let toLocation = "toLocation"
    static let routeName = "routeName"
    
    static let route_entity = "RideRoute"
    static let walk_route_entity = "WalkRoute"
    static let userPreferredRoute_entity = "UserPreferredRoute"
    static let walk_route_table_size = 5
    
    static func saveRoutesInBulk(routeList:[RideRoute])
    {
        for route in routeList
        {
            saveRoute(riderroute: route)
        }
    }
    
    static func saveRoute(riderroute:RideRoute)
    {
        AppDelegate.getAppDelegate().log.debug("saveRoute \(riderroute)")
        if riderroute.routeId == nil || riderroute.routeId! == 0
        {
            return
        }
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: MyRoutesCachePersistenceHelper.route_entity, in: managedContext)
            let routeObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            routeObject.setValue(riderroute.routeId, forKey:MyRoutesCachePersistenceHelper.routeId)
            routeObject.setValue(riderroute.overviewPolyline, forKey:MyRoutesCachePersistenceHelper.overviewPolyline)
            routeObject.setValue(riderroute.distance, forKey:MyRoutesCachePersistenceHelper.distance)
            routeObject.setValue(riderroute.duration, forKey:MyRoutesCachePersistenceHelper.duration)
            routeObject.setValue(riderroute.routeType, forKey:MyRoutesCachePersistenceHelper.routeType)
            routeObject.setValue(riderroute.waypoints, forKey:MyRoutesCachePersistenceHelper.waypoints)
            routeObject.setValue(riderroute.fromLatitude!.getDecimalValueWithOutRounding(places: 4), forKey:MyRoutesCachePersistenceHelper.fromLatitude)
            routeObject.setValue(riderroute.fromLongitude!.getDecimalValueWithOutRounding(places: 4), forKey:MyRoutesCachePersistenceHelper.fromLongitude)
            routeObject.setValue(riderroute.toLatitude!.getDecimalValueWithOutRounding(places: 4), forKey:MyRoutesCachePersistenceHelper.toLatitude)
            routeObject.setValue(riderroute.toLongitude!.getDecimalValueWithOutRounding(places: 4), forKey:MyRoutesCachePersistenceHelper.toLongitude)
            
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            
            
        }
    }
    
    static func getAvailableRoutes(startLatitude:Double,startLongitude:Double,endLatitude:Double,endLongitude:Double) ->[RideRoute]?{
        //TODO : predicate to be added to query routes
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName:MyRoutesCachePersistenceHelper.route_entity)
        fetchRequest.predicate = NSPredicate(format: "\(MyRoutesCachePersistenceHelper.fromLatitude) = %@ AND \(MyRoutesCachePersistenceHelper.fromLongitude) = %@ AND \(MyRoutesCachePersistenceHelper.toLatitude) = %@ AND \(MyRoutesCachePersistenceHelper.toLongitude) = %@", argumentArray: [startLatitude.getDecimalValueWithOutRounding(places: 4),startLongitude.getDecimalValueWithOutRounding(places: 4),endLatitude.getDecimalValueWithOutRounding(places: 4),endLongitude.getDecimalValueWithOutRounding(places: 4)])
        var returnRouteObject = [RideRoute]()
        let rideRouteObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        
        
        for i in 0 ..< rideRouteObject.count {
            let rideRoute : RideRoute? = RideRoute()
            rideRoute!.routeId = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeId) as? Double
            rideRoute!.routeType = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeType) as? String
            rideRoute!.overviewPolyline = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.overviewPolyline) as? String
            rideRoute!.distance = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.distance) as? Double
            rideRoute!.duration = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.duration) as? Double
            rideRoute!.waypoints = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.waypoints) as? String
            rideRoute!.fromLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLatitude) as? Double
            rideRoute!.fromLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLongitude) as? Double
            rideRoute!.toLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLatitude) as? Double
            rideRoute!.toLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLongitude) as? Double
            returnRouteObject.append(rideRoute!)
        }
        return returnRouteObject
    }
    
    static func clearRouteTable()
    {
        let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
        managedObjectContext.perform {
            do {
                let fetchRequestRideRoute = NSFetchRequest<NSFetchRequestResult>(entityName: MyRoutesCachePersistenceHelper.route_entity)
                let fetchRequestWalkRoute = NSFetchRequest<NSFetchRequestResult>(entityName: MyRoutesCachePersistenceHelper.walk_route_entity)
                fetchRequestRideRoute.includesPropertyValues = false
                fetchRequestWalkRoute.includesPropertyValues = false
                let deleteRideRouteRequest = NSBatchDeleteRequest(fetchRequest : fetchRequestRideRoute)
                
                try managedObjectContext.execute(deleteRideRouteRequest)
                
                let deleteWalkRequest = NSBatchDeleteRequest(fetchRequest : fetchRequestWalkRoute)
                
                try managedObjectContext.execute(deleteWalkRequest)
                CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
            } catch {
                AppDelegate.getAppDelegate().log.error("clearRouteTable() ,error : \(error)")
            }
        }
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
    
    static func getWalkRoute(startLatitude:Double,startLongitude:Double,endLatitude:Double,endLongitude:Double) ->RideRoute?{
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName:MyRoutesCachePersistenceHelper.walk_route_entity)
        
        fetchRequest.predicate = NSPredicate(format: "\(MyRoutesCachePersistenceHelper.fromLatitude) = %@ AND \(MyRoutesCachePersistenceHelper.fromLongitude) = %@ AND \(MyRoutesCachePersistenceHelper.toLatitude) = %@ AND \(MyRoutesCachePersistenceHelper.toLongitude) = %@", argumentArray: [startLatitude.getDecimalValueWithOutRounding(places: 5),startLongitude.getDecimalValueWithOutRounding(places: 5),endLatitude.getDecimalValueWithOutRounding(places: 5),endLongitude.getDecimalValueWithOutRounding(places: 5)])
        
        let rideRouteObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        
        
        for i in 0 ..< rideRouteObject.count {
            let rideRoute : RideRoute? = RideRoute()
            
            rideRoute!.overviewPolyline = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.overviewPolyline) as? String
            rideRoute!.distance = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.distance) as? Double
            rideRoute!.duration = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.duration) as? Double
            rideRoute!.fromLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLatitude) as? Double
            rideRoute!.fromLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLongitude) as? Double
            rideRoute!.toLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLatitude) as? Double
            rideRoute!.toLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLongitude) as? Double
            rideRoute!.routeId = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeId) as? Double
            return rideRoute
        }
        return nil
    }
    static func saveWalkRoute(riderroute:RideRoute)
    {
        AppDelegate.getAppDelegate().log.debug("saveWalkRoute \(riderroute)")
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            let entity = NSEntityDescription.entity(forEntityName: MyRoutesCachePersistenceHelper.walk_route_entity, in: managedContext)
            
            
            let routeObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            routeObject.setValue(riderroute.overviewPolyline, forKey:MyRoutesCachePersistenceHelper.overviewPolyline)
            routeObject.setValue(riderroute.distance, forKey:MyRoutesCachePersistenceHelper.distance)
            routeObject.setValue(riderroute.duration, forKey:MyRoutesCachePersistenceHelper.duration)
        routeObject.setValue(riderroute.fromLatitude!.getDecimalValueWithOutRounding(places: 5), forKey:MyRoutesCachePersistenceHelper.fromLatitude)
        routeObject.setValue(riderroute.fromLongitude!.getDecimalValueWithOutRounding(places: 5), forKey:MyRoutesCachePersistenceHelper.fromLongitude)
        routeObject.setValue(riderroute.toLatitude!.getDecimalValueWithOutRounding(places: 5), forKey:MyRoutesCachePersistenceHelper.toLatitude)
        routeObject.setValue(riderroute.toLongitude!.getDecimalValueWithOutRounding(places: 5), forKey:MyRoutesCachePersistenceHelper.toLongitude)
            routeObject.setValue(riderroute.routeId, forKey: MyRoutesCachePersistenceHelper.routeId)
            routeObject.setValue(NSDate().getTimeStamp(), forKey: MyRoutesCachePersistenceHelper.time)
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MyRoutesCachePersistenceHelper.walk_route_entity)
            let sortDescriptor = NSSortDescriptor(key: MyRoutesCachePersistenceHelper.time, ascending: true)
            var sortDescriptors = [NSSortDescriptor]()
            sortDescriptors.append(sortDescriptor)
            fetchRequest.sortDescriptors = sortDescriptors
            let result = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
            if result.count > walk_route_table_size{
                managedContext.delete(result[0])
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    static func updateWalkRoute(rideRoute : RideRoute){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MyRoutesCachePersistenceHelper.walk_route_entity)
            fetchRequest.predicate = NSPredicate(format: "\(MyRoutesCachePersistenceHelper.routeId) == %@",argumentArray: [rideRoute.routeId!])
            
            let fetchResults = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
            if fetchResults.count != 0{
                let managedObject : NSManagedObject? = fetchResults[0]
                managedObject!.setValue(NSDate().getTimeStamp(), forKey: MyRoutesCachePersistenceHelper.time)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
    }
    
    static func storeUserPreferredRoutesInBulk(userPreferredRoutes : [UserPreferredRoute]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            for userPreferredRoute in userPreferredRoutes{
              prepareUserPreferredRouteEntityAndStore(userPreferredRoute: userPreferredRoute, managedContext: managedContext)
            }
        }
    }
    
    static func saveUserPreferredRoute(userPreferredRoute : UserPreferredRoute){
       let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            prepareUserPreferredRouteEntityAndStore(userPreferredRoute: userPreferredRoute, managedContext: managedContext)
        }
    }
    
    static func prepareUserPreferredRouteEntityAndStore(userPreferredRoute : UserPreferredRoute,managedContext : NSManagedObjectContext){
    
            let entity = NSEntityDescription.entity(forEntityName: MyRoutesCachePersistenceHelper.userPreferredRoute_entity, in: managedContext)
            let routeObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            routeObject.setValue(userPreferredRoute.routeId, forKey:MyRoutesCachePersistenceHelper.routeId)
            routeObject.setValue(userPreferredRoute.id, forKey:MyRoutesCachePersistenceHelper.id)
            routeObject.setValue(userPreferredRoute.userId, forKey:MyRoutesCachePersistenceHelper.userId)
            routeObject.setValue(userPreferredRoute.fromLatitude, forKey:MyRoutesCachePersistenceHelper.fromLatitude)
            routeObject.setValue(userPreferredRoute.fromLongitude, forKey:MyRoutesCachePersistenceHelper.fromLongitude)
            routeObject.setValue(userPreferredRoute.toLatitude, forKey:MyRoutesCachePersistenceHelper.toLatitude)
            routeObject.setValue(userPreferredRoute.toLongitude, forKey:MyRoutesCachePersistenceHelper.toLongitude)
            routeObject.setValue(userPreferredRoute.fromLocation, forKey:MyRoutesCachePersistenceHelper.fromLocation)
            routeObject.setValue(userPreferredRoute.toLocation, forKey:MyRoutesCachePersistenceHelper.toLocation)
            routeObject.setValue(userPreferredRoute.routeName, forKey:MyRoutesCachePersistenceHelper.routeName)
            if let rideRoute = userPreferredRoute.rideRoute{
               saveRoute(riderroute: rideRoute)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
      
    }
    
    static func updateUserPreferredRoute(userPreferredRoute : UserPreferredRoute){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName:MyRoutesCachePersistenceHelper.userPreferredRoute_entity)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "\(MyRoutesCachePersistenceHelper.id) = %@", argumentArray: [userPreferredRoute.id!])
            let userPreferredRouteObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
            if userPreferredRouteObject.isEmpty == false{
                userPreferredRouteObject[0].setValue(userPreferredRoute.routeId, forKey:MyRoutesCachePersistenceHelper.routeId)
                userPreferredRouteObject[0].setValue(userPreferredRoute.id, forKey:MyRoutesCachePersistenceHelper.id)
                userPreferredRouteObject[0].setValue(userPreferredRoute.userId, forKey:MyRoutesCachePersistenceHelper.userId)
                userPreferredRouteObject[0].setValue(userPreferredRoute.fromLatitude, forKey:MyRoutesCachePersistenceHelper.fromLatitude)
                userPreferredRouteObject[0].setValue(userPreferredRoute.fromLongitude, forKey:MyRoutesCachePersistenceHelper.fromLongitude)
                userPreferredRouteObject[0].setValue(userPreferredRoute.toLatitude, forKey:MyRoutesCachePersistenceHelper.toLatitude)
                userPreferredRouteObject[0].setValue(userPreferredRoute.toLongitude, forKey:MyRoutesCachePersistenceHelper.toLongitude)
                if let rideRoute = userPreferredRoute.rideRoute{
                    saveRoute(riderroute: rideRoute)
                }
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }
     }
    
    static func getUserPreferredRoutes() -> [UserPreferredRoute]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName:MyRoutesCachePersistenceHelper.userPreferredRoute_entity)
        let userPreferredRouteObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        var returnRouteObject = [UserPreferredRoute]()
        
        for i in 0 ..< userPreferredRouteObject.count {
            let userPreferredRoute = UserPreferredRoute()
            userPreferredRoute.id = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.id) as? Double
            userPreferredRoute.userId = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.userId) as? Double
            userPreferredRoute.routeId = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeId) as? Double
            userPreferredRoute.fromLatitude = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLatitude) as? Double
            userPreferredRoute.fromLongitude = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLongitude) as? Double
            userPreferredRoute.toLatitude = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLatitude) as? Double
            userPreferredRoute.toLongitude = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLongitude) as? Double
            userPreferredRoute.fromLocation = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLocation) as? String
            userPreferredRoute.toLocation = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLocation) as? String
            userPreferredRoute.routeName = userPreferredRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeName) as? String
            returnRouteObject.append(userPreferredRoute)
        }
        return returnRouteObject
    }
    
    static func getRouteFromRouteId(routeId : Double?) -> RideRoute?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest=NSFetchRequest<NSFetchRequestResult>(entityName:MyRoutesCachePersistenceHelper.route_entity)
        
        fetchRequest.predicate = NSPredicate(format: "\(MyRoutesCachePersistenceHelper.routeId) = %@", argumentArray: [routeId!])
        
        let rideRouteObject = executeFetchResult(managedContext: managedContext, fetchRequest: fetchRequest)
        
        
        for i in 0 ..< rideRouteObject.count {
            let rideRoute : RideRoute? = RideRoute()
            
            rideRoute!.overviewPolyline = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.overviewPolyline) as? String
            rideRoute!.distance = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.distance) as? Double
            rideRoute!.duration = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.duration) as? Double
            rideRoute!.fromLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLatitude) as? Double
            rideRoute!.fromLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.fromLongitude) as? Double
            rideRoute!.toLatitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLatitude) as? Double
            rideRoute!.toLongitude = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.toLongitude) as? Double
            rideRoute!.routeId = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeId) as? Double
            rideRoute!.waypoints = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.waypoints) as? String
            rideRoute!.routeType = rideRouteObject[i].value(forKey: MyRoutesCachePersistenceHelper.routeType) as? String
            
            return rideRoute
        }
        return nil
        
    }
    
    static func clearRecordByRecord(fetchRequest : NSFetchRequest<NSFetchRequestResult>){
        do{
            let managedObjectContext = CoreDataHelper.getNSMangedObjectContext()
            let results = try managedObjectContext.fetch(fetchRequest)
            for i in 0..<results.count {
                managedObjectContext.delete(results[i] as! NSManagedObject)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedObjectContext)
        } catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("clearRecordByRecord Failed : \(error.localizedDescription)")
        }
    }
    
    static func deleteUserPreferredRoute(userPreferredRoute : UserPreferredRoute){
        
        AppDelegate.getAppDelegate().log.debug("deleteRecentLocation()")
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        // make the call async
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userPreferredRoute_entity)
        let predicate = NSPredicate(format: "\(id) == %@", argumentArray: [userPreferredRoute.id!])
        fetchRequest.predicate = predicate
        do {
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do{
                try managedContext.execute(deleteRequest)
            }catch{
                AppDelegate.getAppDelegate().log.error("failed batch delete : \(error)")
                clearRecordByRecord(fetchRequest: fetchRequest)
            }
            CoreDataHelper.saveWorkerContext(workerContext: managedContext)
        }catch let error as NSError{
            AppDelegate.getAppDelegate().log.debug("Fetch Failed : \(error.localizedDescription)")
        }
    }
}
