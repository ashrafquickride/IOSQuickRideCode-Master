//
//  TaxiRideEditViewController.swift
//  Quickride
//
//  Created by Quick Ride on 4/21/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline
import CoreLocation

class TaxiRideEditViewController: UIViewController {


    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var iboDistance: UILabel!
    @IBOutlet weak var addviaPointView: UIStackView!
    @IBOutlet weak var viaPointsList: UITableView!
    @IBOutlet weak var iboDone: UIButton!
    @IBOutlet weak var fromLocationLbl: UILabel!
    @IBOutlet weak var toLocationLbl: UILabel!
    @IBOutlet weak var viaPointSelectPin: UIImageView!
    @IBOutlet weak var viaPointZoomLevelWarningView: UIView!
    @IBOutlet weak var viaPointLocationLabel: UILabel!
    @IBOutlet weak var locationsStackView: UIStackView!

    @IBOutlet weak var fromLocationView: UIStackView!

    @IBOutlet weak var fromLocationEditIcon: UIImageView!


    @IBOutlet weak var toLocationView: UIStackView!

    @IBOutlet weak var pickupTimeView: UIStackView!

    @IBOutlet weak var pickupTimeLabel: UILabel!

    @IBOutlet weak var mapViewTopMargin: NSLayoutConstraint!

    @IBOutlet weak var viaPointTableViewHeigh: NSLayoutConstraint!

    @IBOutlet weak var newViaPointView: UIView!

    @IBOutlet weak var loopsErrorView: UIView!
    
    @IBOutlet weak var pickupTimeImage: UIImageView!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @IBAction func backButtonAction(_ sender: Any) {
        loopsErrorView.isHidden = true
        if taxiRideEditRouteViewModel.isViaPointEditSession() {
            taxiRideEditRouteViewModel.disableViaPointEdit()
            updateUIBasedOnEditSession()
            return
        }
        if !taxiRideEditRouteViewModel.rideDetailsChanged(){
            self.navigationController?.popViewController(animated: false)
            return
        }
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: "Discard changes?", message2: nil, positiveActnTitle: Strings.ok, negativeActionTitle : Strings.cancel,linkButtonText : nil,viewController: self, handler: { (result) in
            if Strings.ok == result{
                self.navigationController?.popViewController(animated: false)
            }
        })

    }
    @IBAction func ibaDone(_ sender: Any) {
        loopsErrorView.isHidden = true
        if taxiRideEditRouteViewModel.isViaPointEditSession(){
            QuickRideProgressSpinner.startSpinner()
            taxiRideEditRouteViewModel.saveViaPoint()
            updateUIBasedOnEditSession()
        }else{
            if !taxiRideEditRouteViewModel.rideDetailsChanged(){
                self.navigationController?.popViewController(animated: true)
            }else if taxiRideEditRouteViewModel.wayPoints.isEmpty{
                self.updateRide()
            }else if taxiRideEditRouteViewModel.isRouteDistanceIncreasedByThreshold(){
                showErrorInSaveRoute(message: String(format: Strings.loops_in_route_distance_error, arguments: [String(taxiRideEditRouteViewModel.calculateDistanceChangeInNewRoute())]))
            }else{
                validateAndUpdateRide()
            }
        }
    }

    private let taxiRideEditRouteViewModel = TaxiRideEditViewModel()

    private var routePolylines = [GMSPolyline]()
    private var wayPointMarkers = [GMSMarker]()
    private var startMarker: GMSMarker?
    private var endMarker: GMSMarker?
    private weak var iboMapView: GMSMapView!
    private let startIcon = UIImage(named: "icon_start_location")!
    private let endIcon = UIImage(named: "drop_icon")!


    func initialiseData(taxiRidePassenger: TaxiRidePassenger, handler: @escaping taxiEditCompletionHandler){
        taxiRideEditRouteViewModel.setData(taxiRidePassenger: taxiRidePassenger, handler: handler)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initializeData()

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func setupView() -> Void {
        guard let taxiRidepassenger = taxiRideEditRouteViewModel.taxiRidePassenger else { return  }
        iboDone.addShadow()

        ViewCustomizationUtils.addCornerRadiusToView(view: iboDone, cornerRadius: 20.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: newViaPointView, cornerRadius: 5)

        ViewCustomizationUtils.addBorderToView(view: newViaPointView, borderWidth: 1, color: UIColor.black.withAlphaComponent(0.2))
        iboMapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        iboMapView.delegate = self
        iboMapView.padding = UIEdgeInsets(top: 10, left: 10, bottom: 70, right: 10)
        addviaPointView.isUserInteractionEnabled = true
        addviaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TaxiRideEditRouteViewController.addViaPoint(_:))))
        if taxiRidepassenger.status != TaxiRidePassenger.STATUS_STARTED {
            fromLocationEditIcon.isHidden = false
            fromLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectFromLocation(_:))))
        }else{
            fromLocationEditIcon.isHidden = true
        }

        toLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectToLocation(_:))))
        if taxiRidepassenger.status == TaxiRidePassenger.STATUS_REQUESTED || taxiRidepassenger.status == TaxiRidePassenger.STATUS_CONFIRMED {
            pickupTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPickupTime(_:))))
        }
        newViaPointView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addViaPoint(_:))))
        viaPointsList.estimatedRowHeight = 44
        viaPointsList.rowHeight = UITableView.automaticDimension
        viaPointsList.register(UINib(nibName: "TaxiEditViaPointTableViewCell", bundle: nil), forCellReuseIdentifier: "TaxiEditViaPointTableViewCell")

        registerUpdateNotifications()
    }

    func initializeData() -> Void {
        fromLocationLbl.text = taxiRideEditRouteViewModel.startLocation?.address
        toLocationLbl.text = taxiRideEditRouteViewModel.endLocation?.address
        showTime()
        reloadViaPoints()
        taxiRideEditRouteViewModel.getRoutes()
    }


    @objc func selectFromLocation(_ gesture: UITapGestureRecognizer) -> Void {
        guard let startLocation = taxiRideEditRouteViewModel.startLocation else  {
            return
        }
        moveToLocationSelection(locationType:  ChangeLocationViewController.ORIGIN, location: startLocation, alreadySelectedLocation: taxiRideEditRouteViewModel.endLocation,hideSelectLocationFromMap: false)
    }
    @objc func selectToLocation(_ gesture: UITapGestureRecognizer) -> Void {
        guard let endLocation = taxiRideEditRouteViewModel.endLocation else {
            return
        }
        moveToLocationSelection(locationType:  ChangeLocationViewController.DESTINATION, location: endLocation, alreadySelectedLocation: taxiRideEditRouteViewModel.startLocation,hideSelectLocationFromMap: false)
    }
    @objc func selectPickupTime(_ gesture: UITapGestureRecognizer){

        guard let taxiRidePassenger = taxiRideEditRouteViewModel.taxiRidePassenger, let start = taxiRideEditRouteViewModel.startLocation else { return  }
        let scheduleLater:ScheduleRideViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        let minPickupTime = LocationClientUtils.getMinPickupTimeAcceptedForTaxi(tripType: taxiRidePassenger.tripType!, fromLatitude: start.latitude , fromLongitude: start.longitude)
        let defaultDate = taxiRidePassenger.pickupTimeMs! > minPickupTime ? taxiRidePassenger.pickupTimeMs : minPickupTime

        scheduleLater.initializeDataBeforePresentingView(minDate: minPickupTime/1000,maxDate: nil, defaultDate: defaultDate!/1000, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.dateAndTime, datePickerTitle: nil, handler: nil)
        scheduleLater.delegate = self
        scheduleLater.datePickerMode = UIDatePicker.Mode.dateAndTime

        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }
    @objc func addViaPoint(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("addViaPoint()")
        moveToLocationSelection(locationType: ChangeLocationViewController.VIAPOINT, location: nil, alreadySelectedLocation: nil, hideSelectLocationFromMap: true)
    }

    func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?, hideSelectLocationFromMap: Bool) {
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: true)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }

    private func showTime(){
        guard let taxiRidePassenger = taxiRideEditRouteViewModel.taxiRidePassenger else { return }
        if taxiRidePassenger.status == TaxiRidePassenger.STATUS_REQUESTED || taxiRidePassenger.status == TaxiRidePassenger.STATUS_CONFIRMED {
            pickupTimeLabel.textColor = UIColor(netHex: 0x007AFF)
            pickupTimeImage.image = UIImage(named: "time_clock_blue_icon")

        }else{
            pickupTimeLabel.textColor = UIColor.black.withAlphaComponent(0.8)
            pickupTimeImage.image = UIImage(named: "clock_grey_new")

        }
        if DateUtils.getExactDifferenceBetweenTwoDatesInMins(time1: taxiRidePassenger.pickupTimeMs, time2: NSDate().getTimeStamp()) < 1{
            pickupTimeLabel.text = "Now"
            return
        }
        if let pickupDay = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.pickupTimeMs, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy), let today = DateUtils.getTimeStringFromTimeInMillis(timeStamp: NSDate().getTimeStamp(), timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy), pickupDay.compare(today) == ComparisonResult.orderedSame, let pickupTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRideEditRouteViewModel.taxiRidePassenger?.pickupTimeMs, timeFormat: DateUtils.TIME_FORMAT_hhmm_a) {
            pickupTimeLabel.text = "Today at " + pickupTime
            return
        }
        pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.pickupTimeMs, timeFormat: DateUtils.DATE_FORMAT_EEE_dd_hh_mm_aaa)
    }




    private func getViaPointsMark(index: Int) -> UIImage{
        let viaPointMark = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
        let seqAlphbat = TaxiUtils.getSequenceAlphabetFor(index: index)
        viaPointMark.initializeView(name: seqAlphbat, colorCode: UIColor(netHex: 0x515151))
        return ViewCustomizationUtils.getImageFromView(view: viaPointMark)
    }

    func reloadViaPoints(){
        if taxiRideEditRouteViewModel.wayPoints.count == 0 {
            viaPointsList.isHidden = true
        }else{
            viaPointsList.isHidden = false
            viaPointsList.delegate = self
            viaPointsList.dataSource = self
            viaPointsList.reloadData()
        }

    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async {
            self.viaPointTableViewHeigh.constant = self.viaPointsList.contentSize.height
        }
    }

    private func updateUIBasedOnEditSession(){
        if taxiRideEditRouteViewModel.isViaPointEditSession(){
            locationsStackView.isHidden = true
            mapViewTopMargin.constant = 0
            viaPointLocationLabel.isHidden = false
            newViaPointView.isHidden = false
            iboDone.isHidden = false
            self.viaPointSelectPin.isHidden = false
            self.iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
            iboDone.backgroundColor = UIColor(netHex: 0x00B557)
            iboDone.isUserInteractionEnabled = true
            if let viaPoint = taxiRideEditRouteViewModel.newViaPoint {

                self.iboMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: viaPoint.latitude, longitude: viaPoint.longitude), zoom: 18))
                viaPointLocationLabel.text = viaPoint.address
            }
        }else{
            locationsStackView.isHidden = false
            viaPointLocationLabel.isHidden = true
            newViaPointView.isHidden = true
            self.viaPointSelectPin.isHidden = true
            mapViewTopMargin.constant = 140
            reloadViaPoints()
            self.iboDone.setTitle(Strings.CONFIRM_ROUTE, for: .normal)
            if taxiRideEditRouteViewModel.rideDetailsChanged(){
                iboDone.backgroundColor = UIColor(netHex: 0x00B557)
                iboDone.isUserInteractionEnabled = true
            }else {
                iboDone.backgroundColor = .lightGray
                iboDone.isUserInteractionEnabled = false
            }
        }
    }

    func validateAndUpdateRide(){

        let saveRouteUtilsInstance = SaveRouteViewUtils()

        if let preferredRoute = taxiRideEditRouteViewModel.userPreferredRoute{

            QuickRideProgressSpinner.startSpinner()
            saveRouteUtilsInstance.saveTaxiEditedRoute(useCase: "IOS.App.CustomRoute.TaxiRideEditView",startLocation: taxiRideEditRouteViewModel.startLocation, endLocation: taxiRideEditRouteViewModel.endLocation, preferredRoute: preferredRoute, viaPointString: taxiRideEditRouteViewModel.wayPoints.toJSONString(), routeName: nil) {[weak self] (route, preferredRoute, responseError, error)  in
                QuickRideProgressSpinner.stopSpinner()
                if preferredRoute != nil {
                    self?.updateRide()
                } else {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }else{
            let saveCustomizedRouteViewController = UIStoryboard(name: StoryBoardIdentifiers.routeSelection_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SaveCustomizedRouteViewController") as! SaveCustomizedRouteViewController
            let suggestedRouteName = taxiRideEditRouteViewModel.getSuggestingNameForRoute(startLocation: taxiRideEditRouteViewModel.startLocation ,endLocation: taxiRideEditRouteViewModel.endLocation, wayPoints: taxiRideEditRouteViewModel.wayPoints)
            saveCustomizedRouteViewController.initializeDataBeforePresenting(suggestedRouteName: suggestedRouteName, handler: { [unowned self] (routeName) in
                QuickRideProgressSpinner.startSpinner()
                saveRouteUtilsInstance.saveTaxiEditedRoute(useCase: "IOS.App.CustomRoute.TaxiRideEditView",startLocation: taxiRideEditRouteViewModel.startLocation, endLocation: taxiRideEditRouteViewModel.endLocation, preferredRoute: nil, viaPointString: self.taxiRideEditRouteViewModel.wayPoints.toJSONString(), routeName: routeName) { [weak self](route, preferredRoute, responseError, error)  in
                    QuickRideProgressSpinner.stopSpinner()
                        if preferredRoute != nil {
                            self?.updateRide()
                        } else {
                            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                        }

                }
            })
            self.navigationController?.view.addSubview(saveCustomizedRouteViewController.view)
            self.navigationController?.addChild(saveCustomizedRouteViewController)
        }
    }
    func updateRide() {
        guard let taxiRidePassenger = taxiRideEditRouteViewModel.taxiRidePassenger else { return  }
        QuickRideProgressSpinner.startSpinner()
        taxiRideEditRouteViewModel.getAvailableVehicleClass() { (fareForVehicleClass) in
            QuickRideProgressSpinner.stopSpinner()
            if let fareVehicleClass = fareForVehicleClass, let newFare = fareVehicleClass.maxTotalFare{

                TaxiUtils.displayFareToConfirm(currentFare: taxiRidePassenger.initialFare!, newFare: newFare) { completed in
                    if completed{
                        QuickRideProgressSpinner.startSpinner()
                        self.taxiRideEditRouteViewModel.updateTaxiTrip(fixedFareId: fareVehicleClass.fixedFareId ?? "") { (result) in
                            QuickRideProgressSpinner.stopSpinner()
                            if result{

                                self.navigationController?.popViewController(animated: false)
                            }
                        }
                    }
                }
            }
        }

    }

    private func showErrorInSaveRoute(message : String){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: message, message2: nil, positiveActnTitle: Strings.recustomize_caps,negativeActionTitle : Strings.continue_text_caps,linkButtonText: nil, viewController: self, handler: { [unowned self] (result) in
            if result == Strings.continue_text_caps{
                self.validateAndUpdateRide()
            }
        })
    }
    private func drawMapElements(){
        iboMapView.clear()
        for marker in wayPointMarkers{
            marker.map = nil
        }
        wayPointMarkers.removeAll()
        startMarker?.map = nil
        endMarker?.map = nil

        prepareStartAndEndMarkers()
        drawAllRoutes()

         let viaPoints = self.taxiRideEditRouteViewModel.wayPoints
            for (index, wayPoint) in viaPoints.enumerated() {
                let pointIcon = getViaPointsMark(index: index)
                let wayPointMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: wayPoint.getCoordinate(), shortIcon: pointIcon, tappable: true, anchor: CGPoint(x: 0.5, y: 0.5))
                wayPointMarkers.append(wayPointMarker)
            }

        reloadViaPoints()


    }
    func drawAllRoutes() {
        for polyline in routePolylines {
            polyline.map = nil
        }

        for route in taxiRideEditRouteViewModel.rideRoutes {
            guard let polyline = route.overviewPolyline, let routeId = route.routeId else { continue }
            if route.routeId == taxiRideEditRouteViewModel.selectedRoute?.routeId{
                drawUserRoute(overViewPolyline: polyline, routeId: routeId )
                displayTimeAndDistanceInfoView(routePathData: route)
            }else{
                let polyline = GoogleMapUtils.drawRoute(pathString: polyline, map: self.iboMapView, colorCode: UIColor(netHex: 0x767676), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
                polyline.userData = routeId
                routePolylines.append(polyline)
            }
        }
    }
    func drawUserRoute(overViewPolyline: String, routeId: Double)
    {
        let selectedPolyLine = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: self.iboMapView, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: true)
        selectedPolyLine.userData = routeId
        routePolylines.append(selectedPolyLine)
        let polyline = GoogleMapUtils.drawRoute(pathString: overViewPolyline, map: self.iboMapView, colorCode: UIColor(netHex: 0x005BA4), width: GoogleMapUtils.POLYLINE_WIDTH_10, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: true)
        routePolylines.append(polyline)
        GoogleMapUtils.fitToScreen(route: overViewPolyline, map: self.iboMapView)
    }
    func prepareStartAndEndMarkers(){
        self.startMarker?.map = nil
        self.endMarker?.map = nil
        guard let start = taxiRideEditRouteViewModel.startLocation, let end = taxiRideEditRouteViewModel.endLocation else { return  }
        self.startMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: CLLocationCoordinate2D(latitude: start.latitude, longitude: start.longitude), shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        self.startMarker?.zIndex = 12

        self.endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView, location: CLLocationCoordinate2D(latitude: end.latitude ,longitude : end.longitude), shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        self.endMarker?.zIndex = 12
    }

    var routeDistanceMarker : GMSMarker?
     func displayTimeAndDistanceInfoView(routePathData : RideRoute){
         let noOfTolls = taxiRideEditRouteViewModel.getNoOfTolls()
         if noOfTolls > 0 {
             let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "TaxiEditDistancewithTollsInfoMarker") as! TaxiEditDistancewithTollsInfoMarker
              routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!,duration : routePathData.duration,noOfTolls: noOfTolls)
             routeTimeAndChangeRouteInfoView.addShadow()
              ViewCustomizationUtils.addCornerRadiusToView(view: routeTimeAndChangeRouteInfoView, cornerRadius: 3)
             let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView)
             let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
              routeDistanceMarker?.map = nil
             if path != nil && path!.count() != 0{
                 routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: self.iboMapView, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
             }
         }else{
             let routeTimeAndChangeRouteInfoView = UIView.loadFromNibNamed(nibNamed: "TaxiEditDistanceInfoMarkerView") as! TaxiEditDistanceInfoMarkerView
              routeTimeAndChangeRouteInfoView.initializeView(distance: routePathData.distance!,duration : routePathData.duration)
             routeTimeAndChangeRouteInfoView.addShadow()
              ViewCustomizationUtils.addCornerRadiusToView(view: routeTimeAndChangeRouteInfoView, cornerRadius: 3)
             let icon = ViewCustomizationUtils.getImageFromView(view: routeTimeAndChangeRouteInfoView)
             let path = GMSPath(fromEncodedPath: routePathData.overviewPolyline!)
              routeDistanceMarker?.map = nil
             if path != nil && path!.count() != 0{
                 routeDistanceMarker = GoogleMapUtils.addMarker(googleMap: self.iboMapView, location: path!.coordinate(at: path!.count()/3), shortIcon: icon, tappable: true, anchor: CGPoint(x: 1, y: 1),zIndex: GoogleMapUtils.Z_INDEX_10)
             }
         }


    }
}

extension TaxiRideEditViewController:  UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taxiRideEditRouteViewModel.wayPoints.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxiEditViaPointTableViewCell") as! TaxiEditViaPointTableViewCell
        if taxiRideEditRouteViewModel.wayPoints.endIndex <= indexPath.row{
            return cell
        }
        let index = indexPath.row
        let viaPoint = taxiRideEditRouteViewModel.wayPoints[indexPath.row]
        cell.setUpUI(viaPoint: viaPoint, index: index)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        taxiRideEditRouteViewModel.viaPointSelected(index: indexPath.row)
        updateUIBasedOnEditSession()
    }

}

extension TaxiRideEditViewController : GMSMapViewDelegate{

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

        if !taxiRideEditRouteViewModel.isViaPointEditSession(){
            return
        }
        iboDone.setTitle(Strings.CONFIRM_VIA_POINT, for: .normal)
        if mapView.camera.zoom < 18 {
            viaPointZoomLevelWarningView.isHidden = false
            loopsErrorView.isHidden = true
            iboDone.backgroundColor = UIColor(netHex: 0xC9C9C9)
            iboDone.isEnabled = false
            return
        }
        viaPointZoomLevelWarningView.isHidden = true

        iboDone.backgroundColor = UIColor(netHex: 0x00B557)
        iboDone.isEnabled = true
        if let found = taxiRideEditRouteViewModel.newViaPoint{
           let distance = CLLocation(latitude: found.latitude, longitude: found.longitude).distance(from: CLLocation(latitude: position.target.latitude, longitude: position.target.longitude))
            if distance <= 0.015, let address = taxiRideEditRouteViewModel.newViaPoint?.completeAddress {
                self.viaPointLocationLabel.text = address
                return
            }
            if distance <= 0.015, let address = taxiRideEditRouteViewModel.newViaPoint?.shortAddress{
                self.viaPointLocationLabel.text = address
                return
            }
        }
        taxiRideEditRouteViewModel.handleViaPointSelection(viaPoint: mapView.camera.target) { [weak self] location in
            if let address = location.completeAddress {
                self?.viaPointLocationLabel.text = address
            }else if let address = location.shortAddress {
                self?.viaPointLocationLabel.text = address
            }else{
                self?.viaPointLocationLabel.text = "\(location.latitude), \(location.longitude)"
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        AppDelegate.getAppDelegate().log.debug("didTapOverlay")
        guard let polyline = overlay as? GMSPolyline,let routeId = polyline.userData as? Double else{
            return
        }
        if taxiRideEditRouteViewModel.taxiRidePassenger?.routeId == routeId{
            return
        }
        taxiRideEditRouteViewModel.taxiRidePassenger?.routeId = routeId
        drawMapElements()
        updateUIBasedOnEditSession()
    }

}

extension TaxiRideEditViewController : ReceiveLocationDelegate{
    func receiveSelectedLocation(location : Location,requestLocationType : String){


        if requestLocationType == ChangeLocationViewController.ORIGIN{
            if let drop = taxiRideEditRouteViewModel.endLocation, LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: drop.latitude, toLongitude: drop.longitude) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES {
                UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                return
            }
            taxiRideEditRouteViewModel.updateStartLocation(location: location)
            fromLocationLbl.text = taxiRideEditRouteViewModel.startLocation?.address
            taxiRideEditRouteViewModel.getRoutes()

        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            if let pickup = taxiRideEditRouteViewModel.startLocation, LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: pickup.latitude, toLongitude: pickup.longitude) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES {
                UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
                return
            }
            taxiRideEditRouteViewModel.updateEndLocation(location: location)
            toLocationLbl.text = taxiRideEditRouteViewModel.endLocation?.address
            taxiRideEditRouteViewModel.getRoutes()
        }else{
            self.taxiRideEditRouteViewModel.newViaPoint = location
            if let address = location.completeAddress {
                self.taxiRideEditRouteViewModel.newViaPoint?.address = address
            }else{
                self.taxiRideEditRouteViewModel.newViaPoint?.address = location.shortAddress
            }

        }
        updateUIBasedOnEditSession()

    }

    func locationSelectionCancelled(requestLocationType : String){
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
    }
}
// MARK: Time Delegate
extension TaxiRideEditViewController: SelectDateDelegate {
    func getTime(date: Double) {
        AppDelegate.getAppDelegate().log.debug("getTime")
        taxiRideEditRouteViewModel.taxiRidePassenger?.pickupTimeMs = date*1000
        showTime()
        taxiRideEditRouteViewModel.getRoutes()
        updateUIBasedOnEditSession()
    }
}
// MARK: Notifications
extension TaxiRideEditViewController {
    func registerUpdateNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRoute(_:)), name: .routeReceived ,object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(routeContainLoops(_:)), name: .routeContainLoops ,object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError(_:)), name: .handleApiFailureError, object: taxiRideEditRouteViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(viaPointsChanged(_:)), name: .viaPointsChanged, object: nil)
    }
    @objc func receiveRoute(_ notification:Notification) {
        AppDelegate.getAppDelegate().log.debug()
        QuickRideProgressSpinner.stopSpinner()
        drawMapElements()
        updateUIBasedOnEditSession()
    }
    
    @objc func routeContainLoops(_ notification:Notification) {
        AppDelegate.getAppDelegate().log.debug()
        QuickRideProgressSpinner.stopSpinner()
        iboMapView.clear()
        wayPointMarkers.removeAll()
        if let startLocation = taxiRideEditRouteViewModel.startLocation {
            let start =  CLLocationCoordinate2D(latitude: startLocation.latitude,longitude: startLocation.longitude)
            startMarker =  GoogleMapUtils.addMarker(googleMap: iboMapView,location: start, shortIcon: startIcon, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        }
        if let endLocation = taxiRideEditRouteViewModel.endLocation {
            let end = CLLocationCoordinate2D(latitude: endLocation.latitude,longitude: endLocation.longitude)
            endMarker = GoogleMapUtils.addMarker(googleMap: iboMapView,location: end, shortIcon: endIcon, tappable: false, anchor: CGPoint(x: 0.8, y: 0.8))
        }
        
        if let route = notification.userInfo?["route"] as? RideRoute {
            GoogleMapUtils.drawRoute(pathString: route.overviewPolyline!,map: iboMapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10,tappable: true)
        }
        
        loopsErrorView.isHidden = false
    }

    @objc func handleApiFailureError(_ notification : NSNotification){
        QuickRideProgressSpinner.stopSpinner()
        let responseError = notification.userInfo?["responseError"] as? ResponseError
        let error = notification.userInfo?["nsError"] as? NSError
        ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)

    }
    @objc func viaPointsChanged(_ notification : NSNotification){
        if let index = notification.userInfo?["index"] as? Int{
            taxiRideEditRouteViewModel.viaPointRemoved(index: index)
        }
    }
}
