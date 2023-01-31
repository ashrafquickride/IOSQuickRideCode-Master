//
//  RecurringRideRouteTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 28/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Foundation
import GoogleMaps

class RecurringRideRouteTableViewCell: UITableViewCell{

    //MARK: Outlets
    @IBOutlet weak var fromLocation: UILabel!
    @IBOutlet weak var toLocation: UILabel!
    @IBOutlet weak var recurringRideDaysLabel: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var resumeAndPauseSwitch: UISwitch!
    @IBOutlet weak var mapContainerView: UIView!
    
    //MARK: Variables
    weak var viewMap: GMSMapView!
    private var ride: Ride?
    private var rideRoute: RideRoute?
    private var viewController: UIViewController?
    private var routeSelectionDelegate: RouteSelectionDelegate?
    
    func initalizeRoute(ride: Ride?, rideRoute: RideRoute?,viewController: UIViewController, routeSelectionDelegate: RouteSelectionDelegate){
        self.ride = ride
        self.rideRoute = rideRoute
        self.viewController = viewController
        self.routeSelectionDelegate = routeSelectionDelegate
        if ride?.status == Ride.RIDE_STATUS_SUSPENDED {
            resumeAndPauseSwitch.setOn(false, animated: false)
        } else {
            resumeAndPauseSwitch.setOn(true, animated: false)
        }
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapContainerView)
        viewMap.delegate = self
        self.viewMap.animate(toZoom: 16)
        drawRouteOnMap()
        getCurrentRecurringRideDays()
        initializeRideStartTimeAndAdrress()
        resumeAndPauseSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    private func drawRouteOnMap(){
        GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude:ride!.startLatitude,longitude : ride!.startLongitude), shortIcon: UIImage(named: "green")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5)).zIndex = 12
        GoogleMapUtils.addMarker(googleMap: viewMap, location: CLLocationCoordinate2D(latitude:ride!.endLatitude!,longitude : ride!.endLongitude!), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5)).zIndex = 12
        GoogleMapUtils.drawRoute(pathString: rideRoute!.overviewPolyline!, map: viewMap, colorCode: UIColor.darkGray, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        GoogleMapUtils.fitToScreen(route: rideRoute!.overviewPolyline!, map: viewMap)
        displayTimeAndDistanceInfoView()
    }
    
    func displayTimeAndDistanceInfoView(){
        let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "RouteTimeAndChangeRouteInfoView") as! RouteTimeAndChangeRouteInfoView
        routeTimeAndChangeRouteInfoView.initializeView(distance: rideRoute?.distance ?? 0, duration: rideRoute?.duration)
        routeTimeAndChangeRouteInfoView.addShadow()
        let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView)
        let path = GMSPath(fromEncodedPath: rideRoute?.overviewPolyline ?? "")
        if path != nil && path!.count() != 0{
             GoogleMapUtils.addMarker(googleMap: viewMap, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
        }
    }
    
    private func initializeRideStartTimeAndAdrress(){
        AppDelegate.getAppDelegate().log.debug("initializeStartTime()")
        startTimeLbl.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: ride?.startTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        fromLocation.text = ride?.startAddress
        toLocation.text = ride?.endAddress
    }
    private func getCurrentRecurringRideDays(){
        let regularRide = ride as? RegularRide
        var daysString = ""
        if regularRide?.monday != nil{
           daysString = Strings.mon_short
        }
        if regularRide?.tuesday != nil{
            if daysString.isEmpty{
                daysString += Strings.tue_short
            }else{
                daysString += ", "+Strings.tue_short
            }
        }
        if regularRide?.wednesday != nil{
            if daysString.isEmpty{
                daysString += Strings.wed_short
            }else{
                daysString += ", "+Strings.wed_short
            }
        }
        if regularRide?.thursday != nil{
            if daysString.isEmpty{
                daysString += Strings.thu_short
            }else{
                daysString += ", "+Strings.thu_short
            }
        }
        if regularRide?.friday != nil{
            if daysString.isEmpty{
                daysString += Strings.fri_short
            }else{
                daysString += ", "+Strings.fri_short
            }
        }
        if regularRide?.saturday != nil{
            if daysString.isEmpty{
                daysString += Strings.sat_short
            }else{
                daysString += ", "+Strings.sat_short
            }
        }
        if regularRide?.sunday != nil{
            if daysString.isEmpty{
                daysString += Strings.sun_short
            }else{
                daysString += ", "+Strings.sun_short
            }
        }
        recurringRideDaysLabel.text = daysString
    }
    
    @IBAction func resumeAndPauseRideSwitch(_ sender: UISwitch) {
        var userInfo = [String : Any]()
        if sender.isOn{
            if self.ride!.rideType == Ride.REGULAR_PASSENGER_RIDE{
                userInfo["status"] = Ride.RIDE_STATUS_REQUESTED
            }else if self.ride!.rideType == Ride.REGULAR_RIDER_RIDE{
                userInfo["status"] = Ride.RIDE_STATUS_SCHEDULED
            }
        }else{
            userInfo["status"] = Ride.RIDE_STATUS_SUSPENDED
        }
        NotificationCenter.default.post(name: .rideStatusChanged, object: nil,userInfo: userInfo)
    }
    
    @IBAction func editDaysAndTimeTapped(_ sender: UIButton){
        NotificationCenter.default.post(name: .editDaysAndTime, object: nil)
    }
    
}
//MARK: GMSMapViewDelegate
extension RecurringRideRouteTableViewCell: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        AppDelegate.getAppDelegate().log.debug("changeRouteClicked")
        guard let route = rideRoute, let rideObj = ride else { return  nil}
        let routeSelectionViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        routeSelectionViewController.initializeDataBeforePresenting(ride: rideObj, rideRoute:  route, routeSelectionDelegate: routeSelectionDelegate!)
        viewController?.navigationController?.pushViewController(routeSelectionViewController, animated: false)
        return nil
    }
}
