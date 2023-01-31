//
//  MyRidesPersistenceHelper.swift
//  Quickride
//
//  Created by rakesh on 10/13/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreData

class MyRidesPersistenceHelper : CoreDataHelper{
    
      static let rideId = "rideId"
      static let userId = "userId"
      static let userName = "userName"
      static let rideType = "rideType"
      static let startAddress = "startAddress"
      static let startLatitude = "startLatitude"
      static let startLongitude = "startLongitude"
      static let endAddress = "endAddress"
      static let endLatitude = "endLatitude"
      static let endLongitude = "endLongitude"
      static let distance = "distance"
      static let startTime = "startTime"
      static let expectedEndTime = "expectedEndTime"
      static let status = "status"
      static let routePathPolyline = "routePathPolyline"
      static let actualStartTime = "actualStartTime"
      static let actualEndtime = "actualEndtime"
      static let waypoints = "waypoints"
      static let routeId = "routeId"
      static let rideNotes = "rideNotes"
      static let allowRideMatchToJoinedGroups = "allowRideMatchToJoinedGroups"
      static let showMeToJoinedGroups = "showMeToJoinedGroups"
    
      static let riderId = "riderId"
      static let riderName = "riderName"
      static let points = "points"
      static let newFare = "newFare"
      static let pickupAddress = "pickupAddress"
      static let pickupLatitude = "pickupLatitude"
      static let pickupLongitude = "pickupLongitude"
      static let overLappingDistance = "overLappingDistance"
      static let pickupTime = "pickupTime"
      static let dropAddress = "dropAddress"
      static let dropLatitude = "dropLatitude"
      static let dropLongitude = "dropLongitude"
      static let dropTime = "dropTime"
      static let pickupAndDropRoutePolyline = "pickupAndDropRoutePolyline"
      static let riderRideId = "riderRideId"
      static let noOfSeats = "noOfSeats"
      static let taxiRideId = "taxiRideId"
      static let parentId = "parentId"
      static let relayLeg = "relayLeg"
    
      static let vehicleNumber = "vehicleNumber"
      static let vehicleModel = "vehicleModel"
      static let farePerKm = "farePerKm"
      static let noOfPassengers = "noOfPassengers"
      static let availableSeats = "availableSeats"
      static let capacity = "capacity"
      static let riderPathTravelled = "riderPathTravelled"
      static let additionalFacilities = "additionalFacilities"
      static let makeAndCategory = "makeAndCategory"
      static let riderHasHelmet = "riderHasHelmet"
      static let vehicleType = "vehicleType"
      static let vehicleId = "vehicleId"
      static let vehicleImageURI = "vehicleImageURI"
      static let freezeRide = "freezeRide"
      static let cumulativeOverlapDistance = "cumulativeOverlapDistance"
      static let regularRiderRideId = "regularRiderRideId"
    
      static let fromDate = "fromDate"
      static let toDate = "toDate"
      static let sunday = "sunday"
      static let monday = "monday"
      static let tuesday = "tuesday"
      static let wednesday = "wednesday"
      static let thursday = "thursday"
      static let friday = "friday"
      static let saturday = "saturday"
      static let dayType = "dayType"
    
      static let riderRideTable = "RiderRide"
      static let passengerRideTable = "PassengerRide"
      static let regularRiderRideTable = "RegularRiderRide"
      static let regularPassengerRideTable = "RegularPassengerRide"
      static let closedRiderRideTable = "ClosedRiderRide"
      static let closedPassengerRideTable = "ClosedPassengerRide"
    
      static func storeRiderRidesInBulk(riderRides : [RiderRide]){
      
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            for riderRide in riderRides{
                prepareRiderRideEntityAndStore(riderRide: riderRide, managedContext: managedContext)
            }
        }
    }
    
    static func storeRiderRide(riderRide : RiderRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
           prepareRiderRideEntityAndStore(riderRide: riderRide, managedContext: managedContext)
            
        }
    }
    
    static func prepareRiderRideEntityAndStore(riderRide : RiderRide,managedContext : NSManagedObjectContext){
        
        let entity = NSEntityDescription.entity(forEntityName: riderRideTable, in: managedContext)
        let riderRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        riderRideObject.setValue(riderRide.rideId, forKey: rideId)
        riderRideObject.setValue(riderRide.userId, forKey: userId)
        riderRideObject.setValue(riderRide.userName, forKey: userName)
        riderRideObject.setValue(riderRide.rideType, forKey: rideType)
        riderRideObject.setValue(riderRide.startAddress, forKey: startAddress)
        riderRideObject.setValue(riderRide.startLatitude, forKey: startLatitude)
        riderRideObject.setValue(riderRide.startLongitude, forKey: startLongitude)
        riderRideObject.setValue(riderRide.startTime, forKey: startTime)
        riderRideObject.setValue(riderRide.endAddress, forKey: endAddress)
        riderRideObject.setValue(riderRide.endLatitude, forKey: endLatitude)
        riderRideObject.setValue(riderRide.endLongitude, forKey: endLongitude)
        riderRideObject.setValue(riderRide.distance, forKey: distance)
        riderRideObject.setValue(riderRide.expectedEndTime, forKey: expectedEndTime)
        riderRideObject.setValue(riderRide.status, forKey: status)
        riderRideObject.setValue(riderRide.routePathPolyline, forKey: routePathPolyline)
        riderRideObject.setValue(riderRide.actualStartTime, forKey: actualStartTime)
        riderRideObject.setValue(riderRide.actualEndtime, forKey: actualEndtime)
        riderRideObject.setValue(riderRide.waypoints, forKey: waypoints)
        riderRideObject.setValue(riderRide.routeId, forKey: routeId)
        riderRideObject.setValue(riderRide.rideNotes, forKey: rideNotes)
        riderRideObject.setValue(riderRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        riderRideObject.setValue(riderRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        
        riderRideObject.setValue(riderRide.vehicleNumber, forKey: vehicleNumber)
        riderRideObject.setValue(riderRide.vehicleModel, forKey: vehicleModel)
        riderRideObject.setValue(riderRide.farePerKm, forKey: farePerKm)
        riderRideObject.setValue(riderRide.noOfPassengers, forKey: noOfPassengers)
        riderRideObject.setValue(riderRide.availableSeats, forKey: availableSeats)
        riderRideObject.setValue(riderRide.capacity, forKey: capacity)
        riderRideObject.setValue(riderRide.riderPathTravelled, forKey: riderPathTravelled)
        riderRideObject.setValue(riderRide.makeAndCategory, forKey: makeAndCategory)
        riderRideObject.setValue(riderRide.additionalFacilities, forKey: additionalFacilities)
        riderRideObject.setValue(riderRide.vehicleType, forKey: vehicleType)
        riderRideObject.setValue(riderRide.freezeRide, forKey: freezeRide)
        riderRideObject.setValue(riderRide.cumulativeOverlapDistance, forKey: cumulativeOverlapDistance)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func storeClosedRiderRidesInBulk(riderRides : [RiderRide]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            for riderRide in riderRides{
                prepareClosedRiderRideObjAndStore(riderRide: riderRide, managedContext: managedContext)
            }
        }
    }
    
    static func saveClosedRiderRide(riderRide : RiderRide){
      let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            prepareClosedRiderRideObjAndStore(riderRide: riderRide, managedContext: managedContext)
        }
    }
    
    static func prepareClosedRiderRideObjAndStore(riderRide : RiderRide,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: closedRiderRideTable, in: managedContext)
        let riderRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        riderRideObject.setValue(riderRide.rideId, forKey: rideId)
        riderRideObject.setValue(riderRide.userId, forKey: userId)
        riderRideObject.setValue(riderRide.userName, forKey: userName)
        riderRideObject.setValue(riderRide.rideType, forKey: rideType)
        riderRideObject.setValue(riderRide.startAddress, forKey: startAddress)
        riderRideObject.setValue(riderRide.startLatitude, forKey: startLatitude)
        riderRideObject.setValue(riderRide.startLongitude, forKey: startLongitude)
        riderRideObject.setValue(riderRide.startTime, forKey: startTime)
        riderRideObject.setValue(riderRide.endAddress, forKey: endAddress)
        riderRideObject.setValue(riderRide.endLatitude, forKey: endLatitude)
        riderRideObject.setValue(riderRide.endLongitude, forKey: endLongitude)
        riderRideObject.setValue(riderRide.distance, forKey: distance)
        riderRideObject.setValue(riderRide.expectedEndTime, forKey: expectedEndTime)
        riderRideObject.setValue(riderRide.status, forKey: status)
        riderRideObject.setValue(riderRide.routePathPolyline, forKey: routePathPolyline)
        riderRideObject.setValue(riderRide.actualStartTime, forKey: actualStartTime)
        riderRideObject.setValue(riderRide.actualEndtime, forKey: actualEndtime)
        riderRideObject.setValue(riderRide.waypoints, forKey: waypoints)
        riderRideObject.setValue(riderRide.routeId, forKey: routeId)
        riderRideObject.setValue(riderRide.rideNotes, forKey: rideNotes)
        riderRideObject.setValue(riderRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        riderRideObject.setValue(riderRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        
        riderRideObject.setValue(riderRide.vehicleNumber, forKey: vehicleNumber)
        riderRideObject.setValue(riderRide.vehicleModel, forKey: vehicleModel)
        riderRideObject.setValue(riderRide.farePerKm, forKey: farePerKm)
        riderRideObject.setValue(riderRide.noOfPassengers, forKey: noOfPassengers)
        riderRideObject.setValue(riderRide.availableSeats, forKey: availableSeats)
        riderRideObject.setValue(riderRide.capacity, forKey: capacity)
        riderRideObject.setValue(riderRide.riderPathTravelled, forKey: riderPathTravelled)
        riderRideObject.setValue(riderRide.makeAndCategory, forKey: makeAndCategory)
        riderRideObject.setValue(riderRide.additionalFacilities, forKey: additionalFacilities)
        riderRideObject.setValue(riderRide.vehicleType, forKey: vehicleType)
        riderRideObject.setValue(riderRide.freezeRide, forKey: freezeRide)
        riderRideObject.setValue(riderRide.cumulativeOverlapDistance, forKey: cumulativeOverlapDistance)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)

    }
    
    static func storeClosedPassengerRidesInBulk(passengerRides : [PassengerRide]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            
            for passengerRide in passengerRides{
               prepareClosedPassengerRideObjAndStore(passengerRide: passengerRide, managedContext: managedContext)
            }
        }
    }
    
    static func saveClosedPassengerRide(passengerRide : PassengerRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
           prepareClosedPassengerRideObjAndStore(passengerRide: passengerRide, managedContext: managedContext)
        }
    }
    
    static func prepareClosedPassengerRideObjAndStore(passengerRide : PassengerRide,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: closedPassengerRideTable, in: managedContext)
        let passengerRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        passengerRideObject.setValue(passengerRide.rideId, forKey: rideId)
        passengerRideObject.setValue(passengerRide.userId, forKey: userId)
        passengerRideObject.setValue(passengerRide.userName, forKey: userName)
        passengerRideObject.setValue(passengerRide.rideType, forKey: rideType)
        passengerRideObject.setValue(passengerRide.startAddress, forKey: startAddress)
        passengerRideObject.setValue(passengerRide.startLatitude, forKey: startLatitude)
        passengerRideObject.setValue(passengerRide.startLongitude, forKey: startLongitude)
        passengerRideObject.setValue(passengerRide.startTime, forKey: startTime)
        passengerRideObject.setValue(passengerRide.endAddress, forKey: endAddress)
        passengerRideObject.setValue(passengerRide.endLatitude, forKey: endLatitude)
        passengerRideObject.setValue(passengerRide.endLongitude, forKey: endLongitude)
        passengerRideObject.setValue(passengerRide.distance, forKey: distance)
        passengerRideObject.setValue(passengerRide.expectedEndTime, forKey: expectedEndTime)
        passengerRideObject.setValue(passengerRide.status, forKey: status)
        passengerRideObject.setValue(passengerRide.routePathPolyline, forKey: routePathPolyline)
        passengerRideObject.setValue(passengerRide.actualStartTime, forKey: actualStartTime)
        passengerRideObject.setValue(passengerRide.actualEndtime, forKey: actualEndtime)
        passengerRideObject.setValue(passengerRide.waypoints, forKey: waypoints)
        passengerRideObject.setValue(passengerRide.routeId, forKey: routeId)
        passengerRideObject.setValue(passengerRide.rideNotes, forKey: rideNotes)
        passengerRideObject.setValue(passengerRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        passengerRideObject.setValue(passengerRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        passengerRideObject.setValue(passengerRide.riderId, forKey: riderId)
        passengerRideObject.setValue(passengerRide.riderName, forKey: riderName)
        passengerRideObject.setValue(passengerRide.points, forKey: points)
        passengerRideObject.setValue(passengerRide.newFare, forKey: newFare)
        passengerRideObject.setValue(passengerRide.pickupAddress, forKey: pickupAddress)
        passengerRideObject.setValue(passengerRide.pickupLatitude, forKey: pickupLatitude)
        passengerRideObject.setValue(passengerRide.pickupLongitude, forKey: pickupLongitude)
        passengerRideObject.setValue(passengerRide.overLappingDistance, forKey: overLappingDistance)
        passengerRideObject.setValue(passengerRide.pickupTime, forKey: pickupTime)
        passengerRideObject.setValue(passengerRide.dropAddress, forKey: dropAddress)
        passengerRideObject.setValue(passengerRide.dropLatitude, forKey: dropLatitude)
        passengerRideObject.setValue(passengerRide.dropLongitude, forKey: dropLongitude)
        passengerRideObject.setValue(passengerRide.dropTime, forKey: dropTime)
        passengerRideObject.setValue(passengerRide.pickupAndDropRoutePolyline, forKey: pickupAndDropRoutePolyline)
        passengerRideObject.setValue(passengerRide.riderRideId, forKey: riderRideId)
        passengerRideObject.setValue(passengerRide.noOfSeats, forKey: noOfSeats)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getClosedRiderRides() -> [RiderRide]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: closedRiderRideTable)
        var riderRides  = [RiderRide]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let riderRideObject = RiderRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                  riderRideObject.rideId = rideId
                }
                
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    riderRideObject.userId = userId
                }
                
                riderRideObject.userName = userManagedObject.value(forKey: userName) as? String
                riderRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                  riderRideObject.startAddress = startAddress
                }
                
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    riderRideObject.startLatitude = startLatitude
                }
                
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    riderRideObject.startLongitude = startLongitude
                }
                
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    riderRideObject.startTime = startTime
                }
                
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    riderRideObject.endAddress = endAddress
                }
                
                riderRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                riderRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                riderRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                riderRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                
                if let status = userManagedObject.value(forKey: status) as? String{
                  riderRideObject.status = status
                }
                
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    riderRideObject.routePathPolyline = routePathPolyline
                }
    
                riderRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                riderRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                riderRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                riderRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                riderRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                   riderRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    riderRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let vehicleModel = userManagedObject.value(forKey: vehicleModel) as? String{
                    riderRideObject.vehicleModel = vehicleModel
                }
                
                if let vehicleId = userManagedObject.value(forKey: vehicleId) as? Double{
                    riderRideObject.vehicleId = vehicleId
                }
               
                riderRideObject.vehicleNumber = userManagedObject.value(forKey: vehicleNumber) as? String
                riderRideObject.vehicleType = userManagedObject.value(forKey: vehicleType) as? String
                riderRideObject.vehicleImageURI = userManagedObject.value(forKey: vehicleImageURI) as? String
                if let farePerKm = userManagedObject.value(forKey: farePerKm) as? Double{
                  riderRideObject.farePerKm = farePerKm
                }
                
                if let noOfPassengers = userManagedObject.value(forKey: noOfPassengers) as? Int{
                    riderRideObject.noOfPassengers = noOfPassengers
                }
                if let availableSeats = userManagedObject.value(forKey: availableSeats) as? Int{
                    riderRideObject.availableSeats = availableSeats
                }
                
                if let capacity = userManagedObject.value(forKey: capacity) as? Int{
                    riderRideObject.capacity = capacity
                }
                
                riderRideObject.riderPathTravelled = userManagedObject.value(forKey: riderPathTravelled) as? String
                
                if let freezeRide = userManagedObject.value(forKey: freezeRide) as? Bool{
                    riderRideObject.freezeRide = freezeRide
                }
                riderRideObject.makeAndCategory = userManagedObject.value(forKey: makeAndCategory) as? String
                riderRideObject.additionalFacilities = userManagedObject.value(forKey: additionalFacilities) as? String
                if let cumulativeOverlapDistance = userManagedObject.value(forKey: cumulativeOverlapDistance) as? Double{
                    riderRideObject.cumulativeOverlapDistance = cumulativeOverlapDistance
                }
                riderRides.append(riderRideObject)
            }
        }
        
        return riderRides
        
    }
    
    static func getClosedPassengerRides() -> [PassengerRide]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: closedPassengerRideTable)
        var passengerRides  = [PassengerRide]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let passengerRideObject = PassengerRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                   passengerRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    passengerRideObject.userId = userId
                }
                passengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                passengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    passengerRideObject.startAddress = startAddress
                }
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    passengerRideObject.startLatitude = startLatitude
                }
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    passengerRideObject.startLongitude = startLongitude
                }
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    passengerRideObject.startTime = startTime
                }
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    passengerRideObject.endAddress = endAddress
                }
               
                passengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                passengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                passengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                passengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                
                if let status = userManagedObject.value(forKey: status) as? String{
                    passengerRideObject.status = status
                }
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    passengerRideObject.routePathPolyline = routePathPolyline
                }
               
                passengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                passengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                passengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                passengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                passengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    passengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    passengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                    passengerRideObject.riderId = riderId
                }
                
                if let riderName = userManagedObject.value(forKey: riderName) as? String{
                    passengerRideObject.riderName = riderName
                }
                
                if let points = userManagedObject.value(forKey: points) as? Double{
                    passengerRideObject.points = points
                }
                
                if let newFare = userManagedObject.value(forKey: newFare) as? Double{
                    passengerRideObject.newFare = newFare
                }
                
                if let pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String{
                    passengerRideObject.pickupAddress = pickupAddress
                }
                
                if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                    passengerRideObject.pickupLatitude = pickupLatitude
                }
                if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                    passengerRideObject.pickupLongitude = pickupLongitude
                }
                if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                    passengerRideObject.pickupTime = pickupTime
                }
                if let dropAddress = userManagedObject.value(forKey: dropAddress) as? String{
                    passengerRideObject.dropAddress = dropAddress
                }
                if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                    passengerRideObject.dropLatitude = dropLatitude
                }
                if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                    passengerRideObject.dropLongitude = dropLongitude
                }
                if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                    passengerRideObject.dropTime = dropTime
                }
                if let pickupAndDropRoutePolyline = userManagedObject.value(forKey: pickupAndDropRoutePolyline) as? String{
                    passengerRideObject.pickupAndDropRoutePolyline = pickupAndDropRoutePolyline
                }
                if let riderRideId = userManagedObject.value(forKey: riderRideId) as? Double{
                    passengerRideObject.riderRideId = riderRideId
                }
                if let noOfSeats = userManagedObject.value(forKey: noOfSeats) as? Int{
                    passengerRideObject.noOfSeats = noOfSeats
                }
                
                passengerRides.append(passengerRideObject)
            }
        }
        return passengerRides
    }
    
    
    static func getRiderRides() -> [RiderRide]{
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: riderRideTable)
        var riderRides  = [RiderRide]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
            
                let riderRideObject = RiderRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    riderRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    riderRideObject.userId = userId
                }
                riderRideObject.userName = userManagedObject.value(forKey: userName) as? String
                riderRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    riderRideObject.startAddress = startAddress
                }
                
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    riderRideObject.startLatitude = startLatitude
                }
                
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    riderRideObject.startLongitude = startLongitude
                }
                
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    riderRideObject.startTime = startTime
                }
                
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    riderRideObject.endAddress = endAddress
                }
            
                riderRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                riderRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                riderRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                riderRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    riderRideObject.status = status
                }
                
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    riderRideObject.routePathPolyline = routePathPolyline
                }
                riderRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                riderRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                riderRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                riderRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                riderRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    riderRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    riderRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let vehicleModel = userManagedObject.value(forKey: vehicleModel) as? String{
                    riderRideObject.vehicleModel = vehicleModel
                }
                
                if let vehicleId = userManagedObject.value(forKey: vehicleId) as? Double{
                    riderRideObject.vehicleId = vehicleId
                }
                 riderRideObject.vehicleNumber = userManagedObject.value(forKey: vehicleNumber) as? String
                 riderRideObject.vehicleType = userManagedObject.value(forKey: vehicleType) as? String
                 riderRideObject.vehicleImageURI = userManagedObject.value(forKey: vehicleImageURI) as? String
                if let farePerKm = userManagedObject.value(forKey: farePerKm) as? Double{
                    riderRideObject.farePerKm = farePerKm
                }
                
                if let noOfPassengers = userManagedObject.value(forKey: noOfPassengers) as? Int{
                    riderRideObject.noOfPassengers = noOfPassengers
                }
                if let availableSeats = userManagedObject.value(forKey: availableSeats) as? Int{
                    riderRideObject.availableSeats = availableSeats
                }
                
                if let capacity = userManagedObject.value(forKey: capacity) as? Int{
                    riderRideObject.capacity = capacity
                }
                
                 riderRideObject.riderPathTravelled = userManagedObject.value(forKey: riderPathTravelled) as? String
                if let freezeRide = userManagedObject.value(forKey: freezeRide) as? Bool{
                    riderRideObject.freezeRide = freezeRide
                }
                 riderRideObject.makeAndCategory = userManagedObject.value(forKey: makeAndCategory) as? String
                 riderRideObject.additionalFacilities = userManagedObject.value(forKey: additionalFacilities) as? String
                if let cumulativeOverlapDistance = userManagedObject.value(forKey: cumulativeOverlapDistance) as? Double{
                    riderRideObject.cumulativeOverlapDistance = cumulativeOverlapDistance
                }
                 riderRides.append(riderRideObject)
            }
        }
        
       return riderRides
        
    }
    
    
    static func storePassengerRidesInBulk(passengerRides : [PassengerRide]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for passengerRide in passengerRides{
              preparePassengerRideEntityAndStore(passengerRide: passengerRide, managedContext: managedContext)
            }
        }
    }
    
    static func storePassengerRide(passengerRide : PassengerRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
              preparePassengerRideEntityAndStore(passengerRide: passengerRide, managedContext: managedContext)
       }
    }
    
    static func preparePassengerRideEntityAndStore(passengerRide : PassengerRide,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: passengerRideTable, in: managedContext)
        let passengerRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        passengerRideObject.setValue(passengerRide.rideId, forKey: rideId)
        passengerRideObject.setValue(passengerRide.userId, forKey: userId)
        passengerRideObject.setValue(passengerRide.userName, forKey: userName)
        passengerRideObject.setValue(passengerRide.rideType, forKey: rideType)
        passengerRideObject.setValue(passengerRide.startAddress, forKey: startAddress)
        passengerRideObject.setValue(passengerRide.startLatitude, forKey: startLatitude)
        passengerRideObject.setValue(passengerRide.startLongitude, forKey: startLongitude)
        passengerRideObject.setValue(passengerRide.startTime, forKey: startTime)
        passengerRideObject.setValue(passengerRide.endAddress, forKey: endAddress)
        passengerRideObject.setValue(passengerRide.endLatitude, forKey: endLatitude)
        passengerRideObject.setValue(passengerRide.endLongitude, forKey: endLongitude)
        passengerRideObject.setValue(passengerRide.distance, forKey: distance)
        passengerRideObject.setValue(passengerRide.expectedEndTime, forKey: expectedEndTime)
        passengerRideObject.setValue(passengerRide.status, forKey: status)
        passengerRideObject.setValue(passengerRide.routePathPolyline, forKey: routePathPolyline)
        passengerRideObject.setValue(passengerRide.actualStartTime, forKey: actualStartTime)
        passengerRideObject.setValue(passengerRide.actualEndtime, forKey: actualEndtime)
        passengerRideObject.setValue(passengerRide.waypoints, forKey: waypoints)
        passengerRideObject.setValue(passengerRide.routeId, forKey: routeId)
        passengerRideObject.setValue(passengerRide.rideNotes, forKey: rideNotes)
        passengerRideObject.setValue(passengerRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        passengerRideObject.setValue(passengerRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        passengerRideObject.setValue(passengerRide.riderId, forKey: riderId)
        passengerRideObject.setValue(passengerRide.riderName, forKey: riderName)
        passengerRideObject.setValue(passengerRide.points, forKey: points)
        passengerRideObject.setValue(passengerRide.newFare, forKey: newFare)
        passengerRideObject.setValue(passengerRide.pickupAddress, forKey: pickupAddress)
        passengerRideObject.setValue(passengerRide.pickupLatitude, forKey: pickupLatitude)
        passengerRideObject.setValue(passengerRide.pickupLongitude, forKey: pickupLongitude)
        passengerRideObject.setValue(passengerRide.overLappingDistance, forKey: overLappingDistance)
        passengerRideObject.setValue(passengerRide.pickupTime, forKey: pickupTime)
        passengerRideObject.setValue(passengerRide.dropAddress, forKey: dropAddress)
        passengerRideObject.setValue(passengerRide.dropLatitude, forKey: dropLatitude)
        passengerRideObject.setValue(passengerRide.dropLongitude, forKey: dropLongitude)
        passengerRideObject.setValue(passengerRide.dropTime, forKey: dropTime)
        passengerRideObject.setValue(passengerRide.pickupAndDropRoutePolyline, forKey: pickupAndDropRoutePolyline)
        passengerRideObject.setValue(passengerRide.riderRideId, forKey: riderRideId)
        passengerRideObject.setValue(passengerRide.noOfSeats, forKey: noOfSeats)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getPassengerRide(rideid : Double) -> PassengerRide?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: passengerRideTable)
        fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [rideid])
        let passengerRideObject = fetchPassengerRideObject(managedContext: managedContext, fetchRequest: fetchRequest)
       return passengerRideObject
    }
    
    static func getPassengerRideByRiderRideId(riderRideid : Double) -> PassengerRide?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: passengerRideTable)
        fetchRequest.predicate = NSPredicate(format: "\(riderRideId) == %@", argumentArray: [riderRideid])
        let passengerRideObject = fetchPassengerRideObject(managedContext: managedContext, fetchRequest: fetchRequest)
        return passengerRideObject
    }
    
    static func fetchPassengerRideObject(managedContext : NSManagedObjectContext,fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> PassengerRide?{
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        let passengerRideObject = PassengerRide()
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    passengerRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    passengerRideObject.userId = userId
                }
                passengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                passengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    passengerRideObject.startAddress = startAddress
                }
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    passengerRideObject.startLatitude = startLatitude
                }
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    passengerRideObject.startLongitude = startLongitude
                }
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    passengerRideObject.startTime = startTime
                }
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    passengerRideObject.endAddress = endAddress
                }
                passengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                passengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                passengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                passengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    passengerRideObject.status = status
                }
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    passengerRideObject.routePathPolyline = routePathPolyline
                }
                passengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                passengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                passengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                passengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                passengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    passengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    passengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                    passengerRideObject.riderId = riderId
                }
                
                if let riderName = userManagedObject.value(forKey: riderName) as? String{
                    passengerRideObject.riderName = riderName
                }
                
                if let points = userManagedObject.value(forKey: points) as? Double{
                    passengerRideObject.points = points
                }
                
                if let newFare = userManagedObject.value(forKey: newFare) as? Double{
                    passengerRideObject.newFare = newFare
                }
                
                if let pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String{
                    passengerRideObject.pickupAddress = pickupAddress
                }
                
                if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                    passengerRideObject.pickupLatitude = pickupLatitude
                }
                if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                    passengerRideObject.pickupLongitude = pickupLongitude
                }
                if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                    passengerRideObject.pickupTime = pickupTime
                }
                if let dropAddress = userManagedObject.value(forKey: dropAddress) as? String{
                    passengerRideObject.dropAddress = dropAddress
                }
                if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                    passengerRideObject.dropLatitude = dropLatitude
                }
                if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                    passengerRideObject.dropLongitude = dropLongitude
                }
                if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                    passengerRideObject.dropTime = dropTime
                }
                if let pickupAndDropRoutePolyline = userManagedObject.value(forKey: pickupAndDropRoutePolyline) as? String{
                    passengerRideObject.pickupAndDropRoutePolyline = pickupAndDropRoutePolyline
                }
                if let riderRideId = userManagedObject.value(forKey: riderRideId) as? Double{
                    passengerRideObject.riderRideId = riderRideId
                }
                if let noOfSeats = userManagedObject.value(forKey: noOfSeats) as? Int{
                    passengerRideObject.noOfSeats = noOfSeats
                }
            }
        }
      return passengerRideObject
    }
    
    static func getPassengerRides() -> [PassengerRide]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: passengerRideTable)
        var passengerRides  = [PassengerRide]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let passengerRideObject = PassengerRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    passengerRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    passengerRideObject.userId = userId
                }
                passengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                passengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    passengerRideObject.startAddress = startAddress
                }
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    passengerRideObject.startLatitude = startLatitude
                }
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    passengerRideObject.startLongitude = startLongitude
                }
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    passengerRideObject.startTime = startTime
                }
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    passengerRideObject.endAddress = endAddress
                }
                passengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                passengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                passengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                passengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    passengerRideObject.status = status
                }
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    passengerRideObject.routePathPolyline = routePathPolyline
                }
                if let taxiRideId = userManagedObject.value(forKey: taxiRideId) as? Double {
                    passengerRideObject.taxiRideId = taxiRideId
                }
                if let parentId = userManagedObject.value(forKey: parentId) as? Int {
                    passengerRideObject.parentId = parentId
                }
                if let relayLeg = userManagedObject.value(forKey: relayLeg) as? Int {
                    passengerRideObject.relayLeg = relayLeg
                }
                passengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                passengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                passengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                passengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                passengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    passengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    passengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                    passengerRideObject.riderId = riderId
                }
                
                if let riderName = userManagedObject.value(forKey: riderName) as? String{
                    passengerRideObject.riderName = riderName
                }
                
                if let points = userManagedObject.value(forKey: points) as? Double{
                    passengerRideObject.points = points
                }
                
                if let newFare = userManagedObject.value(forKey: newFare) as? Double{
                    passengerRideObject.newFare = newFare
                }
                
                if let pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String{
                    passengerRideObject.pickupAddress = pickupAddress
                }
                
                if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                    passengerRideObject.pickupLatitude = pickupLatitude
                }
                if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                    passengerRideObject.pickupLongitude = pickupLongitude
                }
                if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                    passengerRideObject.pickupTime = pickupTime
                }
                if let dropAddress = userManagedObject.value(forKey: dropAddress) as? String{
                    passengerRideObject.dropAddress = dropAddress
                }
                if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                    passengerRideObject.dropLatitude = dropLatitude
                }
                if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                    passengerRideObject.dropLongitude = dropLongitude
                }
                if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                    passengerRideObject.dropTime = dropTime
                }
                if let pickupAndDropRoutePolyline = userManagedObject.value(forKey: pickupAndDropRoutePolyline) as? String{
                    passengerRideObject.pickupAndDropRoutePolyline = pickupAndDropRoutePolyline
                }
                if let riderRideId = userManagedObject.value(forKey: riderRideId) as? Double{
                    passengerRideObject.riderRideId = riderRideId
                }
                if let noOfSeats = userManagedObject.value(forKey: noOfSeats) as? Int{
                    passengerRideObject.noOfSeats = noOfSeats
                }
                passengerRides.append(passengerRideObject)
            }
        }
      return passengerRides
    }
    
    static func storeRegularRiderRidesInBulk(regularRiderRides : [RegularRiderRide]){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for regularRiderRide in regularRiderRides{
                prepareRegularRiderRideEntityAndStore(regularRiderRide: regularRiderRide, managedContext: managedContext)
            }
        }
    }
    
    static func storeRegularRiderRide(regularRiderRide : RegularRiderRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            prepareRegularRiderRideEntityAndStore(regularRiderRide: regularRiderRide, managedContext: managedContext)
        }
    }
    
    static func prepareRegularRiderRideEntityAndStore(regularRiderRide : RegularRiderRide,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: regularRiderRideTable, in: managedContext)
        let regularRiderRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        regularRiderRideObject.setValue(regularRiderRide.rideId, forKey: rideId)
        regularRiderRideObject.setValue(regularRiderRide.userId, forKey: userId)
        regularRiderRideObject.setValue(regularRiderRide.userName, forKey: userName)
        regularRiderRideObject.setValue(regularRiderRide.rideType, forKey: rideType)
        regularRiderRideObject.setValue(regularRiderRide.startAddress, forKey: startAddress)
        regularRiderRideObject.setValue(regularRiderRide.startLatitude, forKey: startLatitude)
        regularRiderRideObject.setValue(regularRiderRide.startLongitude, forKey: startLongitude)
        regularRiderRideObject.setValue(regularRiderRide.startTime, forKey: startTime)
        regularRiderRideObject.setValue(regularRiderRide.endAddress, forKey: endAddress)
        regularRiderRideObject.setValue(regularRiderRide.endLatitude, forKey: endLatitude)
        regularRiderRideObject.setValue(regularRiderRide.endLongitude, forKey: endLongitude)
        regularRiderRideObject.setValue(regularRiderRide.distance, forKey: distance)
        regularRiderRideObject.setValue(regularRiderRide.expectedEndTime, forKey: expectedEndTime)
        regularRiderRideObject.setValue(regularRiderRide.status, forKey: status)
        regularRiderRideObject.setValue(regularRiderRide.routePathPolyline, forKey: routePathPolyline)
        regularRiderRideObject.setValue(regularRiderRide.actualStartTime, forKey: actualStartTime)
        regularRiderRideObject.setValue(regularRiderRide.actualEndtime, forKey: actualEndtime)
        regularRiderRideObject.setValue(regularRiderRide.waypoints, forKey: waypoints)
        regularRiderRideObject.setValue(regularRiderRide.routeId, forKey: routeId)
        regularRiderRideObject.setValue(regularRiderRide.rideNotes, forKey: rideNotes)
        regularRiderRideObject.setValue(regularRiderRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        regularRiderRideObject.setValue(regularRiderRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        regularRiderRideObject.setValue(regularRiderRide.fromDate, forKey: fromDate)
        regularRiderRideObject.setValue(regularRiderRide.toDate, forKey: toDate)
        regularRiderRideObject.setValue(regularRiderRide.sunday, forKey: sunday)
        regularRiderRideObject.setValue(regularRiderRide.monday, forKey: monday)
        regularRiderRideObject.setValue(regularRiderRide.tuesday, forKey: tuesday)
        regularRiderRideObject.setValue(regularRiderRide.wednesday, forKey: wednesday)
        regularRiderRideObject.setValue(regularRiderRide.thursday, forKey: thursday)
        regularRiderRideObject.setValue(regularRiderRide.friday, forKey: friday)
        regularRiderRideObject.setValue(regularRiderRide.saturday, forKey: saturday)
        regularRiderRideObject.setValue(regularRiderRide.dayType, forKey: dayType)
        
        regularRiderRideObject.setValue(regularRiderRide.vehicleNumber, forKey: vehicleNumber)
        regularRiderRideObject.setValue(regularRiderRide.vehicleType, forKey: vehicleType)
        regularRiderRideObject.setValue(regularRiderRide.vehicleModel, forKey: vehicleModel)
        regularRiderRideObject.setValue(regularRiderRide.farePerKm, forKey: farePerKm)
        regularRiderRideObject.setValue(regularRiderRide.availableSeats, forKey: availableSeats)
        regularRiderRideObject.setValue(regularRiderRide.noOfPassengers, forKey: noOfPassengers)
        regularRiderRideObject.setValue(regularRiderRide.additionalFacilities, forKey: additionalFacilities)
        regularRiderRideObject.setValue(regularRiderRide.riderHasHelmet, forKey: riderHasHelmet)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getRegularRiderRides() -> [RegularRiderRide]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularRiderRideTable)
        var regularRiderRides  = [RegularRiderRide]()
        
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let regularRiderRideObject = RegularRiderRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    regularRiderRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    regularRiderRideObject.userId = userId
                }
                regularRiderRideObject.userName = userManagedObject.value(forKey: userName) as? String
                regularRiderRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    regularRiderRideObject.startAddress = startAddress
                }
                
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    regularRiderRideObject.startLatitude = startLatitude
                }
                
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    regularRiderRideObject.startLongitude = startLongitude
                }
                
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    regularRiderRideObject.startTime = startTime
                }
                
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    regularRiderRideObject.endAddress = endAddress
                }
                regularRiderRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                regularRiderRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                regularRiderRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                regularRiderRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    regularRiderRideObject.status = status
                }
                
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    regularRiderRideObject.routePathPolyline = routePathPolyline
                }
                regularRiderRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                regularRiderRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                regularRiderRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                regularRiderRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                regularRiderRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    regularRiderRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    regularRiderRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
               
                regularRiderRideObject.vehicleNumber = userManagedObject.value(forKey: vehicleNumber) as? String
                regularRiderRideObject.vehicleModel = userManagedObject.value(forKey: vehicleModel) as? String
                regularRiderRideObject.vehicleType = userManagedObject.value(forKey: vehicleType) as? String
                
                if let noOfPassengers = userManagedObject.value(forKey: noOfPassengers) as? Int{
                    regularRiderRideObject.noOfPassengers = noOfPassengers
                }
                if let availableSeats = userManagedObject.value(forKey: availableSeats) as? Int{
                    regularRiderRideObject.availableSeats = availableSeats
                }
                regularRiderRideObject.additionalFacilities = userManagedObject.value(forKey: additionalFacilities) as? String
                
                if let riderHasHelmet = userManagedObject.value(forKey: riderHasHelmet) as? Bool{
                    regularRiderRideObject.riderHasHelmet = riderHasHelmet
                }
                if let farePerKm = userManagedObject.value(forKey: farePerKm) as? Int{
                    regularRiderRideObject.farePerKm = farePerKm
                }
                if let fromDate = userManagedObject.value(forKey: fromDate) as? Double{
                    regularRiderRideObject.fromDate = fromDate
                }
                if let dayType = userManagedObject.value(forKey: dayType) as? String{
                    regularRiderRideObject.dayType = dayType
                }
                regularRiderRideObject.toDate = userManagedObject.value(forKey: toDate) as? Double
                regularRiderRideObject.sunday = userManagedObject.value(forKey: sunday) as? String
                regularRiderRideObject.monday = userManagedObject.value(forKey: monday) as? String
                regularRiderRideObject.tuesday = userManagedObject.value(forKey: tuesday) as? String
                regularRiderRideObject.wednesday = userManagedObject.value(forKey: wednesday) as? String
                regularRiderRideObject.thursday = userManagedObject.value(forKey: thursday) as? String
                regularRiderRideObject.friday = userManagedObject.value(forKey: friday) as? String
                regularRiderRideObject.saturday = userManagedObject.value(forKey: saturday) as? String
                regularRiderRides.append(regularRiderRideObject)
            }
        }
        
        return regularRiderRides
    }
    
    static func fetchRegularRiderRideObject(managedContext : NSManagedObjectContext,fetchRequest : NSFetchRequest<NSFetchRequestResult>) -> RegularRiderRide?{
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        let regularRiderRideObject = RegularRiderRide()
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    regularRiderRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    regularRiderRideObject.userId = userId
                }
                regularRiderRideObject.userName = userManagedObject.value(forKey: userName) as? String
                regularRiderRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    regularRiderRideObject.startAddress = startAddress
                }
                
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    regularRiderRideObject.startLatitude = startLatitude
                }
                
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    regularRiderRideObject.startLongitude = startLongitude
                }
                
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    regularRiderRideObject.startTime = startTime
                }
                
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    regularRiderRideObject.endAddress = endAddress
                }
                regularRiderRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                regularRiderRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                regularRiderRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                regularRiderRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    regularRiderRideObject.status = status
                }
                
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    regularRiderRideObject.routePathPolyline = routePathPolyline
                }
                regularRiderRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                regularRiderRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                regularRiderRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                regularRiderRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                regularRiderRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    regularRiderRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    regularRiderRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                regularRiderRideObject.vehicleNumber = userManagedObject.value(forKey: vehicleNumber) as? String
                regularRiderRideObject.vehicleModel = userManagedObject.value(forKey: vehicleModel) as? String
                regularRiderRideObject.vehicleType = userManagedObject.value(forKey: vehicleType) as? String
                if let noOfPassengers = userManagedObject.value(forKey: noOfPassengers) as? Int{
                    regularRiderRideObject.noOfPassengers = noOfPassengers
                }
                if let availableSeats = userManagedObject.value(forKey: availableSeats) as? Int{
                    regularRiderRideObject.availableSeats = availableSeats
                }
                regularRiderRideObject.additionalFacilities = userManagedObject.value(forKey: additionalFacilities) as? String
                if let riderHasHelmet = userManagedObject.value(forKey: riderHasHelmet) as? Bool{
                    regularRiderRideObject.riderHasHelmet = riderHasHelmet
                }
                if let farePerKm = userManagedObject.value(forKey: farePerKm) as? Int{
                    regularRiderRideObject.farePerKm = farePerKm
                }
                if let fromDate = userManagedObject.value(forKey: fromDate) as? Double{
                    regularRiderRideObject.fromDate = fromDate
                }
                if let dayType = userManagedObject.value(forKey: dayType) as? String{
                    regularRiderRideObject.dayType = dayType
                }
                regularRiderRideObject.toDate = userManagedObject.value(forKey: toDate) as? Double
                regularRiderRideObject.sunday = userManagedObject.value(forKey: sunday) as? String
                regularRiderRideObject.monday = userManagedObject.value(forKey: monday) as? String
                regularRiderRideObject.tuesday = userManagedObject.value(forKey: tuesday) as? String
                regularRiderRideObject.wednesday = userManagedObject.value(forKey: wednesday) as? String
                regularRiderRideObject.thursday = userManagedObject.value(forKey: thursday) as? String
                regularRiderRideObject.friday = userManagedObject.value(forKey: friday) as? String
                regularRiderRideObject.saturday = userManagedObject.value(forKey: saturday) as? String
            }
        }
        return regularRiderRideObject
    }
    
    static func getRegularRiderRide(rideid : Double) -> RegularRiderRide?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularRiderRideTable)
        fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [rideid])
        let regularRiderRideObject = fetchRegularRiderRideObject(managedContext: managedContext, fetchRequest: fetchRequest)
        return regularRiderRideObject
       
    }
    
    
    static func storeRegularPassengerRidesInBulk(regularPassengerRides : [RegularPassengerRide]){
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            for regularPassengerRide in regularPassengerRides{
                prepareRegularPassengerRideEntityAndStore(regularPassengerRide: regularPassengerRide, managedContext: managedContext)
            }
        }
    }
    
    static func storeRegularPassengerRide(regularPassengerRide : RegularPassengerRide){
        
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
                prepareRegularPassengerRideEntityAndStore(regularPassengerRide: regularPassengerRide, managedContext: managedContext)
        
        }
    }
    
    static func prepareRegularPassengerRideEntityAndStore(regularPassengerRide : RegularPassengerRide,managedContext : NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: regularPassengerRideTable, in: managedContext)
        let regularPassengerRideObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        regularPassengerRideObject.setValue(regularPassengerRide.rideId, forKey: rideId)
        regularPassengerRideObject.setValue(regularPassengerRide.userId, forKey: userId)
        regularPassengerRideObject.setValue(regularPassengerRide.userName, forKey: userName)
        regularPassengerRideObject.setValue(regularPassengerRide.rideType, forKey: rideType)
        regularPassengerRideObject.setValue(regularPassengerRide.startAddress, forKey: startAddress)
        regularPassengerRideObject.setValue(regularPassengerRide.startLatitude, forKey: startLatitude)
        regularPassengerRideObject.setValue(regularPassengerRide.startLongitude, forKey: startLongitude)
        regularPassengerRideObject.setValue(regularPassengerRide.startTime, forKey: startTime)
        regularPassengerRideObject.setValue(regularPassengerRide.endAddress, forKey: endAddress)
        regularPassengerRideObject.setValue(regularPassengerRide.endLatitude, forKey: endLatitude)
        regularPassengerRideObject.setValue(regularPassengerRide.endLongitude, forKey: endLongitude)
        regularPassengerRideObject.setValue(regularPassengerRide.distance, forKey: distance)
        regularPassengerRideObject.setValue(regularPassengerRide.expectedEndTime, forKey: expectedEndTime)
        regularPassengerRideObject.setValue(regularPassengerRide.status, forKey: status)
        regularPassengerRideObject.setValue(regularPassengerRide.routePathPolyline, forKey: routePathPolyline)
        regularPassengerRideObject.setValue(regularPassengerRide.actualStartTime, forKey: actualStartTime)
        regularPassengerRideObject.setValue(regularPassengerRide.actualEndtime, forKey: actualEndtime)
        regularPassengerRideObject.setValue(regularPassengerRide.waypoints, forKey: waypoints)
        regularPassengerRideObject.setValue(regularPassengerRide.routeId, forKey: routeId)
        regularPassengerRideObject.setValue(regularPassengerRide.rideNotes, forKey: rideNotes)
        regularPassengerRideObject.setValue(regularPassengerRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
        regularPassengerRideObject.setValue(regularPassengerRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
        regularPassengerRideObject.setValue(regularPassengerRide.fromDate, forKey: fromDate)
        regularPassengerRideObject.setValue(regularPassengerRide.toDate, forKey: toDate)
        regularPassengerRideObject.setValue(regularPassengerRide.sunday, forKey: sunday)
        regularPassengerRideObject.setValue(regularPassengerRide.monday, forKey: monday)
        regularPassengerRideObject.setValue(regularPassengerRide.tuesday, forKey: tuesday)
        regularPassengerRideObject.setValue(regularPassengerRide.wednesday, forKey: wednesday)
        regularPassengerRideObject.setValue(regularPassengerRide.thursday, forKey: thursday)
        regularPassengerRideObject.setValue(regularPassengerRide.friday, forKey: friday)
        regularPassengerRideObject.setValue(regularPassengerRide.saturday, forKey: saturday)
        regularPassengerRideObject.setValue(regularPassengerRide.dayType, forKey: dayType)
        regularPassengerRideObject.setValue(regularPassengerRide.regularRiderRideId, forKey: regularRiderRideId)
        regularPassengerRideObject.setValue(regularPassengerRide.riderId, forKey: riderId)
        regularPassengerRideObject.setValue(regularPassengerRide.riderName, forKey: riderName)
        regularPassengerRideObject.setValue(regularPassengerRide.points, forKey: points)
        regularPassengerRideObject.setValue(regularPassengerRide.pickupAddress, forKey: pickupAddress)
        regularPassengerRideObject.setValue(regularPassengerRide.pickupLatitude, forKey: pickupLatitude)
        regularPassengerRideObject.setValue(regularPassengerRide.pickupLongitude, forKey: pickupLongitude)
        regularPassengerRideObject.setValue(regularPassengerRide.dropAddress, forKey: dropAddress)
        regularPassengerRideObject.setValue(regularPassengerRide.dropLatitude, forKey: dropLatitude)
        regularPassengerRideObject.setValue(regularPassengerRide.dropLongitude, forKey: dropLongitude)
        regularPassengerRideObject.setValue(regularPassengerRide.pickupTime, forKey: pickupTime)
        regularPassengerRideObject.setValue(regularPassengerRide.dropTime, forKey: dropTime)
        CoreDataHelper.saveWorkerContext(workerContext: managedContext)
    }
    
    static func getRegularPassengerRides() -> [RegularPassengerRide]{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularPassengerRideTable)
        var regularPassengerRides  = [RegularPassengerRide]()
       
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                let regularPassengerRideObject = RegularPassengerRide()
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                   regularPassengerRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    regularPassengerRideObject.userId = userId
                }
                
                regularPassengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                regularPassengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    regularPassengerRideObject.startAddress = startAddress
                }
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    regularPassengerRideObject.startLatitude = startLatitude
                }
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    regularPassengerRideObject.startLongitude = startLongitude
                }
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    regularPassengerRideObject.startTime = startTime
                }
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    regularPassengerRideObject.endAddress = endAddress
                }
                regularPassengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                regularPassengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                regularPassengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                regularPassengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    regularPassengerRideObject.status = status
                }
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    regularPassengerRideObject.routePathPolyline = routePathPolyline
                }
                regularPassengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                regularPassengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                regularPassengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                regularPassengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                regularPassengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    regularPassengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    regularPassengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let fromDate = userManagedObject.value(forKey: fromDate) as? Double{
                    regularPassengerRideObject.fromDate = fromDate
                }
                regularPassengerRideObject.toDate = userManagedObject.value(forKey: toDate) as? Double
                regularPassengerRideObject.sunday = userManagedObject.value(forKey: sunday) as? String
                regularPassengerRideObject.monday = userManagedObject.value(forKey: monday) as? String
                regularPassengerRideObject.tuesday = userManagedObject.value(forKey: tuesday) as? String
                regularPassengerRideObject.wednesday = userManagedObject.value(forKey: wednesday) as? String
                regularPassengerRideObject.thursday = userManagedObject.value(forKey: thursday) as? String
                regularPassengerRideObject.friday = userManagedObject.value(forKey: friday) as? String
                regularPassengerRideObject.saturday = userManagedObject.value(forKey: saturday) as? String
                if let dayType = userManagedObject.value(forKey: dayType) as? String{
                    regularPassengerRideObject.dayType = dayType
                }
                if let regularRiderRideId = userManagedObject.value(forKey: regularRiderRideId) as? Double{
                    regularPassengerRideObject.regularRiderRideId = regularRiderRideId
                }
                if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                    regularPassengerRideObject.riderId = riderId
                }
                regularPassengerRideObject.riderName = userManagedObject.value(forKey: riderName) as? String
                if let points = userManagedObject.value(forKey: points) as? Double{
                    regularPassengerRideObject.points = points
                }
                regularPassengerRideObject.pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String
                regularPassengerRideObject.dropAddress = userManagedObject.value(forKey: dropAddress) as? String
                if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                    regularPassengerRideObject.pickupLatitude = pickupLatitude
                }
                if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                    regularPassengerRideObject.pickupLongitude = pickupLongitude
                }
                if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                    regularPassengerRideObject.dropLatitude = dropLatitude
                }
                if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                    regularPassengerRideObject.dropLongitude = dropLongitude
                }
                if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                    regularPassengerRideObject.pickupTime = pickupTime
                }
                if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                    regularPassengerRideObject.dropTime = dropTime
                }
                regularPassengerRides.append(regularPassengerRideObject)
            }
        }
        
        return regularPassengerRides
    }
    
    static func getRegularPassengerRide(rideid : Double) -> RegularPassengerRide{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularPassengerRideTable)
        fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [rideid])
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        let regularPassengerRideObject = RegularPassengerRide()
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    regularPassengerRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    regularPassengerRideObject.userId = userId
                }
                regularPassengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                regularPassengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    regularPassengerRideObject.startAddress = startAddress
                }
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    regularPassengerRideObject.startLatitude = startLatitude
                }
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    regularPassengerRideObject.startLongitude = startLongitude
                }
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    regularPassengerRideObject.startTime = startTime
                }
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    regularPassengerRideObject.endAddress = endAddress
                }
                regularPassengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                regularPassengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                regularPassengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                regularPassengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    regularPassengerRideObject.status = status
                }
                regularPassengerRideObject.routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as! String
                regularPassengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                regularPassengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                regularPassengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                regularPassengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                regularPassengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    regularPassengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    regularPassengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let fromDate = userManagedObject.value(forKey: fromDate) as? Double{
                    regularPassengerRideObject.fromDate = fromDate
                }
                regularPassengerRideObject.toDate = userManagedObject.value(forKey: toDate) as? Double
                regularPassengerRideObject.sunday = userManagedObject.value(forKey: sunday) as? String
                regularPassengerRideObject.monday = userManagedObject.value(forKey: monday) as? String
                regularPassengerRideObject.tuesday = userManagedObject.value(forKey: tuesday) as? String
                regularPassengerRideObject.wednesday = userManagedObject.value(forKey: wednesday) as? String
                regularPassengerRideObject.thursday = userManagedObject.value(forKey: thursday) as? String
                regularPassengerRideObject.friday = userManagedObject.value(forKey: friday) as? String
                regularPassengerRideObject.saturday = userManagedObject.value(forKey: saturday) as? String
                if let dayType = userManagedObject.value(forKey: dayType) as? String{
                    regularPassengerRideObject.dayType = dayType
                }
                if let regularRiderRideId = userManagedObject.value(forKey: regularRiderRideId) as? Double{
                    regularPassengerRideObject.regularRiderRideId = regularRiderRideId
                }
                if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                    regularPassengerRideObject.riderId = riderId
                }
                regularPassengerRideObject.riderName = userManagedObject.value(forKey: riderName) as? String
                if let points = userManagedObject.value(forKey: points) as? Double{
                    regularPassengerRideObject.points = points
                }
                regularPassengerRideObject.pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String
                regularPassengerRideObject.dropAddress = userManagedObject.value(forKey: dropAddress) as? String
                if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                    regularPassengerRideObject.pickupLatitude = pickupLatitude
                }
                if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                    regularPassengerRideObject.pickupLongitude = pickupLongitude
                }
                if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                    regularPassengerRideObject.dropLatitude = dropLatitude
                }
                if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                    regularPassengerRideObject.dropLongitude = dropLongitude
                }
                if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                    regularPassengerRideObject.pickupTime = pickupTime
                }
                if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                    regularPassengerRideObject.dropTime = dropTime
                }
            }
        }
        return regularPassengerRideObject
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
    
    static func deleteRiderRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: riderRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func deletePassengerRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: passengerRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    static func deleteRegularRiderRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularRiderRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func deleteRegularPassengerRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: regularPassengerRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func deleteClosedRiderRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: closedRiderRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    static func deleteClosedPassengerRide(rideid : Double){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            do {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: closedPassengerRideTable)
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@",argumentArray: [rideid])
                
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                let batchResult = try managedContext.execute(deleteRequest)
                AppDelegate.getAppDelegate().log.error("\(batchResult)")
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }catch let error as NSError{
                AppDelegate.getAppDelegate().log.error("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    static func getRiderRide(rideid : Double) -> RiderRide?{
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: riderRideTable)
        fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [rideid])
        let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
        
        let riderRideObject = RiderRide()
        if userManagedObjects != nil{
            for userManagedObject in userManagedObjects!{
                
                if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                    riderRideObject.rideId = rideId
                }
                if let userId = userManagedObject.value(forKey: userId) as? Double{
                    riderRideObject.userId = userId
                }
                riderRideObject.userName = userManagedObject.value(forKey: userName) as? String
                riderRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                    riderRideObject.startAddress = startAddress
                }
                
                if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                    riderRideObject.startLatitude = startLatitude
                }
                
                if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                    riderRideObject.startLongitude = startLongitude
                }
                
                if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                    riderRideObject.startTime = startTime
                }
                
                if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                    riderRideObject.endAddress = endAddress
                }
                riderRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                riderRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                riderRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                riderRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                if let status = userManagedObject.value(forKey: status) as? String{
                    riderRideObject.status = status
                }
                
                if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                    riderRideObject.routePathPolyline = routePathPolyline
                }
                riderRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                riderRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                riderRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                riderRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                riderRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                    riderRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                }
                if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                    riderRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                }
                
                if let vehicleModel = userManagedObject.value(forKey: vehicleModel) as? String{
                    riderRideObject.vehicleModel = vehicleModel
                }
                
                if let vehicleId = userManagedObject.value(forKey: vehicleId) as? Double{
                    riderRideObject.vehicleId = vehicleId
                }
                riderRideObject.vehicleNumber = userManagedObject.value(forKey: vehicleNumber) as? String
                riderRideObject.vehicleType = userManagedObject.value(forKey: vehicleType) as? String
                riderRideObject.vehicleImageURI = userManagedObject.value(forKey: vehicleImageURI) as? String
                if let farePerKm = userManagedObject.value(forKey: farePerKm) as? Double{
                    riderRideObject.farePerKm = farePerKm
                }
                
                if let noOfPassengers = userManagedObject.value(forKey: noOfPassengers) as? Int{
                    riderRideObject.noOfPassengers = noOfPassengers
                }
                if let availableSeats = userManagedObject.value(forKey: availableSeats) as? Int{
                    riderRideObject.availableSeats = availableSeats
                }
                
                if let capacity = userManagedObject.value(forKey: capacity) as? Int{
                    riderRideObject.capacity = capacity
                }
                riderRideObject.riderPathTravelled = userManagedObject.value(forKey: riderPathTravelled) as? String
                if let freezeRide = userManagedObject.value(forKey: freezeRide) as? Bool{
                    riderRideObject.freezeRide = freezeRide
                }
                riderRideObject.makeAndCategory = userManagedObject.value(forKey: makeAndCategory) as? String
                riderRideObject.additionalFacilities = userManagedObject.value(forKey: additionalFacilities) as? String
                if let cumulativeOverlapDistance = userManagedObject.value(forKey: cumulativeOverlapDistance) as? Double{
                    riderRideObject.cumulativeOverlapDistance = cumulativeOverlapDistance
                }
            }
        }
      return riderRideObject
    }
  
    static func updateRiderRide(riderRide : RiderRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:riderRideTable)
            fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [riderRide.rideId])
            if let riderRideObject = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest){
                riderRideObject[0].setValue(riderRide.rideId, forKey: rideId)
                riderRideObject[0].setValue(riderRide.userId, forKey: userId)
                riderRideObject[0].setValue(riderRide.userName, forKey: userName)
                riderRideObject[0].setValue(riderRide.rideType, forKey: rideType)
                riderRideObject[0].setValue(riderRide.startAddress, forKey: startAddress)
                riderRideObject[0].setValue(riderRide.startLatitude, forKey: startLatitude)
                riderRideObject[0].setValue(riderRide.startLongitude, forKey: startLongitude)
                riderRideObject[0].setValue(riderRide.startTime, forKey: startTime)
                riderRideObject[0].setValue(riderRide.endAddress, forKey: endAddress)
                riderRideObject[0].setValue(riderRide.endLatitude, forKey: endLatitude)
                riderRideObject[0].setValue(riderRide.endLongitude, forKey: endLongitude)
                riderRideObject[0].setValue(riderRide.distance, forKey: distance)
                riderRideObject[0].setValue(riderRide.expectedEndTime, forKey: expectedEndTime)
                riderRideObject[0].setValue(riderRide.status, forKey: status)
                riderRideObject[0].setValue(riderRide.routePathPolyline, forKey: routePathPolyline)
                riderRideObject[0].setValue(riderRide.actualStartTime, forKey: actualStartTime)
                riderRideObject[0].setValue(riderRide.actualEndtime, forKey: actualEndtime)
                riderRideObject[0].setValue(riderRide.waypoints, forKey: waypoints)
                riderRideObject[0].setValue(riderRide.routeId, forKey: routeId)
                riderRideObject[0].setValue(riderRide.rideNotes, forKey: rideNotes)
                riderRideObject[0].setValue(riderRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
                riderRideObject[0].setValue(riderRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
                
                riderRideObject[0].setValue(riderRide.vehicleNumber, forKey: vehicleNumber)
                riderRideObject[0].setValue(riderRide.vehicleModel, forKey: vehicleModel)
                riderRideObject[0].setValue(riderRide.farePerKm, forKey: farePerKm)
                riderRideObject[0].setValue(riderRide.noOfPassengers, forKey: noOfPassengers)
                riderRideObject[0].setValue(riderRide.availableSeats, forKey: availableSeats)
                riderRideObject[0].setValue(riderRide.capacity, forKey: capacity)
                riderRideObject[0].setValue(riderRide.riderPathTravelled, forKey: riderPathTravelled)
                riderRideObject[0].setValue(riderRide.makeAndCategory, forKey: makeAndCategory)
                riderRideObject[0].setValue(riderRide.additionalFacilities, forKey: additionalFacilities)
                riderRideObject[0].setValue(riderRide.vehicleType, forKey: vehicleType)
                riderRideObject[0].setValue(riderRide.freezeRide, forKey: freezeRide)
                riderRideObject[0].setValue(riderRide.cumulativeOverlapDistance, forKey: cumulativeOverlapDistance)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
        
    }
    
    static func updatePassengerRide(passengerRide : PassengerRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:passengerRideTable)
            fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [passengerRide.rideId])
            if let passengerRideObject = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest){
                passengerRideObject[0].setValue(passengerRide.rideId, forKey: rideId)
                passengerRideObject[0].setValue(passengerRide.userId, forKey: userId)
                passengerRideObject[0].setValue(passengerRide.userName, forKey: userName)
                passengerRideObject[0].setValue(passengerRide.rideType, forKey: rideType)
                passengerRideObject[0].setValue(passengerRide.startAddress, forKey: startAddress)
                passengerRideObject[0].setValue(passengerRide.startLatitude, forKey: startLatitude)
                passengerRideObject[0].setValue(passengerRide.startLongitude, forKey: startLongitude)
                passengerRideObject[0].setValue(passengerRide.startTime, forKey: startTime)
                passengerRideObject[0].setValue(passengerRide.endAddress, forKey: endAddress)
                passengerRideObject[0].setValue(passengerRide.endLatitude, forKey: endLatitude)
                passengerRideObject[0].setValue(passengerRide.endLongitude, forKey: endLongitude)
                passengerRideObject[0].setValue(passengerRide.distance, forKey: distance)
                passengerRideObject[0].setValue(passengerRide.expectedEndTime, forKey: expectedEndTime)
                passengerRideObject[0].setValue(passengerRide.status, forKey: status)
                passengerRideObject[0].setValue(passengerRide.routePathPolyline, forKey: routePathPolyline)
                passengerRideObject[0].setValue(passengerRide.actualStartTime, forKey: actualStartTime)
                passengerRideObject[0].setValue(passengerRide.actualEndtime, forKey: actualEndtime)
                passengerRideObject[0].setValue(passengerRide.waypoints, forKey: waypoints)
                passengerRideObject[0].setValue(passengerRide.routeId, forKey: routeId)
                passengerRideObject[0].setValue(passengerRide.rideNotes, forKey: rideNotes)
                passengerRideObject[0].setValue(passengerRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
                passengerRideObject[0].setValue(passengerRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
                passengerRideObject[0].setValue(passengerRide.riderId, forKey: riderId)
                passengerRideObject[0].setValue(passengerRide.riderName, forKey: riderName)
                passengerRideObject[0].setValue(passengerRide.points, forKey: points)
                passengerRideObject[0].setValue(passengerRide.newFare, forKey: newFare)
                passengerRideObject[0].setValue(passengerRide.pickupAddress, forKey: pickupAddress)
                passengerRideObject[0].setValue(passengerRide.pickupLatitude, forKey: pickupLatitude)
                passengerRideObject[0].setValue(passengerRide.pickupLongitude, forKey: pickupLongitude)
                passengerRideObject[0].setValue(passengerRide.overLappingDistance, forKey: overLappingDistance)
                passengerRideObject[0].setValue(passengerRide.pickupTime, forKey: pickupTime)
                passengerRideObject[0].setValue(passengerRide.dropAddress, forKey: dropAddress)
                passengerRideObject[0].setValue(passengerRide.dropLatitude, forKey: dropLatitude)
                passengerRideObject[0].setValue(passengerRide.dropLongitude, forKey: dropLongitude)
                passengerRideObject[0].setValue(passengerRide.dropTime, forKey: dropTime)
                passengerRideObject[0].setValue(passengerRide.pickupAndDropRoutePolyline, forKey: pickupAndDropRoutePolyline)
                passengerRideObject[0].setValue(passengerRide.riderRideId, forKey: riderRideId)
                passengerRideObject[0].setValue(passengerRide.noOfSeats, forKey: noOfSeats)
                passengerRideObject[0].setValue(passengerRide.taxiRideId, forKey: taxiRideId)
                passengerRideObject[0].setValue(passengerRide.parentId, forKey: parentId)
                passengerRideObject[0].setValue(passengerRide.relayLeg, forKey: relayLeg)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
     }
    
    
    static func getRegularPassengerRideByRegularRiderRideId(regularRiderRideid : Double?,rideid : Double?) -> RegularPassengerRide?{
       let managedContext = CoreDataHelper.getNSMangedObjectContext()
        let regularPassengerRideObject = RegularPassengerRide()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:regularRiderRideTable)
            if regularRiderRideid != nil{
                fetchRequest.predicate = NSPredicate(format: "\(regularRiderRideId) == %@", argumentArray: [regularRiderRideid!])
            }else{
                fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [rideid!])
            }
            let userManagedObjects = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest)
            if userManagedObjects != nil{
                for userManagedObject in userManagedObjects!{
                    
                    if let rideId = userManagedObject.value(forKey: rideId) as? Double{
                        regularPassengerRideObject.rideId = rideId
                    }
                    if let userId = userManagedObject.value(forKey: userId) as? Double{
                        regularPassengerRideObject.userId = userId
                    }
                    regularPassengerRideObject.userName = userManagedObject.value(forKey: userName) as? String
                    regularPassengerRideObject.rideType = userManagedObject.value(forKey: rideType) as? String
                    if let startAddress = userManagedObject.value(forKey: startAddress) as? String{
                        regularPassengerRideObject.startAddress = startAddress
                    }
                    if let startLatitude = userManagedObject.value(forKey: startLatitude) as? Double{
                        regularPassengerRideObject.startLatitude = startLatitude
                    }
                    if let startLongitude = userManagedObject.value(forKey: startLongitude) as? Double{
                        regularPassengerRideObject.startLongitude = startLongitude
                    }
                    if let startTime = userManagedObject.value(forKey: startTime) as? Double{
                        regularPassengerRideObject.startTime = startTime
                    }
                    if let endAddress = userManagedObject.value(forKey: endAddress) as? String{
                        regularPassengerRideObject.endAddress = endAddress
                    }
                    regularPassengerRideObject.endLatitude = userManagedObject.value(forKey: endLatitude) as? Double
                    regularPassengerRideObject.endLongitude = userManagedObject.value(forKey: endLongitude) as? Double
                    regularPassengerRideObject.distance = userManagedObject.value(forKey: distance) as? Double
                    regularPassengerRideObject.expectedEndTime = userManagedObject.value(forKey: expectedEndTime) as? Double
                    if let status = userManagedObject.value(forKey: status) as? String{
                        regularPassengerRideObject.status = status
                    }
                    if let routePathPolyline = userManagedObject.value(forKey: routePathPolyline) as? String{
                        regularPassengerRideObject.routePathPolyline = routePathPolyline
                    }
                    regularPassengerRideObject.actualStartTime = userManagedObject.value(forKey: actualStartTime) as? Double
                    regularPassengerRideObject.actualEndtime = userManagedObject.value(forKey: actualEndtime) as? Double
                    regularPassengerRideObject.waypoints = userManagedObject.value(forKey: waypoints) as? String
                    regularPassengerRideObject.routeId = userManagedObject.value(forKey: routeId) as? Double
                    regularPassengerRideObject.rideNotes = userManagedObject.value(forKey: rideNotes) as? String
                    if let allowRideMatchToJoinedGroups = userManagedObject.value(forKey: allowRideMatchToJoinedGroups) as? Bool{
                        regularPassengerRideObject.allowRideMatchToJoinedGroups = allowRideMatchToJoinedGroups
                    }
                    if let showMeToJoinedGroups = userManagedObject.value(forKey: showMeToJoinedGroups) as? Bool{
                        regularPassengerRideObject.showMeToJoinedGroups = showMeToJoinedGroups
                    }
                    
                    if let fromDate = userManagedObject.value(forKey: fromDate) as? Double{
                        regularPassengerRideObject.fromDate = fromDate
                    }
                    regularPassengerRideObject.toDate = userManagedObject.value(forKey: toDate) as? Double
                    regularPassengerRideObject.sunday = userManagedObject.value(forKey: sunday) as? String
                    regularPassengerRideObject.monday = userManagedObject.value(forKey: monday) as? String
                    regularPassengerRideObject.tuesday = userManagedObject.value(forKey: tuesday) as? String
                    regularPassengerRideObject.wednesday = userManagedObject.value(forKey: wednesday) as? String
                    regularPassengerRideObject.thursday = userManagedObject.value(forKey: thursday) as? String
                    regularPassengerRideObject.friday = userManagedObject.value(forKey: friday) as? String
                    regularPassengerRideObject.saturday = userManagedObject.value(forKey: saturday) as? String
                    if let dayType = userManagedObject.value(forKey: dayType) as? String{
                        regularPassengerRideObject.dayType = dayType
                    }
                    if let regularRiderRideId = userManagedObject.value(forKey: regularRiderRideId) as? Double{
                        regularPassengerRideObject.regularRiderRideId = regularRiderRideId
                    }
                    if let riderId = userManagedObject.value(forKey: riderId) as? Double{
                        regularPassengerRideObject.riderId = riderId
                    }
                    regularPassengerRideObject.riderName = userManagedObject.value(forKey: riderName) as? String
                    if let points = userManagedObject.value(forKey: points) as? Double{
                        regularPassengerRideObject.points = points
                    }
                    regularPassengerRideObject.pickupAddress = userManagedObject.value(forKey: pickupAddress) as? String
                    regularPassengerRideObject.dropAddress = userManagedObject.value(forKey: dropAddress) as? String
                    if let pickupLatitude = userManagedObject.value(forKey: pickupLatitude) as? Double{
                        regularPassengerRideObject.pickupLatitude = pickupLatitude
                    }
                    if let pickupLongitude = userManagedObject.value(forKey: pickupLongitude) as? Double{
                        regularPassengerRideObject.pickupLongitude = pickupLongitude
                    }
                    if let dropLatitude = userManagedObject.value(forKey: dropLatitude) as? Double{
                        regularPassengerRideObject.dropLatitude = dropLatitude
                    }
                    if let dropLongitude = userManagedObject.value(forKey: dropLongitude) as? Double{
                        regularPassengerRideObject.dropLongitude = dropLongitude
                    }
                    if let pickupTime = userManagedObject.value(forKey: pickupTime) as? Double{
                        regularPassengerRideObject.pickupTime = pickupTime
                    }
                    if let dropTime = userManagedObject.value(forKey: dropTime) as? Double{
                        regularPassengerRideObject.dropTime = dropTime
                    }
                }
            }
        }
      return regularPassengerRideObject
    }
        
    
    static func updateRegularRiderRide(regularRiderRide : RegularRiderRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:regularRiderRideTable)
            fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [regularRiderRide.rideId])
            if let regularRiderRideObject = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest){
                regularRiderRideObject[0].setValue(regularRiderRide.rideId, forKey: rideId)
                regularRiderRideObject[0].setValue(regularRiderRide.userId, forKey: userId)
                regularRiderRideObject[0].setValue(regularRiderRide.userName, forKey: userName)
                regularRiderRideObject[0].setValue(regularRiderRide.rideType, forKey: rideType)
                regularRiderRideObject[0].setValue(regularRiderRide.startAddress, forKey: startAddress)
                regularRiderRideObject[0].setValue(regularRiderRide.startLatitude, forKey: startLatitude)
                regularRiderRideObject[0].setValue(regularRiderRide.startLongitude, forKey: startLongitude)
                regularRiderRideObject[0].setValue(regularRiderRide.startTime, forKey: startTime)
                regularRiderRideObject[0].setValue(regularRiderRide.endAddress, forKey: endAddress)
                regularRiderRideObject[0].setValue(regularRiderRide.endLatitude, forKey: endLatitude)
                regularRiderRideObject[0].setValue(regularRiderRide.endLongitude, forKey: endLongitude)
                regularRiderRideObject[0].setValue(regularRiderRide.distance, forKey: distance)
                regularRiderRideObject[0].setValue(regularRiderRide.expectedEndTime, forKey: expectedEndTime)
                regularRiderRideObject[0].setValue(regularRiderRide.status, forKey: status)
                regularRiderRideObject[0].setValue(regularRiderRide.routePathPolyline, forKey: routePathPolyline)
                regularRiderRideObject[0].setValue(regularRiderRide.actualStartTime, forKey: actualStartTime)
                regularRiderRideObject[0].setValue(regularRiderRide.actualEndtime, forKey: actualEndtime)
                regularRiderRideObject[0].setValue(regularRiderRide.waypoints, forKey: waypoints)
                regularRiderRideObject[0].setValue(regularRiderRide.routeId, forKey: routeId)
                regularRiderRideObject[0].setValue(regularRiderRide.rideNotes, forKey: rideNotes)
                regularRiderRideObject[0].setValue(regularRiderRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
                regularRiderRideObject[0].setValue(regularRiderRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
                regularRiderRideObject[0].setValue(regularRiderRide.fromDate, forKey: fromDate)
                regularRiderRideObject[0].setValue(regularRiderRide.toDate, forKey: toDate)
                regularRiderRideObject[0].setValue(regularRiderRide.sunday, forKey: sunday)
                regularRiderRideObject[0].setValue(regularRiderRide.monday, forKey: monday)
                regularRiderRideObject[0].setValue(regularRiderRide.tuesday, forKey: tuesday)
                regularRiderRideObject[0].setValue(regularRiderRide.wednesday, forKey: wednesday)
                regularRiderRideObject[0].setValue(regularRiderRide.thursday, forKey: thursday)
                regularRiderRideObject[0].setValue(regularRiderRide.friday, forKey: friday)
                regularRiderRideObject[0].setValue(regularRiderRide.saturday, forKey: saturday)
                regularRiderRideObject[0].setValue(regularRiderRide.dayType, forKey: dayType)
                
                regularRiderRideObject[0].setValue(regularRiderRide.vehicleNumber, forKey: vehicleNumber)
                regularRiderRideObject[0].setValue(regularRiderRide.vehicleType, forKey: vehicleType)
                regularRiderRideObject[0].setValue(regularRiderRide.vehicleModel, forKey: vehicleModel)
                regularRiderRideObject[0].setValue(regularRiderRide.farePerKm, forKey: farePerKm)
                regularRiderRideObject[0].setValue(regularRiderRide.availableSeats, forKey: availableSeats)
                regularRiderRideObject[0].setValue(regularRiderRide.noOfPassengers, forKey: noOfPassengers)
                regularRiderRideObject[0].setValue(regularRiderRide.additionalFacilities, forKey: additionalFacilities)
                regularRiderRideObject[0].setValue(regularRiderRide.riderHasHelmet, forKey: riderHasHelmet)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
    }
    
    
    static func updateRegularPassengerRide(regularPassengerRide : RegularPassengerRide){
        let managedContext = CoreDataHelper.getNSMangedObjectContext()
        managedContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:regularPassengerRideTable)
            fetchRequest.predicate = NSPredicate(format: "\(rideId) == %@", argumentArray: [regularPassengerRide.rideId])
            if let regularPassengerRideObject = executeFetchResultAll(managedContext: managedContext, fetchRequest: fetchRequest){
                regularPassengerRideObject[0].setValue(regularPassengerRide.rideId, forKey: rideId)
                regularPassengerRideObject[0].setValue(regularPassengerRide.userId, forKey: userId)
                regularPassengerRideObject[0].setValue(regularPassengerRide.userName, forKey: userName)
                regularPassengerRideObject[0].setValue(regularPassengerRide.rideType, forKey: rideType)
                regularPassengerRideObject[0].setValue(regularPassengerRide.startAddress, forKey: startAddress)
                regularPassengerRideObject[0].setValue(regularPassengerRide.startLatitude, forKey: startLatitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.startLongitude, forKey: startLongitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.startTime, forKey: startTime)
                regularPassengerRideObject[0].setValue(regularPassengerRide.endAddress, forKey: endAddress)
                regularPassengerRideObject[0].setValue(regularPassengerRide.endLatitude, forKey: endLatitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.endLongitude, forKey: endLongitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.distance, forKey: distance)
                regularPassengerRideObject[0].setValue(regularPassengerRide.expectedEndTime, forKey: expectedEndTime)
                regularPassengerRideObject[0].setValue(regularPassengerRide.status, forKey: status)
                regularPassengerRideObject[0].setValue(regularPassengerRide.routePathPolyline, forKey: routePathPolyline)
                regularPassengerRideObject[0].setValue(regularPassengerRide.actualStartTime, forKey: actualStartTime)
                regularPassengerRideObject[0].setValue(regularPassengerRide.actualEndtime, forKey: actualEndtime)
                regularPassengerRideObject[0].setValue(regularPassengerRide.waypoints, forKey: waypoints)
                regularPassengerRideObject[0].setValue(regularPassengerRide.routeId, forKey: routeId)
                regularPassengerRideObject[0].setValue(regularPassengerRide.rideNotes, forKey: rideNotes)
                regularPassengerRideObject[0].setValue(regularPassengerRide.allowRideMatchToJoinedGroups, forKey: allowRideMatchToJoinedGroups)
                regularPassengerRideObject[0].setValue(regularPassengerRide.showMeToJoinedGroups, forKey: showMeToJoinedGroups)
                regularPassengerRideObject[0].setValue(regularPassengerRide.fromDate, forKey: fromDate)
                regularPassengerRideObject[0].setValue(regularPassengerRide.toDate, forKey: toDate)
                regularPassengerRideObject[0].setValue(regularPassengerRide.sunday, forKey: sunday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.monday, forKey: monday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.tuesday, forKey: tuesday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.wednesday, forKey: wednesday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.thursday, forKey: thursday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.friday, forKey: friday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.saturday, forKey: saturday)
                regularPassengerRideObject[0].setValue(regularPassengerRide.dayType, forKey: dayType)
                regularPassengerRideObject[0].setValue(regularPassengerRide.regularRiderRideId, forKey: regularRiderRideId)
                regularPassengerRideObject[0].setValue(regularPassengerRide.riderId, forKey: riderId)
                regularPassengerRideObject[0].setValue(regularPassengerRide.riderName, forKey: riderName)
                regularPassengerRideObject[0].setValue(regularPassengerRide.points, forKey: points)
                regularPassengerRideObject[0].setValue(regularPassengerRide.pickupAddress, forKey: pickupAddress)
                regularPassengerRideObject[0].setValue(regularPassengerRide.pickupLatitude, forKey: pickupLatitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.pickupLongitude, forKey: pickupLongitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.dropAddress, forKey: dropAddress)
                regularPassengerRideObject[0].setValue(regularPassengerRide.dropLatitude, forKey: dropLatitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.dropLongitude, forKey: dropLongitude)
                regularPassengerRideObject[0].setValue(regularPassengerRide.pickupTime, forKey: pickupTime)
                regularPassengerRideObject[0].setValue(regularPassengerRide.dropTime, forKey: dropTime)
                CoreDataHelper.saveWorkerContext(workerContext: managedContext)
            }
        }
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
    

}
