

//
//  RouteAsyncTask.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 18/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


typealias routeCompletionHandler = (_ rideRoute : [RideRoute]?, _ responseObject : NSDictionary?,_ error :  NSError?)->Void

class RouteAsyncTask{
  
    var startLat,startLng,endLat,endLng:Double
    var wayPoints:String?
    var routePaths:[RideRoute] = [RideRoute]()
    var alternatives:Bool = false;
    var delegate:routeCompletionHandler?
    var viewController : UIViewController?
    var useCase : String
    var rideId : Double = 0
    var weightedRoutes: Bool?
    
  
  
    init(rideId : Double , useCase : String, startLat : Double, startLng : Double, endLat :Double, endLng:Double, wayPoints:String?, alternatives:Bool,weightedRoutes: Bool, viewController: UIViewController?, routeReceive:@escaping routeCompletionHandler){
    self.startLat = startLat
    self.startLng = startLng
    self.endLat = endLat
    self.endLng = endLng
    self.wayPoints = wayPoints
    self.alternatives = alternatives
    self.delegate = routeReceive
    self.viewController = viewController
        self.useCase = useCase
        self.rideId = rideId
        self.weightedRoutes = weightedRoutes
    }


    func getRoutes(){
        AppDelegate.getAppDelegate().log.debug("getRoutes()")

        if(alternatives == true){
            RoutePathServiceClient.getAllAvailableRoutes(rideId: rideId,useCase : useCase, startLatitude: startLat, startLongitude: startLng, endLatitude: endLat, endLongitude: endLng, wayPoints: wayPoints, weightedRoutes: weightedRoutes ?? false, viewcontroller: viewController, completionhandler: { (responseObject, error) -> Void in

                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    var routePathData  = Mapper<RideRoute>().mapArray(JSONObject: responseObject!["resultData"])! as [RideRoute]
                    var defaultRoutePosition : Int?

                    for i in 0...routePathData.count-1{
                        if routePathData[i].routeType == "Main" || routePathData[i].routeType == "Default"{
                            defaultRoutePosition = i
                        }
                    }
                    if defaultRoutePosition != nil{
                        let defaultRoute = routePathData[defaultRoutePosition!]
                        routePathData.remove(at: defaultRoutePosition!)
                        routePathData.insert(defaultRoute, at: 0)
                    }
                    self.delegate!(routePathData, nil, nil)

                }else{
                    self.delegate!(nil, responseObject, error)

                }
            })
        }else{


            RoutePathServiceClient.getMostFavourableRoute(rideId: rideId,useCase : useCase,startLatitude: startLat, startLongitude: startLng, endLatitude: endLat, endLongitude: endLng, wayPoints: wayPoints, viewController: viewController, completionHandler: { (responseObject, error) -> Void in
          if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            
            var routePathData : [RideRoute] = [RideRoute]()
            let route :RideRoute = Mapper<RideRoute>().map(JSONObject: responseObject!["resultData"])! as RideRoute
            route.waypoints = self.wayPoints
            routePathData.append(route)
            
            self.delegate!(routePathData,nil,nil)
            
          }
          else{
            self.delegate?(nil,responseObject, error)
          }
        })
      }
    }
  }
