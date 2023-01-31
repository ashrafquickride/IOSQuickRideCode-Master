//
//  TaxiRideEditRouteViewController.swift
//  Quickride
//
//  Created by Rajesab on 23/12/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import CoreLocation



class TaxiRideEditRouteViewController: UIViewController {

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var iboDistance: UILabel!
    @IBOutlet weak var addviaPointView: UIView!
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
    @IBOutlet weak var viaPointLocationLabel: UILabel!
    @IBOutlet weak var locationsStackView: UIView!
    @IBOutlet weak var locationStackViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var mapViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var loopsFoundErrorView: UIView!
    
    
    private var taxiRideEditRouteViewModel = TaxiRideEditRouteViewModel()
    private var routePolyline : GMSPolyline?
    private var wayPointMarkers = [GMSMarker]()
    private var startMarker,endMarker:GMSMarker?
    private weak var iboMapView: GMSMapView!
    private let startIcon = UIImage(named: "icon_start_location")!
    private let endIcon = UIImage(named: "drop_icon")!
    
    func initialiseData(startLocation: Location?,endLocation: Location?,rideRoute: RideRoute?,routeSelectionDelegate: RouteSelectionDelegate){
        taxiRideEditRouteViewModel = TaxiRideEditRouteViewModel(startLocation: startLocation, endLocation: endLocation, rideRoute: rideRoute, routeSelectionDelegate: routeSelectionDelegate)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        iboDone.addShadow()

        ViewCustomizationUtils.addCornerRadiusToView(view: iboDone, cornerRadius: 20.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: newViaPointLabelView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: newViaPointLabelView, borderWidth: 1, color: UIColor(netHex: 0xE0E0E0))
        ViewCustomizationUtils.addCornerRadiusToView(view: newViaPointSeqView, cornerRadius: 7.5)
        newViaPointLabelView.isHidden = true
        
        viaPointLocationLabel.isHidden = true
        ViewCustomizationUtils.addCornerRadiusToView(view: viaPointLocationLabel, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: viaPointLocationLabel, borderWidth: 1, color: UIColor(netHex: 0xE0E0E0))
        
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        iboMapView.padding = UIEdgeInsets(top: 10, left: 10, bottom: 70, right: 10)
        addviaPointView.isUserInteractionEnabled = true
        addviaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TaxiRideEditRouteViewController.addViaPoint(_:))))
        newViaPointView.isUserInteractionEnabled = true
        newViaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TaxiRideEditRouteViewController.newViaPointViewTapped(_:))))
        
        viaPointsList.delegate = self
        viaPointsList.dataSource = self
        
        iboDone.isEnabled = false
        
        if taxiRideEditRouteViewModel.isStartAndEndAddressAreSame(){
            MessageDisplay.displayAlert( messageString: Strings.route_short_can_not_customized, viewController: self, handler: { (result) -> Void in
                if result == Strings.ok_caps {
                    self.navigationController?.popViewController(animated: false)
                }
            })
            return
        }
        fromLocationLbl.text = taxiRideEditRouteViewModel.startLocation?.address ?? taxiRideEditRouteViewModel.startLocation?.shortAddress
        toLocationLbl.text = taxiRideEditRouteViewModel.endLocation?.address ?? taxiRideEditRouteViewModel.endLocation?.shortAddress
        
        perform(#selector(RouteSelectionViewController.drawRoute), with: self, afterDelay: 0.5)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRoute(_:)), name: .routeReceived ,object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(routeContainLoops(_:)), name: .routeContainLoops ,object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRouteFailed(_:)), name: .routeFailed ,object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(viaPointsChanged(_:)), name: .viaPointsChanged, object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(newViaPointChanged(_:)), name: .newViaPointChanged, object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(viaPointEditUndone(_:)), name: .viaPointEditUndone, object: taxiRideEditRouteViewModel)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func drawRoute(){
        
        iboMapView.clear()
        wayPointMarkers.removeAll()
        routePolyline = nil
        let start =  CLLocationCoordinate2D(latitude: taxiRideEditRouteViewModel.startLocation?.latitude ?? 0 ,longitude: taxiRideEditRouteViewModel.startLocation?.longitude ?? 0 )
        startMarker =  GoogleMapUtils.addMarker(googleMap: iboMapView,location: start, shortIcon: startIcon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        let end = CLLocationCoordinate2D(latitude: taxiRideEditRouteViewModel.endLocation?.latitude ?? 0 ,longitude: taxiRideEditRouteViewModel.endLocation?.longitude ?? 0)
        endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView,location: end, shortIcon: endIcon, tappable: false, anchor: CGPoint(x: 0.8, y: 0.8))
        
        self.routePolyline = GoogleMapUtils.drawRoute(pathString: (taxiRideEditRouteViewModel.rideRoute?.overviewPolyline!)!,map: iboMapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10,tappable: true)
        if let viaPoints = self.taxiRideEditRouteViewModel.getWayPointsOfRoute(), viaPoints.count <= 5 {
            for (index, wayPoint) in viaPoints.enumerated() {
                let pointIcon = getViaPointsMark(index: index)
                let wayPointMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: wayPoint.getCoordinate(), shortIcon: pointIcon, tappable: true, anchor: CGPoint(x: 0.5, y: 0.5))
                wayPointMarkers.append(wayPointMarker)
            }
        }
        reloadViaPoints()
        enableViaPointSelection(enabled: false, point: nil)
        guard let distanceInKm = taxiRideEditRouteViewModel.rideRoute?.distance  else {
            return
        }
        var distance = distanceInKm
        if let duration = taxiRideEditRouteViewModel.rideRoute?.duration,duration > 0 {
            iboDistance.text = "\(String(describing: distance.roundToPlaces(places: 2)))"+" "+Strings.KM+"    "+"\(StringUtils.getStringFromDouble(decimalNumber: taxiRideEditRouteViewModel.rideRoute?.duration!))"+" "+Strings.mins
        } else {
            iboDistance.text = "\(String(describing: distance.roundToPlaces(places: 2)))"+" "+Strings.KM
        }
    }
    
    private func getViaPointsMark(index: Int) -> UIImage{
        let viaPointMark = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
        let seqAlphbat = taxiRideEditRouteViewModel.getSequenceAlphabetFor(index: index)
        viaPointMark.initializeView(name: seqAlphbat, colorCode: UIColor(netHex: 0x515151))
        return ViewCustomizationUtils.getImageFromView(view: viaPointMark)
    }
    
    func reloadViaPoints(){
        viaPointsList.delegate = nil
        viaPointsList.dataSource = nil
        let count = taxiRideEditRouteViewModel.wayPoints.count
        if count > 0 || taxiRideEditRouteViewModel.isRouteChanged() {
            viaPointsList.isHidden = false
            viaPointsList.delegate = self
            viaPointsList.dataSource = self
            viaPointsList.reloadData()
            let height = CGFloat(45*count)
            viaPointstableViewHeight.constant = height
            locationStackViewHeightConstraints.constant = 140 + height
            iboDone.isHidden = false
        }else{
            iboDone.isHidden = true
            viaPointsList.isHidden = true
            viaPointstableViewHeight.constant = 0
            locationStackViewHeightConstraints.constant = 140
        }
    }
    
    func enableViaPointSelection(enabled : Bool, point : CLLocationCoordinate2D?){
        if(enabled){
            addviaPointView.isHidden = true
            newViaPointView.isHidden = false
            newOrAddViaPointViewHeight.constant = 30
            iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
            viaPointSelectPin.isHidden = false
            if point != nil{
                iboMapView.animate(with: GMSCameraUpdate.setTarget(point!, zoom: 18))
                let viaPointSequence = taxiRideEditRouteViewModel.getSequenceAlphabetFor(index: taxiRideEditRouteViewModel.wayPoints.count)
                newViaPointSequnceLabel.text = viaPointSequence
            }
        }else{
            addviaPointView.isHidden = false
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
    @objc func addViaPoint(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("addViaPoint()")
        taxiRideEditRouteViewModel.isNewViaPointAdded = true
        getViaPointFromLocationSearch()
        selectViaPoint()
    }
    
    func selectViaPoint() {
        if let polyLineString = taxiRideEditRouteViewModel.rideRoute?.overviewPolyline, let coordinates = Polyline(encodedPolyline:polyLineString ).coordinates{
            let center = coordinates[coordinates.count/2]
            taxiRideEditRouteViewModel.newViaPoint = Location(latitude: center.latitude,longitude: center.longitude,shortAddress: nil)
            enableViaPointSelection(enabled: true,point: center);
        }
    }
    
    private func updateUIForNewViaPoint(){
        self.mapViewContainer.translatesAutoresizingMaskIntoConstraints = false

        if taxiRideEditRouteViewModel.isViaPointEditSession(){
            mapViewTopMargin.constant = 0
//            locationStackViewHeightConstraints.constant = 0
            locationsStackView.isHidden = true
            viaPointLocationLabel.isHidden = false
            
            iboDone.isHidden = false
        }else{
            mapViewTopMargin.constant = 140
            locationsStackView.isHidden = false
            viaPointLocationLabel.isHidden = true
            reloadViaPoints()
        }
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
    
    @objc func newViaPointChanged(_ notification:Notification){
        if let address = taxiRideEditRouteViewModel.newViaPoint?.completeAddress{
            newViaPointLabel.text = address
            viaPointLocationLabel.text = address
        }
    }
    
    @objc func viaPointEditUndone(_ notification : NSNotification){
        QuickRideProgressSpinner.stopSpinner()
        reloadViaPoints()
        enableViaPointSelection(enabled: false, point: nil)
        GoogleMapUtils.fitToScreen(route: (taxiRideEditRouteViewModel.rideRoute?.overviewPolyline!)!, map: iboMapView)
    }
    
    @IBAction func ibaDone(_ sender: Any) {
        loopsFoundErrorView.isHidden = true
        if taxiRideEditRouteViewModel.isViaPointEditSession(){
            QuickRideProgressSpinner.startSpinner()
            taxiRideEditRouteViewModel.saveViaPoint()
            updateUIForNewViaPoint()
        }else{
            saveRoute()
        }
    }
    
    func saveRoute(){
        if !taxiRideEditRouteViewModel.isRouteChanged(){
            self.navigationController?.popViewController(animated: true)
            
        }else if taxiRideEditRouteViewModel.isRouteDistanceIncreasedByThreshold(){
            showErrorInSaveRoute(message: String(format: Strings.loops_in_route_distance_error, arguments: [String(taxiRideEditRouteViewModel.calculateDistanceChangeInNewRoute())]))
        }else{
            saveRouteAfterValidation()
        }
    }
    func saveRouteAfterValidation(){
        let saveRouteUtilsInstance = SaveRouteViewUtils()
        if let preferredRoute = taxiRideEditRouteViewModel.userPreferredRoute{
            
            QuickRideProgressSpinner.startSpinner()
            saveRouteUtilsInstance.saveTaxiEditedRoute(useCase: "IOS.App.CustomRoute.RouteSelectionView",startLocation: taxiRideEditRouteViewModel.startLocation, endLocation: taxiRideEditRouteViewModel.endLocation, preferredRoute: preferredRoute, viaPointString: taxiRideEditRouteViewModel.wayPoints.toJSONString(), routeName: nil) { (route, preferredRoute, responseError, error)  in
                QuickRideProgressSpinner.stopSpinner()
                if let route = route{
                    self.navigationController?.popViewController(animated: false)
                    self.taxiRideEditRouteViewModel.routeSelectionDelegate?.receiveSelectedRoute(ride: nil, route: route)
                }else{
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }else{
            let saveCustomizedRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SaveCustomizedRouteViewController") as! SaveCustomizedRouteViewController
            let suggestedRouteName = taxiRideEditRouteViewModel.getSuggestingNameForRoute(startLocation: taxiRideEditRouteViewModel.startLocation ,endLocation: taxiRideEditRouteViewModel.endLocation, wayPoints: taxiRideEditRouteViewModel.wayPoints)
            saveCustomizedRouteViewController.initializeDataBeforePresenting(suggestedRouteName: suggestedRouteName, handler: { [unowned self] (routeName) in
                QuickRideProgressSpinner.startSpinner()
                saveRouteUtilsInstance.saveTaxiEditedRoute(useCase: "IOS.App.CustomRoute.RouteSelectionView",startLocation: taxiRideEditRouteViewModel.startLocation, endLocation: taxiRideEditRouteViewModel.endLocation, preferredRoute: nil, viaPointString: self.taxiRideEditRouteViewModel.wayPoints.toJSONString(), routeName: routeName) { (route, preferredRoute, responseError, error)  in
                    QuickRideProgressSpinner.stopSpinner()
                    if let route  = route {
                        if preferredRoute != nil {
                            self.navigationController?.popViewController(animated: false)
                            self.taxiRideEditRouteViewModel.routeSelectionDelegate?.receiveSelectedRoute(ride: nil, route: route)
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
    
    private func showErrorInSaveRoute(message : String){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: message, message2: nil, positiveActnTitle: Strings.recustomize_caps,negativeActionTitle : Strings.continue_text_caps,linkButtonText: nil, viewController: self, handler: { [unowned self] (result) in
            if result == Strings.continue_text_caps{
                self.saveRouteAfterValidation()
            }
        })
    }
    
    @IBAction func removeNewViaPointAction(_ sender: Any) {
        taxiRideEditRouteViewModel.newViaPointRemoved() 
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func removeViaPoint(_ sender: UIButton) {
        QuickRideProgressSpinner.startSpinner()
        taxiRideEditRouteViewModel.viaPointRemoved(index : sender.tag)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        loopsFoundErrorView.isHidden = true
        if taxiRideEditRouteViewModel.isViaPointEditSession() {
            taxiRideEditRouteViewModel.newViaPointRemoved()
            iboDone.setTitle(Strings.CONFIRM_ROUTE, for: .normal)
            updateUIForNewViaPoint()
        }else {
            if taxiRideEditRouteViewModel.isUserRouteChanged(){
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.editRouteAlertMessage, message2: nil, positiveActnTitle: Strings.ok, negativeActionTitle : Strings.cancel,linkButtonText : nil,viewController: self, handler: { (result) in
                    if Strings.ok == result{
                        self.navigationController?.popViewController(animated: false)
                    }
                })
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
       
}



extension TaxiRideEditRouteViewController {
    @objc func receiveRoute(_ notification:Notification) {
           AppDelegate.getAppDelegate().log.debug()
           QuickRideProgressSpinner.stopSpinner()
           drawRoute()
    }
    @objc func routeContainLoops(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        iboMapView.clear()
        wayPointMarkers.removeAll()
        routePolyline = nil
        if let startLocation = taxiRideEditRouteViewModel.startLocation, startLocation.latitude > 0, startLocation.longitude > 0 {
            let start =  CLLocationCoordinate2D(latitude: startLocation.latitude,longitude: startLocation.longitude)
            startMarker =  GoogleMapUtils.addMarker(googleMap: iboMapView,location: start, shortIcon: startIcon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        }
        if let endLocation = taxiRideEditRouteViewModel.endLocation, endLocation.latitude > 0 , endLocation.longitude > 0 {
            let end = CLLocationCoordinate2D(latitude: endLocation.latitude,longitude: endLocation.longitude)
            endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView,location: end, shortIcon: endIcon, tappable: false, anchor: CGPoint(x: 0.8, y: 0.8))
        }
        if let route = notification.userInfo?["route"] as? RideRoute {
            self.routePolyline = GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!,map: iboMapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10,tappable: true)
        }
        loopsFoundErrorView.isHidden = false
    }
}

extension TaxiRideEditRouteViewController:  UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taxiRideEditRouteViewModel.wayPoints.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viaPointCell") as! ViaPointTableViewCell
        if taxiRideEditRouteViewModel.wayPoints.endIndex <= indexPath.row{
            return cell
        }
        
        let index = indexPath.row
        let viaPoint = taxiRideEditRouteViewModel.wayPoints[indexPath.row]
        let seqAlphabat = taxiRideEditRouteViewModel.getSequenceAlphabetFor(index: indexPath.row)
        cell.setUpUI(viaPoint: viaPoint, index: index,sequenceAlphabat: seqAlphabat,newViaPoint: taxiRideEditRouteViewModel.newViaPoint,selectedViaPointIndex: taxiRideEditRouteViewModel.selectedViaPointIndex)
        return cell
    }
    
    fileprivate func getViaPointFromLocationSearch() {
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: ChangeLocationViewController.ORIGIN, currentSelectedLocation: taxiRideEditRouteViewModel.newViaPoint, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationViewController, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ViaPointTableViewCell else {
            return
        }
        if !taxiRideEditRouteViewModel.isEditAllowedFor(row: indexPath.row){ 
            return
        }
        let backGroundColor = cell.viaPointView.backgroundColor
        cell.viaPointView.backgroundColor = taxiRideEditRouteViewModel.isViaPointEditSession() ? UIColor(netHex : 0xF5F5F5) : UIColor.white
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            cell.viaPointView.backgroundColor = backGroundColor
            if self.taxiRideEditRouteViewModel.isViaPointEditSession(){
                self.getViaPointFromLocationSearch()
            }else{
                let wayPoint = self.taxiRideEditRouteViewModel.wayPoints[indexPath.row]
                self.taxiRideEditRouteViewModel.newViaPoint = wayPoint
                self.taxiRideEditRouteViewModel.selectedViaPointIndex = indexPath.row
                self.addviaPointView.isHidden = true
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
extension TaxiRideEditRouteViewController : GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if !taxiRideEditRouteViewModel.isViaPointEditSession(){
            return
        }
        iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
        if mapView.camera.zoom < 18 {
            viaPointZoomLevelWarningView.isHidden = false
            loopsFoundErrorView.isHidden = true
            iboDone.backgroundColor = UIColor(netHex: 0xC9C9C9)
            iboDone.isEnabled = false
            return
        }
        viaPointZoomLevelWarningView.isHidden = true
        iboDone.backgroundColor = UIColor(netHex: 0x00B557)
        iboDone.isEnabled = true
        taxiRideEditRouteViewModel.handleViaPointSelection(viaPoint: mapView.camera.target) 
    }
    
}

extension TaxiRideEditRouteViewController : ReceiveLocationDelegate{
    func receiveSelectedLocation(location : Location,requestLocationType : String){
        
        updateUIForNewViaPoint()
        
        self.taxiRideEditRouteViewModel.newViaPoint = location
        if taxiRideEditRouteViewModel.selectedViaPointIndex != -1{
            viaPointsList.reloadData()
        }else{
            newViaPointLabel.text = location.completeAddress
        }
        self.iboMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), zoom: 18))
    }
    
    func locationSelectionCancelled(requestLocationType : String){
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
        if taxiRideEditRouteViewModel.isViaPointEditSession(){
            taxiRideEditRouteViewModel.newViaPointRemoved()
        }
    }
}
