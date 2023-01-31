//
//  TravelledRouteSavingViewController.swift
//  Quickride
//
//  Created by Vinutha on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class TravelledRouteSavingViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var setAsDefaultRouteButton: UIButton!
    
    //MARK: Properties
    private var travelledRouteSavingViewModel = TravelledRouteSavingViewModel()
    private weak var iboMapView: GMSMapView!
    private var handler: clickActionCompletionHandler?
    var routeDistanceMarker: GMSMarker?
    
    //MARK: Initialiser
    func initialiseData(riderRide: RiderRide, newRoute: RideRoute, handler: clickActionCompletionHandler) {
        travelledRouteSavingViewModel.initialiseData(riderRide: riderRide, newRoute: newRoute)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: Methods
    private func setUpUI() {
        setAsDefaultRouteButton.addShadow()
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        iboMapView.padding = UIEdgeInsets(top: 10, left: 10, bottom: 70, right: 10)
        drawRoute()
    }
    
    private func drawRoute() {
        if let riderRide = travelledRouteSavingViewModel.riderRide {
            let start = CLLocationCoordinate2D(latitude: riderRide.startLatitude, longitude: riderRide.startLongitude)
            let end = CLLocationCoordinate2D(latitude: (riderRide.endLatitude)!, longitude: (riderRide.endLongitude)!)
            GoogleMapUtils.drawCurrentUserRoutePathOnMapWithStartAndStop(start: start,end : end,route: riderRide.routePathPolyline, map: iboMapView, colorCode: UIColor(netHex: 0x252525), width: GoogleMapUtils.POLYLINE_WIDTH_10, zIndex: GoogleMapUtils.Z_INDEX_7)
        }
        GoogleMapUtils.drawRoute(pathString: travelledRouteSavingViewModel.newRoute!.overviewPolyline!, map: iboMapView, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_7, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        if let viaPoints = travelledRouteSavingViewModel.extractViaPoints(wayPoints: travelledRouteSavingViewModel.newRoute?.waypoints ?? ""), let latLngs = LocationClientUtils.decodePolylineAndReturnLatlng(travelledRouteSavingViewModel.newRoute?.overviewPolyline ?? "") {
            if viaPoints.count < 5 {
                let position = latLngs[latLngs.count / 2]
                let editMarkerView = UIView.loadFromNibNamed(nibNamed: "EditMarkerView") as! EditMarkerView
                editMarkerView.initializeView(title: Strings.edit_route, imageName: "edit_route_signup")
                editMarkerView.addShadow()
                let icon = ViewCustomizationUtils.getImageFromView(view: editMarkerView)
                routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: position, shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
            }
        }
        GoogleMapUtils.fitToScreen(route: travelledRouteSavingViewModel.newRoute!.overviewPolyline!, map: iboMapView)
    }
    
    //MARK: Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func setAsDefaultRouteTapped(_ sender: UIButton) {
        if let riderRide = travelledRouteSavingViewModel.riderRide, let newRoute = travelledRouteSavingViewModel.newRoute {
            let saveRouteUtilsInstance = SaveRouteViewUtils()
            if let preferredRoute = UserDataCache.getInstance()?.getUserPreferredRoute(startLatitude: riderRide.startLatitude, startLongitude: riderRide.startLongitude, endLatitude: riderRide.endLatitude ?? 0, endLongitude: riderRide.endLongitude ?? 0) {
                
                MessageDisplay.displayAlertWithAction(title: nil, isDismissViewRequired: false, message1: Strings.do_you_want_update_preferred_route, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, msgWithLinkText: nil, isActionButtonRequired: true, viewController: self) { (action) in
                    if Strings.yes_caps == action {
                        QuickRideProgressSpinner.startSpinner()
                        saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: riderRide.rideType)).CustomRoute.TravelledRouteSavingView", ride: riderRide, preferredRoute: preferredRoute, viaPointString: newRoute.waypoints, routeName: nil) { (route, preferredRoute, responseError, error) in
                            QuickRideProgressSpinner.stopSpinner()
                            if route != nil{
                                UIApplication.shared.keyWindow?.makeToast("Route Updated")
                                self.navigationController?.popViewController(animated: false)
                                self.handler?(Strings.success)
                            }else{
                                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                            }
                        }
                    } else {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
                
            }else{
                let saveCustomizedRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SaveCustomizedRouteViewController") as! SaveCustomizedRouteViewController
                let suggestedRouteName = saveRouteUtilsInstance.getSuggestingNameForRoute(ride: riderRide, wayPoints: nil)
                saveCustomizedRouteViewController.initializeDataBeforePresenting(suggestedRouteName: suggestedRouteName, handler: { [unowned self] (routeName) in
                    QuickRideProgressSpinner.startSpinner()
                    saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: riderRide.rideType)).CustomRoute.TravelledRouteSavingView", ride: riderRide, preferredRoute: nil, viaPointString: newRoute.waypoints, routeName: routeName){ (route, preferredRoute, responseError, error) in
                        QuickRideProgressSpinner.stopSpinner()
                        if route != nil {
                            if preferredRoute != nil {
                                UIApplication.shared.keyWindow?.makeToast("Route Updated")
                                self.navigationController?.popViewController(animated: false)
                                self.handler?(Strings.success)
                            } else {
                                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                            }
                        } else {
                            self.handler?(Strings.failed)
                        }
                    }
                })
                self.navigationController?.view.addSubview(saveCustomizedRouteViewController.view)
                self.navigationController?.addChild(saveCustomizedRouteViewController)
                
            }
        }
    }
    
}
extension TravelledRouteSavingViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        AppDelegate.getAppDelegate().log.debug("changeRouteClicked")
        let selectRouteFromMapViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RouteSelectionViewController") as! RouteSelectionViewController
        selectRouteFromMapViewController.initializeDataBeforePresenting(ride: travelledRouteSavingViewModel.riderRide!, rideRoute: travelledRouteSavingViewModel.newRoute!, routeSelectionDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: selectRouteFromMapViewController, animated: false)
        return nil
    }
}
extension TravelledRouteSavingViewController: RouteSelectionDelegate {
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        UIApplication.shared.keyWindow?.makeToast("Route Updated")
        self.navigationController?.popViewController(animated: false)
        self.handler?(Strings.success)
    }
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
       UIApplication.shared.keyWindow?.makeToast( "Route Updated")
        self.navigationController?.popViewController(animated: false)
        self.handler?(Strings.success)
    }
    
    
}
