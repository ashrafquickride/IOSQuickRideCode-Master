//
//  MyTaxiRidesPersistenceHelper.swift
//  Quickride
//
//  Created by HK on 16/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class MyTaxiRidesPersistenceHelper: CoreDataHelper {
    
    
    //MARK: keys
    static let id  = "id"
    static let userId  = "userId"
    static let userName  = "userName"
    static let contactNo  = "contactNo"
    static let email  = "email"
    static let imageURI  = "imageURI"
    static let taxiGroupId  = "taxiGroupId"
    static let startTimeMs  = "startTimeMs"
    static let expectedEndTimeMs  = "expectedEndTimeMs"
    static let startAddress  = "startAddress"
    static let startLat  = "startLat"
    static let startLng  = "startLng"
    static let endAddress  = "endAddress"
    static let endLat  = "endLat"
    static let endLng  = "endLng"
    static let tripType  = "tripType"
    static let journeyType  = "journeyType"
    static let taxiVehicleCategory  = "taxiVehicleCategory"
    static let taxiType  = "taxiType"
    static let shareType  = "shareType"
    static let status  = "status"
    static let noOfSeats  = "noOfSeats"
    static let distance  = "distance"
    static let initialFare  = "initialFare"
    static let finalFare  = "finalFare"
    static let taxiRideJoinTimeMs  = "taxiRideJoinTimeMs"
    static let pickupTimeMs  = "pickupTimeMs"
    static let pickupOrder  = "pickupOrder"
    static let dropTimeMs  = "dropTimeMs"
    static let dropOrder  = "dropOrder"
    static let finalDistance  = "finalDistance"
    static let deviatedFromOriginalRoute  = "deviatedFromOriginalRoute"
    static let actualStartTimeMs  = "actualStartTimeMs"
    static let actualEndTimeMs  = "actualEndTimeMs"
    static let taxiRideUnjoinTimeMs  = "taxiRideUnjoinTimeMs"
    static let taxiUnjoinReason  = "taxiUnjoinReason"
    static let cancellationAmount  = "cancellationAmount"
    static let routeId  = "routeId"
    static let wayPoints  = "wayPoints"
    static let refRequestId  = "refRequestId"
    static let singleSharingOn  = "singleSharingOn"
    static let pickupOtp  = "pickupOtp"
    static let pickupReachedTimeMs  = "pickupReachedTimeMs"
    static let dropOtp  = "dropOtp"
    static let creationTimeMs  = "creationTimeMs"
    static let modifiedTimeMs  = "modifiedTimeMs"
    static let routePolyline  = "routePolyline"
    static let version  = "version"
    static let pickupRouteId = "pickupRouteId"
    static let pickupRoutePolyline = "pickupRoutePolyline"
    static let advanceFare  = "advanceFare"
    static let pendingAmount  = "pendingAmount"
    static let paymentType  = "paymentType"
    
    //MARK: Tables
    static let taxiRidePassengerTable = "TaxiRidePassenger"
    static let closedTaxiRidePassengerTable = "ClosedTaxiRidePassenger"
    
    //MARK: Ative rides
    static func storeAllActiveTrips(taxiRides: [TaxiRidePassenger]){
        clearTableForEntity(entityName: taxiRidePassengerTable)
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for taxiRide in taxiRides{
                prepareTaxiRideEntityAndStore(taxiRide: taxiRide, managedContext: managedContext)
            }
        }
    }
    
    static func saveActiveTrip(taxiRide: TaxiRidePassenger){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            prepareTaxiRideEntityAndStore(taxiRide: taxiRide, managedContext: managedContext)
        }
    }
    
    static func prepareTaxiRideEntityAndStore(taxiRide: TaxiRidePassenger,managedContext : NSManagedObjectContext){
        
        let entity = NSEntityDescription.entity(forEntityName: taxiRidePassengerTable, in: managedContext)
        let taxiRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        taxiRideObject.setValue(taxiRide.id, forKey: id)
        taxiRideObject.setValue(taxiRide.userId, forKey: userId)
        taxiRideObject.setValue(taxiRide.userName, forKey: userName)
        taxiRideObject.setValue(taxiRide.contactNo, forKey: contactNo)
        taxiRideObject.setValue(taxiRide.email, forKey: email)
        taxiRideObject.setValue(taxiRide.imageURI, forKey: imageURI)
        taxiRideObject.setValue(taxiRide.taxiGroupId, forKey: taxiGroupId)
        taxiRideObject.setValue(taxiRide.startTimeMs, forKey: startTimeMs)
        taxiRideObject.setValue(taxiRide.expectedEndTimeMs, forKey: expectedEndTimeMs)
        taxiRideObject.setValue(taxiRide.startAddress, forKey: startAddress)
        taxiRideObject.setValue(taxiRide.startLat, forKey: startLat)
        taxiRideObject.setValue(taxiRide.startLng, forKey: startLng)
        taxiRideObject.setValue(taxiRide.endAddress, forKey: endAddress)
        taxiRideObject.setValue(taxiRide.endLat, forKey: endLat)
        taxiRideObject.setValue(taxiRide.endLng, forKey: endLng)
        taxiRideObject.setValue(taxiRide.tripType, forKey: tripType)
        taxiRideObject.setValue(taxiRide.journeyType, forKey: journeyType)
        taxiRideObject.setValue(taxiRide.taxiVehicleCategory, forKey: taxiVehicleCategory)
        taxiRideObject.setValue(taxiRide.taxiType, forKey: taxiType)
        taxiRideObject.setValue(taxiRide.shareType, forKey: shareType)
        taxiRideObject.setValue(taxiRide.status, forKey: status)
        taxiRideObject.setValue(taxiRide.noOfSeats, forKey: noOfSeats)
        taxiRideObject.setValue(taxiRide.distance, forKey: distance)
        taxiRideObject.setValue(taxiRide.initialFare, forKey: initialFare)
        taxiRideObject.setValue(taxiRide.advanceFare, forKey: advanceFare)
        taxiRideObject.setValue(taxiRide.finalFare, forKey: finalFare)
        taxiRideObject.setValue(taxiRide.taxiRideJoinTimeMs, forKey: taxiRideJoinTimeMs)
        taxiRideObject.setValue(taxiRide.pickupTimeMs, forKey: pickupTimeMs)
        taxiRideObject.setValue(taxiRide.dropTimeMs, forKey: dropTimeMs)
        taxiRideObject.setValue(taxiRide.finalDistance, forKey: finalDistance)
        taxiRideObject.setValue(taxiRide.deviatedFromOriginalRoute, forKey: deviatedFromOriginalRoute)
        taxiRideObject.setValue(taxiRide.actualStartTimeMs, forKey: actualStartTimeMs)
        taxiRideObject.setValue(taxiRide.actualEndTimeMs, forKey: actualEndTimeMs)
        taxiRideObject.setValue(taxiRide.taxiRideUnjoinTimeMs, forKey: taxiRideUnjoinTimeMs)
        taxiRideObject.setValue(taxiRide.taxiUnjoinReason, forKey: taxiUnjoinReason)
        taxiRideObject.setValue(taxiRide.cancellationAmount, forKey: cancellationAmount)
        taxiRideObject.setValue(taxiRide.routeId, forKey: routeId)
        taxiRideObject.setValue(taxiRide.wayPoints, forKey: wayPoints)
        taxiRideObject.setValue(taxiRide.refRequestId, forKey: refRequestId)
        taxiRideObject.setValue(taxiRide.singleSharingOn, forKey: singleSharingOn)
        taxiRideObject.setValue(taxiRide.pickupOtp, forKey: pickupOtp)
        taxiRideObject.setValue(taxiRide.pickupReachedTimeMs, forKey: pickupReachedTimeMs)
        taxiRideObject.setValue(taxiRide.dropOtp, forKey: dropOtp)
        taxiRideObject.setValue(taxiRide.creationTimeMs, forKey: creationTimeMs)
        taxiRideObject.setValue(taxiRide.modifiedTimeMs, forKey: modifiedTimeMs)
        taxiRideObject.setValue(taxiRide.routePolyline, forKey: routePolyline)
        taxiRideObject.setValue(taxiRide.version, forKey: version)
        taxiRideObject.setValue(taxiRide.pickupRouteId, forKey: pickupRouteId)
        taxiRideObject.setValue(taxiRide.pickupRoutePolyline, forKey: pickupRoutePolyline)
        taxiRideObject.setValue(taxiRide.pendingAmount, forKey: pendingAmount)
        taxiRideObject.setValue(taxiRide.paymentType, forKey: paymentType)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }

    
    static func updateTaxiTrip(taxiRide: TaxiRidePassenger){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taxiRidePassengerTable)
            fetchRequest.predicate = NSPredicate(format: "\(taxiRide.id ?? 0) == %@", argumentArray: [taxiRide.id ?? 0])
            if let taxiRideObject = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest){
                taxiRideObject[0].setValue(taxiRide.id, forKey: id)
                taxiRideObject[0].setValue(taxiRide.userId, forKey: userId)
                taxiRideObject[0].setValue(taxiRide.userName, forKey: userName)
                taxiRideObject[0].setValue(taxiRide.contactNo, forKey: contactNo)
                taxiRideObject[0].setValue(taxiRide.email, forKey: email)
                taxiRideObject[0].setValue(taxiRide.imageURI, forKey: imageURI)
                taxiRideObject[0].setValue(taxiRide.taxiGroupId, forKey: taxiGroupId)
                taxiRideObject[0].setValue(taxiRide.startTimeMs, forKey: startTimeMs)
                taxiRideObject[0].setValue(taxiRide.expectedEndTimeMs, forKey: expectedEndTimeMs)
                taxiRideObject[0].setValue(taxiRide.startAddress, forKey: startAddress)
                taxiRideObject[0].setValue(taxiRide.startLat, forKey: startLat)
                taxiRideObject[0].setValue(taxiRide.startLng, forKey: startLng)
                taxiRideObject[0].setValue(taxiRide.endAddress, forKey: endAddress)
                taxiRideObject[0].setValue(taxiRide.endLat, forKey: endLat)
                taxiRideObject[0].setValue(taxiRide.endLng, forKey: endLng)
                taxiRideObject[0].setValue(taxiRide.tripType, forKey: tripType)
                taxiRideObject[0].setValue(taxiRide.journeyType, forKey: journeyType)
                taxiRideObject[0].setValue(taxiRide.taxiVehicleCategory, forKey: taxiVehicleCategory)
                taxiRideObject[0].setValue(taxiRide.taxiType, forKey: taxiType)
                taxiRideObject[0].setValue(taxiRide.shareType, forKey: shareType)
                taxiRideObject[0].setValue(taxiRide.status, forKey: status)
                taxiRideObject[0].setValue(taxiRide.noOfSeats, forKey: noOfSeats)
                taxiRideObject[0].setValue(taxiRide.distance, forKey: distance)
                taxiRideObject[0].setValue(taxiRide.initialFare, forKey: initialFare)
                taxiRideObject[0].setValue(taxiRide.advanceFare, forKey: advanceFare)
                taxiRideObject[0].setValue(taxiRide.finalFare, forKey: finalFare)
                taxiRideObject[0].setValue(taxiRide.taxiRideJoinTimeMs, forKey: taxiRideJoinTimeMs)
                taxiRideObject[0].setValue(taxiRide.pickupTimeMs, forKey: pickupTimeMs)
//                taxiRideObject[0].setValue(taxiRide.pickupOrder, forKey: pickupOrder)
                taxiRideObject[0].setValue(taxiRide.dropTimeMs, forKey: dropTimeMs)
//                taxiRideObject[0].setValue(taxiRide.dropOrder, forKey: dropOrder)
                taxiRideObject[0].setValue(taxiRide.finalDistance, forKey: finalDistance)
                taxiRideObject[0].setValue(taxiRide.deviatedFromOriginalRoute, forKey: deviatedFromOriginalRoute)
                taxiRideObject[0].setValue(taxiRide.actualStartTimeMs, forKey: actualStartTimeMs)
                taxiRideObject[0].setValue(taxiRide.actualEndTimeMs, forKey: actualEndTimeMs)
                taxiRideObject[0].setValue(taxiRide.taxiRideUnjoinTimeMs, forKey: taxiRideUnjoinTimeMs)
                taxiRideObject[0].setValue(taxiRide.taxiUnjoinReason, forKey: taxiUnjoinReason)
                taxiRideObject[0].setValue(taxiRide.cancellationAmount, forKey: cancellationAmount)
                taxiRideObject[0].setValue(taxiRide.routeId, forKey: routeId)
                taxiRideObject[0].setValue(taxiRide.wayPoints, forKey: wayPoints)
                taxiRideObject[0].setValue(taxiRide.refRequestId, forKey: refRequestId)
                taxiRideObject[0].setValue(taxiRide.singleSharingOn, forKey: singleSharingOn)
                taxiRideObject[0].setValue(taxiRide.pickupOtp, forKey: pickupOtp)
                taxiRideObject[0].setValue(taxiRide.pickupReachedTimeMs, forKey: pickupReachedTimeMs)
                taxiRideObject[0].setValue(taxiRide.dropOtp, forKey: dropOtp)
                taxiRideObject[0].setValue(taxiRide.creationTimeMs, forKey: creationTimeMs)
                taxiRideObject[0].setValue(taxiRide.modifiedTimeMs, forKey: modifiedTimeMs)
                taxiRideObject[0].setValue(taxiRide.routePolyline, forKey: routePolyline)
                taxiRideObject[0].setValue(taxiRide.version, forKey: version)
                taxiRideObject[0].setValue(taxiRide.pickupRouteId, forKey: pickupRouteId)
                taxiRideObject[0].setValue(taxiRide.pickupRoutePolyline, forKey: pickupRoutePolyline)
                taxiRideObject[0].setValue(taxiRide.pendingAmount, forKey: pendingAmount)
                taxiRideObject[0].setValue(taxiRide.paymentType, forKey: paymentType)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    static func deleteTaxiRide(taxiRideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taxiRidePassengerTable)
                fetchRequest.predicate = NSPredicate(format: "\(taxiRideid) == %@",argumentArray: [taxiRideid])
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func getAllActiveTaxiTrips() -> [TaxiRidePassenger]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: taxiRidePassengerTable)
        var activeRides  = [TaxiRidePassenger]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let taxiRide = TaxiRidePassenger()
                
                taxiRide.id = userManagedObject.value(forKey: id) as? Double
                taxiRide.userId = userManagedObject.value(forKey: userId) as? Double
                taxiRide.userName = userManagedObject.value(forKey: userName) as? String
                taxiRide.contactNo = userManagedObject.value(forKey: contactNo) as? String
                taxiRide.email = userManagedObject.value(forKey: email) as? String
                taxiRide.imageURI = userManagedObject.value(forKey: imageURI) as? String
                taxiRide.taxiGroupId = userManagedObject.value(forKey: taxiGroupId) as? Double
                taxiRide.startTimeMs = userManagedObject.value(forKey: startTimeMs) as? Double
                taxiRide.expectedEndTimeMs = userManagedObject.value(forKey: expectedEndTimeMs) as? Double
                taxiRide.startAddress = userManagedObject.value(forKey: startAddress) as? String
                taxiRide.startLat = userManagedObject.value(forKey: startLat) as? Double
                taxiRide.startLng = userManagedObject.value(forKey: startLng) as? Double
                taxiRide.endAddress = userManagedObject.value(forKey: endAddress) as? String
                taxiRide.endLat = userManagedObject.value(forKey: endLat) as? Double
                taxiRide.endLng = userManagedObject.value(forKey: endLng) as? Double
                taxiRide.tripType = userManagedObject.value(forKey: tripType) as? String
                taxiRide.journeyType = userManagedObject.value(forKey: journeyType) as? String
                taxiRide.taxiVehicleCategory = userManagedObject.value(forKey: taxiVehicleCategory) as? String
                taxiRide.taxiType = userManagedObject.value(forKey: taxiType) as? String
                taxiRide.shareType = userManagedObject.value(forKey: shareType) as? String
                taxiRide.status = userManagedObject.value(forKey: status) as? String
                taxiRide.noOfSeats = userManagedObject.value(forKey: noOfSeats) as? Int ?? 1
                taxiRide.distance = userManagedObject.value(forKey: distance) as? Double
                taxiRide.initialFare = userManagedObject.value(forKey: initialFare) as? Double
                taxiRide.advanceFare = userManagedObject.value(forKey: advanceFare) as? Double
                taxiRide.finalFare = userManagedObject.value(forKey: finalFare) as? Double
                taxiRide.taxiRideJoinTimeMs = userManagedObject.value(forKey: taxiRideJoinTimeMs) as? Double
                taxiRide.pickupTimeMs = userManagedObject.value(forKey: pickupTimeMs) as? Double
//                taxiRide.pickupOrder = userManagedObject.value(forKey: pickupOrder) as? Int
                taxiRide.dropTimeMs = userManagedObject.value(forKey: dropTimeMs) as? Double
//                taxiRide.dropOrder = userManagedObject.value(forKey: dropOrder) as? Int
                taxiRide.finalDistance = userManagedObject.value(forKey: finalDistance) as? Double
                taxiRide.deviatedFromOriginalRoute = userManagedObject.value(forKey: deviatedFromOriginalRoute) as? Bool
                taxiRide.actualStartTimeMs = userManagedObject.value(forKey: actualStartTimeMs) as? Double
                taxiRide.actualEndTimeMs = userManagedObject.value(forKey: actualEndTimeMs) as? Double
                taxiRide.taxiRideUnjoinTimeMs = userManagedObject.value(forKey: taxiRideUnjoinTimeMs) as? Double
                taxiRide.taxiUnjoinReason = userManagedObject.value(forKey: taxiUnjoinReason) as? String
                taxiRide.cancellationAmount = userManagedObject.value(forKey: cancellationAmount) as? Double
                taxiRide.routeId = userManagedObject.value(forKey: routeId) as? Double
                taxiRide.wayPoints = userManagedObject.value(forKey: wayPoints) as? String
                taxiRide.refRequestId = userManagedObject.value(forKey: refRequestId) as? String
                taxiRide.singleSharingOn = userManagedObject.value(forKey: singleSharingOn) as? Bool
                taxiRide.pickupOtp = userManagedObject.value(forKey: pickupOtp) as? String
                taxiRide.pickupReachedTimeMs = userManagedObject.value(forKey: pickupReachedTimeMs) as? Double
                taxiRide.dropOtp = userManagedObject.value(forKey: dropOtp) as? String
                taxiRide.creationTimeMs = userManagedObject.value(forKey: creationTimeMs) as? Double
                taxiRide.modifiedTimeMs = userManagedObject.value(forKey: modifiedTimeMs) as? Double
                taxiRide.routePolyline = userManagedObject.value(forKey: routePolyline) as? String
                taxiRide.version = userManagedObject.value(forKey: version) as? Int
                taxiRide.pickupRouteId = userManagedObject.value(forKey: pickupRouteId) as? Double
                taxiRide.pickupRoutePolyline = userManagedObject.value(forKey: pickupRoutePolyline) as? String
                taxiRide.pendingAmount = userManagedObject.value(forKey: pendingAmount) as? Double ?? 0
                taxiRide.paymentType = userManagedObject.value(forKey: paymentType) as? String
                activeRides.append(taxiRide)
            }
        }
        var activeRidesDict  = [Double : TaxiRidePassenger]()
        for activeRide in activeRides {
            if let taxiRideId = activeRide.id {
                activeRidesDict[taxiRideId] = activeRide
            }
        }
        return Array(activeRidesDict.values)
    }
    
    //MARK: Closed trips
    static func storeAllClosedTaxiRides(taxiRides: [TaxiRidePassenger]){
        clearTableForEntity(entityName: closedTaxiRidePassengerTable)
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for taxiRide in taxiRides{
                prepareClosedTaxiRideAndStore(taxiRide: taxiRide, managedContext: managedContext)
            }
        }
    }
    
    static func saveClosedTaxiRide(taxiRide : TaxiRidePassenger){
      let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            prepareClosedTaxiRideAndStore(taxiRide: taxiRide, managedContext: managedContext)
        }
    }
    
    static func prepareClosedTaxiRideAndStore(taxiRide: TaxiRidePassenger,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: closedTaxiRidePassengerTable, in: managedContext)
        let taxiRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        taxiRideObject.setValue(taxiRide.id, forKey: id)
        taxiRideObject.setValue(taxiRide.userId, forKey: userId)
        taxiRideObject.setValue(taxiRide.userName, forKey: userName)
        taxiRideObject.setValue(taxiRide.contactNo, forKey: contactNo)
        taxiRideObject.setValue(taxiRide.email, forKey: email)
        taxiRideObject.setValue(taxiRide.imageURI, forKey: imageURI)
        taxiRideObject.setValue(taxiRide.taxiGroupId, forKey: taxiGroupId)
        taxiRideObject.setValue(taxiRide.startTimeMs, forKey: startTimeMs)
        taxiRideObject.setValue(taxiRide.expectedEndTimeMs, forKey: expectedEndTimeMs)
        taxiRideObject.setValue(taxiRide.startAddress, forKey: startAddress)
        taxiRideObject.setValue(taxiRide.startLat, forKey: startLat)
        taxiRideObject.setValue(taxiRide.startLng, forKey: startLng)
        taxiRideObject.setValue(taxiRide.endAddress, forKey: endAddress)
        taxiRideObject.setValue(taxiRide.endLat, forKey: endLat)
        taxiRideObject.setValue(taxiRide.endLng, forKey: endLng)
        taxiRideObject.setValue(taxiRide.tripType, forKey: tripType)
        taxiRideObject.setValue(taxiRide.journeyType, forKey: journeyType)
        taxiRideObject.setValue(taxiRide.taxiVehicleCategory, forKey: taxiVehicleCategory)
        taxiRideObject.setValue(taxiRide.taxiType, forKey: taxiType)
        taxiRideObject.setValue(taxiRide.shareType, forKey: shareType)
        taxiRideObject.setValue(taxiRide.status, forKey: status)
        taxiRideObject.setValue(taxiRide.noOfSeats, forKey: noOfSeats)
        taxiRideObject.setValue(taxiRide.distance, forKey: distance)
        taxiRideObject.setValue(taxiRide.initialFare, forKey: initialFare)
        taxiRideObject.setValue(taxiRide.advanceFare, forKey: advanceFare)
        taxiRideObject.setValue(taxiRide.finalFare, forKey: finalFare)
        taxiRideObject.setValue(taxiRide.taxiRideJoinTimeMs, forKey: taxiRideJoinTimeMs)
        taxiRideObject.setValue(taxiRide.pickupTimeMs, forKey: pickupTimeMs)
//        taxiRideObject.setValue(taxiRide.pickupOrder, forKey: pickupOrder)
        taxiRideObject.setValue(taxiRide.dropTimeMs, forKey: dropTimeMs)
//        taxiRideObject.setValue(taxiRide.dropOrder, forKey: dropOrder)
        taxiRideObject.setValue(taxiRide.finalDistance, forKey: finalDistance)
        taxiRideObject.setValue(taxiRide.deviatedFromOriginalRoute, forKey: deviatedFromOriginalRoute)
        taxiRideObject.setValue(taxiRide.actualStartTimeMs, forKey: actualStartTimeMs)
        taxiRideObject.setValue(taxiRide.actualEndTimeMs, forKey: actualEndTimeMs)
        taxiRideObject.setValue(taxiRide.taxiRideUnjoinTimeMs, forKey: taxiRideUnjoinTimeMs)
        taxiRideObject.setValue(taxiRide.taxiUnjoinReason, forKey: taxiUnjoinReason)
        taxiRideObject.setValue(taxiRide.cancellationAmount, forKey: cancellationAmount)
        taxiRideObject.setValue(taxiRide.routeId, forKey: routeId)
        taxiRideObject.setValue(taxiRide.wayPoints, forKey: wayPoints)
        taxiRideObject.setValue(taxiRide.refRequestId, forKey: refRequestId)
        taxiRideObject.setValue(taxiRide.singleSharingOn, forKey: singleSharingOn)
        taxiRideObject.setValue(taxiRide.pickupOtp, forKey: pickupOtp)
        taxiRideObject.setValue(taxiRide.pickupReachedTimeMs, forKey: pickupReachedTimeMs)
        taxiRideObject.setValue(taxiRide.dropOtp, forKey: dropOtp)
        taxiRideObject.setValue(taxiRide.creationTimeMs, forKey: creationTimeMs)
        taxiRideObject.setValue(taxiRide.modifiedTimeMs, forKey: modifiedTimeMs)
        taxiRideObject.setValue(taxiRide.routePolyline, forKey: routePolyline)
        taxiRideObject.setValue(taxiRide.version, forKey: version)
        taxiRideObject.setValue(taxiRide.pickupRouteId, forKey: pickupRouteId)
        taxiRideObject.setValue(taxiRide.pickupRoutePolyline, forKey: pickupRoutePolyline)
        taxiRideObject.setValue(taxiRide.pendingAmount, forKey: pendingAmount)
        taxiRideObject.setValue(taxiRide.paymentType, forKey: paymentType)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getClosedTaxiTrips() -> [TaxiRidePassenger]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: closedTaxiRidePassengerTable)
        var closedTaxiRides  = [TaxiRidePassenger]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let taxiRide = TaxiRidePassenger()
                
                taxiRide.id = userManagedObject.value(forKey: id) as? Double
                taxiRide.userId = userManagedObject.value(forKey: userId) as? Double
                taxiRide.userName = userManagedObject.value(forKey: userName) as? String
                taxiRide.contactNo = userManagedObject.value(forKey: contactNo) as? String
                taxiRide.email = userManagedObject.value(forKey: email) as? String
                taxiRide.imageURI = userManagedObject.value(forKey: imageURI) as? String
                taxiRide.taxiGroupId = userManagedObject.value(forKey: taxiGroupId) as? Double
                taxiRide.startTimeMs = userManagedObject.value(forKey: startTimeMs) as? Double
                taxiRide.expectedEndTimeMs = userManagedObject.value(forKey: expectedEndTimeMs) as? Double
                taxiRide.startAddress = userManagedObject.value(forKey: startAddress) as? String
                taxiRide.startLat = userManagedObject.value(forKey: startLat) as? Double
                taxiRide.startLng = userManagedObject.value(forKey: startLng) as? Double
                taxiRide.endAddress = userManagedObject.value(forKey: endAddress) as? String
                taxiRide.endLat = userManagedObject.value(forKey: endLat) as? Double
                taxiRide.endLng = userManagedObject.value(forKey: endLng) as? Double
                taxiRide.tripType = userManagedObject.value(forKey: tripType) as? String
                taxiRide.journeyType = userManagedObject.value(forKey: journeyType) as? String
                taxiRide.taxiVehicleCategory = userManagedObject.value(forKey: taxiVehicleCategory) as? String
                taxiRide.taxiType = userManagedObject.value(forKey: taxiType) as? String
                taxiRide.shareType = userManagedObject.value(forKey: shareType) as? String
                taxiRide.status = userManagedObject.value(forKey: status) as? String
                taxiRide.noOfSeats = userManagedObject.value(forKey: noOfSeats) as? Int ?? 1
                taxiRide.distance = userManagedObject.value(forKey: distance) as? Double
                taxiRide.initialFare = userManagedObject.value(forKey: initialFare) as? Double
                taxiRide.advanceFare = userManagedObject.value(forKey: advanceFare) as? Double
                taxiRide.finalFare = userManagedObject.value(forKey: finalFare) as? Double
                taxiRide.taxiRideJoinTimeMs = userManagedObject.value(forKey: taxiRideJoinTimeMs) as? Double
                taxiRide.pickupTimeMs = userManagedObject.value(forKey: pickupTimeMs) as? Double
//                taxiRide.pickupOrder = userManagedObject.value(forKey: pickupOrder) as? Int
                taxiRide.dropTimeMs = userManagedObject.value(forKey: dropTimeMs) as? Double
//                taxiRide.dropOrder = userManagedObject.value(forKey: dropOrder) as? Int
                taxiRide.finalDistance = userManagedObject.value(forKey: finalDistance) as? Double
                taxiRide.deviatedFromOriginalRoute = userManagedObject.value(forKey: deviatedFromOriginalRoute) as? Bool
                taxiRide.actualStartTimeMs = userManagedObject.value(forKey: actualStartTimeMs) as? Double
                taxiRide.actualEndTimeMs = userManagedObject.value(forKey: actualEndTimeMs) as? Double
                taxiRide.taxiRideUnjoinTimeMs = userManagedObject.value(forKey: taxiRideUnjoinTimeMs) as? Double
                taxiRide.taxiUnjoinReason = userManagedObject.value(forKey: taxiUnjoinReason) as? String
                taxiRide.cancellationAmount = userManagedObject.value(forKey: cancellationAmount) as? Double
                taxiRide.routeId = userManagedObject.value(forKey: routeId) as? Double
                taxiRide.wayPoints = userManagedObject.value(forKey: wayPoints) as? String
                taxiRide.refRequestId = userManagedObject.value(forKey: refRequestId) as? String
                taxiRide.singleSharingOn = userManagedObject.value(forKey: singleSharingOn) as? Bool
                taxiRide.pickupOtp = userManagedObject.value(forKey: pickupOtp) as? String
                taxiRide.pickupReachedTimeMs = userManagedObject.value(forKey: pickupReachedTimeMs) as? Double
                taxiRide.dropOtp = userManagedObject.value(forKey: dropOtp) as? String
                taxiRide.creationTimeMs = userManagedObject.value(forKey: creationTimeMs) as? Double
                taxiRide.modifiedTimeMs = userManagedObject.value(forKey: modifiedTimeMs) as? Double
                taxiRide.routePolyline = userManagedObject.value(forKey: routePolyline) as? String
                taxiRide.version = userManagedObject.value(forKey: version) as? Int
                taxiRide.pickupRouteId = userManagedObject.value(forKey: pickupRouteId) as? Double
                taxiRide.pickupRoutePolyline = userManagedObject.value(forKey: pickupRoutePolyline) as? String
                taxiRide.pendingAmount = userManagedObject.value(forKey: pendingAmount) as? Double ?? 0
                taxiRide.paymentType = userManagedObject.value(forKey: paymentType) as? String
                closedTaxiRides.append(taxiRide)
            }
        }
        return closedTaxiRides
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
