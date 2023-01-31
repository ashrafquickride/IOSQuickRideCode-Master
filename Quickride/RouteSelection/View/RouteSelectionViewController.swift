//
//  RouteSelectionViewController.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 23/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import ObjectMapper

class RouteSelectionViewController : UIViewController{
    
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var iboDistance: UILabel!
    @IBOutlet weak var addViaPointView: UIView!
    @IBOutlet weak var viaPointsList: UITableView!
    @IBOutlet weak var viaPointstableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iboDone: UIButton!
    @IBOutlet weak var fromLocationLbl: UILabel!
    @IBOutlet weak var toLocationLbl: UILabel!
    @IBOutlet weak var newViaPointView: UIView!
    @IBOutlet weak var newViaPointLabelView: UIView!
    @IBOutlet weak var newViaPointLabel: UILabel!
    @IBOutlet weak var newViaPointSequnceLabel: UILabel!
    @IBOutlet weak var newViaPointSeqView: UIView!
    @IBOutlet weak var viaPointSelectPin: UIImageView!
    @IBOutlet weak var viaPointZoomLevelWarningView: UIView!
    @IBOutlet weak var newOrAddViaPointViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var loopsFoundErroView: UIView!
    
    private var routePolyline : GMSPolyline?
    private var wayPointMarkers = [GMSMarker]()
    private var startMarker,endMarker:GMSMarker?
    private weak var iboMapView: GMSMapView!
    private let startIcon = UIImage(named: "icon_start_location")!
    private let endIcon = UIImage(named: "drop_icon")!
    
    
    private var routeSelectionViewModel = RouteSelectionViewModel()
    
    func initializeDataBeforePresenting(ride : Ride, rideRoute:RideRoute, routeSelectionDelegate : RouteSelectionDelegate){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        routeSelectionViewModel = RouteSelectionViewModel(ride : ride,rideRoute : rideRoute,routeSelectionDelegate: routeSelectionDelegate)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        definesPresentationContext = true
        super.viewDidLoad()
        iboDone.addShadow()
        
        ViewCustomizationUtils.addCornerRadiusToView(view: iboDone, cornerRadius: 20.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: newViaPointLabelView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: newViaPointLabelView, borderWidth: 1, color: UIColor(netHex: 0xE0E0E0))
        ViewCustomizationUtils.addCornerRadiusToView(view: newViaPointSeqView, cornerRadius: 7.5)
        
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        iboMapView.padding = UIEdgeInsets(top: 10, left: 10, bottom: 70, right: 10)
        addViaPointView.isUserInteractionEnabled = true
        addViaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RouteSelectionViewController.addViaPoint(_:))))
        newViaPointView.isUserInteractionEnabled = true
        newViaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RouteSelectionViewController.newViaPointViewTapped(_:))))
        
        viaPointsList.delegate = self
        viaPointsList.dataSource = self
        
        iboDone.isEnabled = false
        if !routeSelectionViewModel.isInPutValid(){
            MessageDisplay.displayAlert( messageString: Strings.route_short_can_not_customized, viewController: self, handler: { (result) -> Void in
                if result == Strings.ok_caps {
                    self.navigationController?.popViewController(animated: false)
                }
            })
            return
        }
        fromLocationLbl.text = routeSelectionViewModel.ride.startAddress
        toLocationLbl.text = routeSelectionViewModel.ride.endAddress
        self.navigationItem.title = routeSelectionViewModel.getTitleForRoute()
        perform(#selector(RouteSelectionViewController.drawRoute), with: self, afterDelay: 0.5)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRoute(_:)), name: .routeReceived ,object: routeSelectionViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(routeContainLoops(_:)), name: .routeContainLoops ,object: routeSelectionViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRouteFailed(_:)), name: .routeFailed ,object: routeSelectionViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(viaPointsChanged(_:)), name: .viaPointsChanged, object: routeSelectionViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(newViaPointChanged(_:)), name: .newViaPointChanged, object: routeSelectionViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(viaPointEditUndone(_:)), name: .viaPointEditUndone, object: routeSelectionViewModel)
        
    }
    
    
    @objc func drawRoute(){
        
        iboMapView.clear()
        wayPointMarkers.removeAll()
        routePolyline = nil
        let start =  CLLocationCoordinate2D(latitude: routeSelectionViewModel.ride.startLatitude,longitude: routeSelectionViewModel.ride.startLongitude)
        startMarker =  GoogleMapUtils.addMarker(googleMap: iboMapView,location: start, shortIcon: startIcon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        let end = CLLocationCoordinate2D(latitude: routeSelectionViewModel.ride.endLatitude!,longitude: routeSelectionViewModel.ride.endLongitude!)
        endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView,location: end, shortIcon: endIcon, tappable: false, anchor: CGPoint(x: 0.8, y: 0.8))
        
        self.routePolyline = GoogleMapUtils.drawRoute(pathString: routeSelectionViewModel.rideRoute.overviewPolyline!,map: iboMapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10,tappable: true)
        if let viaPoints = self.routeSelectionViewModel.getWayPointsOfRoute(), viaPoints.count <= 5 {
            for (index, wayPoint) in viaPoints.enumerated() {
                let pointIcon = getViaPointsMark(index: index)
                let wayPointMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: wayPoint.getCoordinate(), shortIcon: pointIcon, tappable: true, anchor: CGPoint(x: 0.5, y: 0.5))
                wayPointMarkers.append(wayPointMarker)
            }
        }
        reloadViaPoints()
        enableViaPointSelection(enabled: false, point: nil)
        iboDistance.text = "\(routeSelectionViewModel.rideRoute.distance!.roundToPlaces(places: 2))"+" "+Strings.KM+"    "+"\(StringUtils.getStringFromDouble(decimalNumber: routeSelectionViewModel.rideRoute.duration!))"+" "+Strings.mins
        GoogleMapUtils.fitToScreen(route: routeSelectionViewModel.rideRoute.overviewPolyline!, map: iboMapView)
        
    }
    
    
    
    @IBAction func ibaDone(_ sender: Any) {
        loopsFoundErroView.isHidden = true
        if routeSelectionViewModel.isViaPointEditSession(){
            QuickRideProgressSpinner.startSpinner()
            routeSelectionViewModel.saveViaPoint()
        }else{
            saveRoute()
        }
    }
    
    func saveRoute(){
        if !routeSelectionViewModel.isRouteChanged(){
            self.navigationController?.popViewController(animated: true)            
        }else if routeSelectionViewModel.isRouteDistanceIncreasedByThreshold(){
            showErrorInSaveRoute(message: String(format: Strings.loops_in_route_distance_error, arguments: [String(routeSelectionViewModel.calculateDistanceChangeInNewRoute())]))
        }else{
            saveRouteAfterValidation()
        }
    }
    
    func saveRouteAfterValidation(){
        let saveRouteUtilsInstance = SaveRouteViewUtils()
        if let preferredRoute = routeSelectionViewModel.userPreferredRoute{
            
            QuickRideProgressSpinner.startSpinner()
            saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: routeSelectionViewModel.ride.rideType)).CustomRoute.RouteSelectionView", ride: routeSelectionViewModel.ride, preferredRoute: preferredRoute, viaPointString: routeSelectionViewModel.wayPoints.toJSONString(), routeName: nil) { (route, preferredRoute, responseError, error)  in
                QuickRideProgressSpinner.stopSpinner()
                if let route = route{
                    self.navigationController?.popViewController(animated: false)
                    self.routeSelectionViewModel.routeSelectionDelegate?.receiveSelectedRoute(ride: self.routeSelectionViewModel.ride, route: route)
                }else{
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }else{
            let saveCustomizedRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SaveCustomizedRouteViewController") as! SaveCustomizedRouteViewController
            let suggestedRouteName = saveRouteUtilsInstance.getSuggestingNameForRoute(ride: self.routeSelectionViewModel.ride, wayPoints: routeSelectionViewModel.wayPoints)
            saveCustomizedRouteViewController.initializeDataBeforePresenting(suggestedRouteName: suggestedRouteName, handler: { [unowned self] (routeName) in
                QuickRideProgressSpinner.startSpinner()
                saveRouteUtilsInstance.saveEditedRoute(useCase: "IOS.App.\(String(describing: self.routeSelectionViewModel.ride.rideType)).CustomRoute.RouteSelectionView", ride: self.routeSelectionViewModel.ride, preferredRoute: nil, viaPointString: self.routeSelectionViewModel.wayPoints.toJSONString(), routeName: routeName) { (route, preferredRoute, responseError, error)  in
                    QuickRideProgressSpinner.stopSpinner()
                    if let route  = route {
                        if preferredRoute != nil {
                            self.navigationController?.popViewController(animated: false)
                            self.routeSelectionViewModel.routeSelectionDelegate?.receiveSelectedRoute(ride: self.routeSelectionViewModel.ride, route: route)
                        } else {
                            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                        }
                    }
                }
            })
            self.navigationController?.view.addSubview(saveCustomizedRouteViewController.view)
            self.navigationController?.addChild(saveCustomizedRouteViewController)
            
        }
    }
    
    @objc func addViaPoint(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("")
        selectViaPoint()
    }
    
    @objc func newViaPointViewTapped(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("")
        let backGroundColor = newViaPointLabelView.backgroundColor
        newViaPointLabelView.backgroundColor = UIColor.white
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.newViaPointLabelView.backgroundColor = backGroundColor
            self.getViaPointFromLocationSearch()
        }
    }
    
    func selectViaPoint() {
        if let polyLineString = routeSelectionViewModel.rideRoute.overviewPolyline, let coordinates = Polyline(encodedPolyline:polyLineString ).coordinates{
            let center = coordinates[coordinates.count/2]
            routeSelectionViewModel.newViaPoint = Location(latitude: center.latitude,longitude: center.longitude,shortAddress: nil)
            enableViaPointSelection(enabled: true,point: center);
        }
    }
    
    func enableViaPointSelection(enabled : Bool, point : CLLocationCoordinate2D?){
        if(enabled){
            addViaPointView.isHidden = true
            newViaPointView.isHidden = false
            newOrAddViaPointViewHeight.constant = 30
            iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
            viaPointSelectPin.isHidden = false
            if point != nil{
                iboMapView.animate(with: GMSCameraUpdate.setTarget(point!, zoom: 18))
                let viaPointSequence = routeSelectionViewModel.getSequenceAlphabetFor(index: routeSelectionViewModel.wayPoints.count)
                newViaPointSequnceLabel.text = viaPointSequence
            }
        }else{
            addViaPointView.isHidden = false
            newViaPointView.isHidden = true
            newOrAddViaPointViewHeight.constant = 30
            iboDone.setTitle(Strings.CONFIRM_ROUTE, for: .normal)
            viaPointZoomLevelWarningView.isHidden = true
            iboDone.backgroundColor = UIColor(netHex: 0x00B557)
            iboDone.isEnabled = true
            viaPointSelectPin.isHidden = true
            if routePolyline != nil{
                iboMapView.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds.init(path: routePolyline!.path!), withPadding: 50))
            }
        }
    }
    
    private func getViaPointsMark(index: Int) -> UIImage{
        let viaPointMark = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
        let seqAlphbat = routeSelectionViewModel.getSequenceAlphabetFor(index: index)
        viaPointMark.initializeView(name: seqAlphbat, colorCode: UIColor(netHex: 0x515151))
        return ViewCustomizationUtils.getImageFromView(view: viaPointMark)
    }
    func reloadViaPoints(){
        viaPointsList.delegate = nil
        viaPointsList.dataSource = nil
        let count = routeSelectionViewModel.wayPoints.count
        if count > 0{
            viaPointsList.isHidden = false
            viaPointsList.delegate = self
            viaPointsList.dataSource = self
            viaPointsList.reloadData()
            let height = CGFloat(45*count)
            viaPointstableViewHeight.constant = height
        }else{
            viaPointsList.isHidden = true
            viaPointstableViewHeight.constant = 0
        }
    }
    private func removeWayPointMarkers(){
        AppDelegate.getAppDelegate().log.debug("removeWayPointMarkers()")
        for  marker in wayPointMarkers{
            marker.map = nil
        }
        wayPointMarkers.removeAll()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        loopsFoundErroView.isHidden = true
        if routeSelectionViewModel.isRouteChanged(){
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.save_edit_route, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self) { [weak self](actionText) in
                guard let self = `self` else {
                    return
                }
                if actionText == Strings.yes_caps{
                    self.saveRoute()
                }else if actionText == Strings.no_caps{
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }else{
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    @IBAction func removeViaPoint(_ sender: UIButton) {
        QuickRideProgressSpinner.startSpinner()
        routeSelectionViewModel.viaPointRemoved(index : sender.tag)
    }
    private func showErrorInSaveRoute(message : String){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: message, message2: nil, positiveActnTitle: Strings.recustomize_caps,negativeActionTitle : Strings.continue_text_caps,linkButtonText: nil, viewController: self, handler: { [unowned self] (result) in
            if result == Strings.continue_text_caps{
                self.saveRouteAfterValidation()
            }
        })
    }
    
    @IBAction func removeNewViaPointAction(_ sender: Any) {
        routeSelectionViewModel.newViaPointRemoved()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
}
extension RouteSelectionViewController {
    @objc func receiveRoute(_ notification:Notification) {
        AppDelegate.getAppDelegate().log.debug("receiveRoute()")
        QuickRideProgressSpinner.stopSpinner()
        drawRoute()
        
    }
    @objc func routeContainLoops(_ notification: Notification){
        AppDelegate.getAppDelegate().log.debug("routeContainLoops()")
        QuickRideProgressSpinner.stopSpinner()
        iboMapView.clear()
        wayPointMarkers.removeAll()
        routePolyline = nil
        let start =  CLLocationCoordinate2D(latitude: routeSelectionViewModel.ride.startLatitude,longitude: routeSelectionViewModel.ride.startLongitude)
        startMarker =  GoogleMapUtils.addMarker(googleMap: iboMapView,location: start, shortIcon: startIcon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        let end = CLLocationCoordinate2D(latitude: routeSelectionViewModel.ride.endLatitude!,longitude: routeSelectionViewModel.ride.endLongitude!)
        endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView,location: end, shortIcon: endIcon, tappable: false, anchor: CGPoint(x: 0.8, y: 0.8))
        if let route = notification.userInfo?["route"] as? RideRoute {
            self.routePolyline = GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!,map: iboMapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10,tappable: true)
        }
        
        loopsFoundErroView.isHidden = false
        
    }
    
    @objc func receiveRouteFailed(_ notification:Notification) {
        AppDelegate.getAppDelegate().log.debug("receiveRouteFailed()")
        QuickRideProgressSpinner.stopSpinner()
        let responseError = notification.userInfo?["responseError"] as? ResponseError
        let error = notification.userInfo?["nsError"] as? NSError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
    }
    @objc func viaPointsChanged(_ notification:Notification){
        reloadViaPoints()
    }
    @objc func newViaPointChanged(_ notification:Notification){
        if let address = routeSelectionViewModel.newViaPoint?.completeAddress{
            newViaPointLabel.text = address
        }
    }
    @objc func viaPointEditUndone(_ notification : NSNotification){
        QuickRideProgressSpinner.stopSpinner()
        reloadViaPoints()
        enableViaPointSelection(enabled: false, point: nil)
        GoogleMapUtils.fitToScreen(route: routeSelectionViewModel.rideRoute.overviewPolyline!, map: iboMapView)
    }
}
extension RouteSelectionViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSelectionViewModel.wayPoints.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viaPointCell") as! ViaPointTableViewCell
        if routeSelectionViewModel.wayPoints.endIndex <= indexPath.row{
            return cell
        }
        let index = indexPath.row
        let viaPoint = routeSelectionViewModel.wayPoints[indexPath.row]
        let seqAlphabat = routeSelectionViewModel.getSequenceAlphabetFor(index: indexPath.row)
        cell.setUpUI(viaPoint: viaPoint, index: index,sequenceAlphabat: seqAlphabat,newViaPoint: routeSelectionViewModel.newViaPoint,selectedViaPointIndex: routeSelectionViewModel.selectedViaPointIndex)
        return cell
    }
    fileprivate func getViaPointFromLocationSearch() {
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.ORIGIN, currentSelectedLocation: routeSelectionViewModel.newViaPoint, hideSelectLocationFromMap: true, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationViewController, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ViaPointTableViewCell else {
            return
        }
        if !routeSelectionViewModel.isEditAllowedFor(row: indexPath.row){
            return
        }
        let backGroundColor = cell.viaPointView.backgroundColor
        cell.viaPointView.backgroundColor = routeSelectionViewModel.isViaPointEditSession() ? UIColor(netHex : 0xF5F5F5) : UIColor.white
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            cell.viaPointView.backgroundColor = backGroundColor
            if self.routeSelectionViewModel.isViaPointEditSession(){
                self.getViaPointFromLocationSearch()
            }else{
                let wayPoint = self.routeSelectionViewModel.wayPoints[indexPath.row]
                self.routeSelectionViewModel.newViaPoint = wayPoint
                self.routeSelectionViewModel.selectedViaPointIndex = indexPath.row
                self.addViaPointView.isHidden = true
                self.newViaPointView.isHidden = true
                self.newOrAddViaPointViewHeight.constant = 0
                self.viaPointSelectPin.isHidden = false
                self.iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
                
                self.iboMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: wayPoint.latitude, longitude: wayPoint.longitude), zoom: 18))
                tableView.reloadData()
            }
        }
    }
    
}

extension RouteSelectionViewController : GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        
        if !routeSelectionViewModel.isViaPointEditSession(){
            return
        }
        iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
        if mapView.camera.zoom < 18 {
            viaPointZoomLevelWarningView.isHidden = false
            loopsFoundErroView.isHidden = true
            iboDone.backgroundColor = UIColor(netHex: 0xC9C9C9)
            iboDone.isEnabled = false
            return
        }
        viaPointZoomLevelWarningView.isHidden = true
        
        iboDone.backgroundColor = UIColor(netHex: 0x00B557)
        iboDone.isEnabled = true
        routeSelectionViewModel.handleViaPointSelection(viaPoint: mapView.camera.target)
    }
    
}

extension RouteSelectionViewController : ReceiveLocationDelegate{
    func receiveSelectedLocation(location : Location,requestLocationType : String){
        self.routeSelectionViewModel.newViaPoint = location
        if routeSelectionViewModel.selectedViaPointIndex != -1{
            viaPointsList.reloadData()
        }else{
            newViaPointLabel.text = location.completeAddress
        }
        self.iboMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), zoom: 18))
    }
    func locationSelectionCancelled(requestLocationType : String){
        
    }
}
