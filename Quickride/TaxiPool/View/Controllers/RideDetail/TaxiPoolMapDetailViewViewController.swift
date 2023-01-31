//
//  TaxiPoolMapDetailViewViewController.swift
//  Quickride
//
//  Created by Ashutos on 5/17/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import Polyline
import FloatingPanel

class TaxiPoolMapDetailViewViewController: UIViewController {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var downArrowBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitLeLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var numberShowingView: UIView!
    @IBOutlet weak var numberShowingLabel: UILabel!
    
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    private var vehicleMarker : GMSMarker!
    private var rideParticipantMarkers = [Double : RideParticipantElements]()
    var participantPickupIconMarker: GMSMarker?
    var participantDropIconMarker: GMSMarker?
    private var floatingPanelController: FloatingPanelController!
    private var taxiPoolRideDetailViewController: TaxiPoolRideDetailViewController!
    
    private var taxiPoolDetailViewModel = TaxiPoolRideDetailsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 40)
        viewMap.delegate = self
        
        if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                setDataToView(status: true)
            addTaxiPoolRideDetailViewController(status: 0)
        } else {
            self.addTaxiPoolRideDetailViewController(status: 1)
            if taxiPoolDetailViewModel.ride == nil {
                setDataToView(status: false)
            }else{
                setDataToView(status: false)
                taxiPoolDetailViewModel.getTaxiRideDetails(completionHandler: { [weak self] result in
                    self?.setDataToView(status: false)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        isPanelTopNotchVisiable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func getDataForTheSharedTaxi(selectedIndex: Int?, matchedShareTaxis: [MatchedShareTaxi]?,ride: Ride?,analyticNotificationHandlerModel: AnalyticNotificationHandlerModel?,taxiInviteData: TaxiInviteEntity?) {
        taxiPoolDetailViewModel.initliseData(selectedIndex: selectedIndex, matchedShareTaxi: matchedShareTaxis, ride: ride, analyticNotificationHandlerModel: analyticNotificationHandlerModel, taxiInviteEntity: taxiInviteData)
    }
        
    @IBAction func downBtnPressed(_ sender: UIButton) {
        floatingPanelController.move(to: .half, animated: true)
        self.numberShowingView.isHidden = false
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func setDataToView(status: Bool) {
        if status {
            let pageNumber = String(taxiPoolDetailViewModel.selectedIndex + 1) + "/" + String(taxiPoolDetailViewModel.matchedShareTaxi.count)
            numberShowingLabel.text = pageNumber
            numberShowingLabel.isHidden = false
        } else{
            numberShowingLabel.isHidden = true
        }
        drawRouteOnMap()
        setHeaderTitle()
        setRideParticipentMarker()
    }
    
    func setPickUpAndDrop() {
        if taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
            var pickUp: CLLocationCoordinate2D?
            var drop: CLLocationCoordinate2D?
            if taxiPoolDetailViewModel.ride == nil {
             pickUp = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLng ?? 0.0)
             drop = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLng ?? 0.0)
            
            } else {
                pickUp = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.ride?.startLatitude ?? 0.0, longitude: taxiPoolDetailViewModel.ride?.startLongitude ?? 0.0)
                 drop = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.ride?.endLatitude ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLng ?? 0.0)
            }
            self.setPickUpMarker(pickUp: pickUp!, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
            self.setDropMarker(drop: drop!, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
        } else{
            let matchedTaxi = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
            if matchedTaxi.pickUpAddress != nil {
                let pickUp = CLLocationCoordinate2D(latitude: matchedTaxi.pickUpLatitude!, longitude: matchedTaxi.pickUpLongitude!)
                self.setPickUpMarker(pickUp: pickUp, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
            }
            if matchedTaxi.dropAddress != nil {
                let drop = CLLocationCoordinate2D(latitude: matchedTaxi.dropLatitude!, longitude: matchedTaxi.dropLongitude!)
                self.setDropMarker(drop: drop, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
            }
        }
    }
    
    private func setHeaderTitle() {
        titleLabel.text =  Strings.taxi_details
        subTitLeLabel.text = ""
    }
    
    private func drawRouteOnMap() {
        if viewMap == nil{return}
        viewMap.clear()
        taxiPoolDetailViewModel.isOverlappingRouteDrawn = false
        drawMatchedTaxiRoute()
        setPickUpAndDrop()
    }
    
    private func drawMatchedTaxiRoute() {
        var polyline = ""
        if taxiPoolDetailViewModel.matchedShareTaxi.count != 0  {
            let matchedTaxi = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
            if  let matchedTaxiRoutePathPolyline = matchedTaxi.routePolyline, viewMap != nil {
                let route = Polyline(encodedPolyline: matchedTaxiRoutePathPolyline)
                if (route.coordinates?.count)! < 2{
                    return
                }
                polyline = matchedTaxiRoutePathPolyline
            }
        }else{
            if taxiPoolDetailViewModel.taxiInviteEntity != nil {
                let overallPolyLine = taxiPoolDetailViewModel.taxiInviteEntity?.overviewPolyLine ?? ""
                GoogleMapUtils.drawRoute(pathString: overallPolyLine, map: viewMap, colorCode: UIColor(netHex:0x000000), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
            }
            if taxiPoolDetailViewModel.ride != nil {
                polyline = taxiPoolDetailViewModel.ride?.routePathPolyline ?? ""
            } else {
                polyline = taxiPoolDetailViewModel.analyticNotificationHandlerModel?.routepathPolyline ?? ""
            }
        }
        GoogleMapUtils.drawRoute(pathString: polyline, map: viewMap, colorCode: UIColor(netHex:0x2196F3), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            GoogleMapUtils.fitToScreen(route: polyline, map : self.viewMap)
        }
    }
    
    private func setPickUpMarker(pickUp : CLLocationCoordinate2D, zoomState: String) {
        pickUpMarker?.map = nil
        pickUpMarker = nil
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.pick_up_caps, markerImage: UIImage(named: "green")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: pickUp, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.18, y: 0.25))
        pickUpMarker?.zIndex = 8
        pickUpMarker?.title = Strings.pick_up_caps
    }
    
    private func setDropMarker(drop : CLLocationCoordinate2D, zoomState: String) {
        dropMarker?.map = nil
        dropMarker = nil
        let pickDropView = UIView.loadFromNibNamed(nibNamed: "LocationInfoView") as! LocationInfoView
        pickDropView.initializeViews(markerTitle: Strings.drop_caps, markerImage: UIImage(named: "drop_icon")!, zoomState: zoomState)
        let icon = ViewCustomizationUtils.getImageFromView(view: pickDropView)
        dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: drop, shortIcon: icon,tappable: true,anchor :CGPoint(x: 0.25, y: 0.25))
        dropMarker?.zIndex = 8
        dropMarker?.title = Strings.drop_caps
    }
    
    private func setRideParticipentMarker() {
        if taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
            return
        }
        guard let matchedTaxiUser = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex].taxiShareRidePassengerInfos else {
            return
        }
        for rideParticipant in matchedTaxiUser {
            checkParticipantStatusAndDisplayMarker(rideParticipant: rideParticipant)
        }
    }
    
    private func checkParticipantStatusAndDisplayMarker(rideParticipant : TaxiShareRidePassengerInfos) {
        var participantMarkerElement = rideParticipantMarkers[rideParticipant.id ?? 0]
        //MARK: PickUPMarker
        let participantPickupPoint = CLLocationCoordinate2D(latitude: rideParticipant.pickUpLatitude!,longitude: rideParticipant.pickUpLongitude!)
        self.participantPickupIconMarker = nil
        self.participantPickupIconMarker?.map = nil
        let participantPickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: participantPickupPoint)
        let participantPickUpImageView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
        participantPickUpImageView.initializeView(name: rideParticipant.passengerName!, colorCode: UIColor(netHex: 0x656766))
        let icon = ViewCustomizationUtils.getImageFromView(view: participantPickUpImageView)
        participantPickUpMarker.icon = icon
        participantPickUpMarker.zIndex = 12
        participantPickUpMarker.title = StringUtils.getStringFromDouble(decimalNumber : rideParticipant.id)
        participantPickUpMarker.isTappable = true
        participantPickUpMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
        self.participantPickupIconMarker = participantPickUpMarker
        self.participantPickupIconMarker?.map = viewMap
        let participantDropPoint = CLLocationCoordinate2D(latitude: rideParticipant.dropLatitude!,longitude: rideParticipant.dropLongitude!)
        //MARK: DropMarker
        self.participantDropIconMarker = nil
        self.participantDropIconMarker?.map = nil
        let participantDropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: participantDropPoint)
        let participantDropImageView = UIView.loadFromNibNamed(nibNamed: "RideParticipantMarkerView") as! RideParticipantMarkerView
        participantDropImageView.initializeView(name: rideParticipant.passengerName!, colorCode: UIColor(netHex: 0xE20000))
        let dropIcon = ViewCustomizationUtils.getImageFromView(view: participantDropImageView)
        participantDropMarker.icon = dropIcon
        participantDropMarker.zIndex = 12
        participantDropMarker.title = StringUtils.getStringFromDouble(decimalNumber : rideParticipant.id)
        participantPickUpMarker.isTappable = true
        participantPickUpMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.4)
        self.participantDropIconMarker = participantDropMarker
        self.participantDropIconMarker?.map = viewMap
    }
}

extension TaxiPoolMapDetailViewViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            //  currentLocationButton.isHidden = false
        } else {
            // currentLocationButton.isHidden = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.title == Strings.pick_up_caps {
            if taxiPoolDetailViewModel.pickupZoomState == TaxiPoolRideDetailsViewModel.ZOOMED_IN {
                taxiPoolDetailViewModel.pickupZoomState = TaxiPoolRideDetailsViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                var pickUp: CLLocationCoordinate2D?
                if taxiPoolDetailViewModel.analyticNotificationHandlerModel == nil {
                    let matchedTaxiUser = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
                    pickUp = CLLocationCoordinate2D(latitude: matchedTaxiUser.pickUpLatitude!, longitude: matchedTaxiUser.pickUpLongitude!)
                }else{
                    if let ride = taxiPoolDetailViewModel.ride{
                        pickUp = CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude)
                    }else{
                        pickUp = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLng ?? 0.0)
                    }
                }
                
                if let pickup = pickUp {
                    setPickUpMarker(pickUp: pickup, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
                }
            } else {
                taxiPoolDetailViewModel.pickUpOrDropNavigation = Strings.pick_up_caps
                taxiPoolDetailViewModel.pickupZoomState = RideDetailMapViewModel.ZOOMED_IN
                var pickUp: CLLocationCoordinate2D?
                if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                    let matchedTaxiUser = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
                    pickUp = CLLocationCoordinate2D(latitude: matchedTaxiUser.pickUpLatitude!, longitude: matchedTaxiUser.pickUpLongitude!)
                }else{
                    if let ride = taxiPoolDetailViewModel.ride {
                        pickUp = CLLocationCoordinate2D(latitude: ride.startLatitude, longitude: ride.startLongitude)
                    }else{
                        pickUp = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.fromLng ?? 0.0)
                    }
                }
                if let pickUpData = pickUp {
                    zoomInToSelectedPoint(zoomPoint: pickUpData, markerType: Strings.pick_up_caps)
                    setPickUpMarker(pickUp: pickUpData, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_IN)
                }
            }
        }
        
        if marker.title == Strings.drop_caps {
            if taxiPoolDetailViewModel.dropZoomState == TaxiPoolRideDetailsViewModel.ZOOMED_IN {
                taxiPoolDetailViewModel.dropZoomState = TaxiPoolRideDetailsViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                var drop: CLLocationCoordinate2D?
                if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                    let matchedTaxiUser = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
                    drop = CLLocationCoordinate2D(latitude: matchedTaxiUser.dropLongitude!, longitude: matchedTaxiUser.dropLatitude!)
                }else{
                    if let ride = taxiPoolDetailViewModel.ride {
                        drop = CLLocationCoordinate2D(latitude: ride.endLatitude ?? 0.0, longitude: ride.endLongitude ?? 0.0)
                    }else{
                        drop = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLng ?? 0.0)
                    }
                }
                if let dropLocation = drop{
                    setDropMarker(drop: dropLocation, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
                }
            } else {
                taxiPoolDetailViewModel.pickUpOrDropNavigation = Strings.drop_caps
                taxiPoolDetailViewModel.dropZoomState = TaxiPoolRideDetailsViewModel.ZOOMED_IN
                var dropLocation: CLLocationCoordinate2D?
                if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
                    let matchedTaxiUser = taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex]
                    dropLocation = CLLocationCoordinate2D(latitude: matchedTaxiUser.dropLatitude!, longitude: matchedTaxiUser.dropLongitude!)
                }else{
                    if let ride = taxiPoolDetailViewModel.ride {
                        dropLocation = CLLocationCoordinate2D(latitude: ride.endLatitude ?? 0.0, longitude: ride.endLongitude ?? 0.0)
                    }else {
                        dropLocation = CLLocationCoordinate2D(latitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLat ?? 0.0, longitude: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.toLng ?? 0.0)
                    }
                }
                if let dropLocation = dropLocation {
                    zoomInToSelectedPoint(zoomPoint: dropLocation, markerType: Strings.drop_caps)
                    setDropMarker(drop: dropLocation, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_IN)
                }
            }
        }
        return true
    }
    
    private func zoomInToSelectedPoint(zoomPoint: CLLocationCoordinate2D, markerType: String) {
            let cameraPosition = GMSCameraPosition.camera(withTarget: zoomPoint, zoom: 16.0)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            self.viewMap.animate(to: cameraPosition)
            CATransaction.commit()
    }
    
    private func zoomOutToSelectedPoint() {
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        if !taxiPoolDetailViewModel.matchedShareTaxi.isEmpty {
            let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: taxiPoolDetailViewModel.matchedShareTaxi[taxiPoolDetailViewModel.selectedIndex].routePolyline!)!)
            self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        }else{
            if let ride = taxiPoolDetailViewModel.ride {
                let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: ride.routePathPolyline)!)
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            }else{
                let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: taxiPoolDetailViewModel.analyticNotificationHandlerModel?.routepathPolyline ?? "")!)
                self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
            }
        }
        CATransaction.commit()
    }
}

//MARK: MatchedTaxiDataChange Delegate From RideDetailVC
extension TaxiPoolMapDetailViewViewController: TaxiPoolRideDetailViewControllerDelegate {
    func selectedIndexChanged(selectedIndex: Int) {
        taxiPoolDetailViewModel.selectedIndex = selectedIndex
        setDataToView(status: true)
    }
}

extension TaxiPoolMapDetailViewViewController: FloatingPanelControllerDelegate{
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return TaxiPoolFloatingPanelLayout()
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .full {
                            self.floatingPanelController.surfaceView.cornerRadius = 0.0
                            self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
                            self.floatingPanelController.backdropView.isHidden = true
                            self.floatingPanelController.surfaceView.shadowHidden = true
                            //MARK: Our UI components
                            self.downArrowBtn.isHidden = false
                            self.numberShowingView.isHidden = true
                            self.closeBtn.isHidden = true
                            self.titleLabel.text = Strings.taxipool_details
                            if self.taxiPoolDetailViewModel.analyticNotificationHandlerModel == nil && self.taxiPoolDetailViewModel.taxiInviteEntity == nil {
                                self.subTitLeLabel.text = String(self.taxiPoolDetailViewModel.selectedIndex + 1) + "/" + String(self.taxiPoolDetailViewModel.matchedShareTaxi.count)
                            }else{
                                self.setHeaderTitle()
                                self.downArrowBtn.isHidden = true
                                self.closeBtn.isHidden = false
                            }
                            self.taxiPoolRideDetailViewController.taxiRideDetailsTableView.isScrollEnabled = true
                        }else{
                            if #available(iOS 11, *) {
                                self.floatingPanelController.surfaceView.cornerRadius = 20.0
                            } else {
                                self.floatingPanelController.surfaceView.cornerRadius = 0.0
                            }
                            self.isPanelTopNotchVisiable()
                            self.floatingPanelController.backdropView.isHidden = false
                            self.floatingPanelController.surfaceView.shadowHidden = false
                            self.setHeaderTitle()
                            self.numberShowingView.isHidden = false
                            self.downArrowBtn.isHidden = true
                            self.closeBtn.isHidden = false
                            self.taxiPoolRideDetailViewController.taxiRideDetailsTableView.isScrollEnabled = true
                        }
                        self.taxiPoolRideDetailViewController.floatingLabelPositionChanged(position: targetPosition)
                       }, completion: nil)
    }
    
    private func isPanelTopNotchVisiable() {
        if self.taxiPoolDetailViewModel.analyticNotificationHandlerModel != nil || self.taxiPoolDetailViewModel.taxiInviteEntity != nil {
            self.floatingPanelController.surfaceView.grabberHandle.isHidden = false
        }else{
            self.floatingPanelController.surfaceView.grabberHandle.isHidden = true
        }
    }
}

extension TaxiPoolMapDetailViewViewController {
    private func addTaxiPoolRideDetailViewController(status: Int) {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self
        // Initialize FloatingPanelController and add the view
        if status == 1{
            floatingPanelController.surfaceView.backgroundColor = .white
        }else{
            floatingPanelController.surfaceView.backgroundColor = .clear
        }
        if #available(iOS 11, *) {
            floatingPanelController.surfaceView.cornerRadius = 20.0
        } else {
            floatingPanelController.surfaceView.cornerRadius = 0.0
        }
        floatingPanelController.surfaceView.shadowHidden = false
        floatingPanelController.surfaceView.grabberTopPadding = 10
        taxiPoolRideDetailViewController = storyboard?.instantiateViewController(withIdentifier: "TaxiPoolRideDetailViewController") as? TaxiPoolRideDetailViewController
        taxiPoolRideDetailViewController.getDataForTheSharedTaxi(selectedIndex: taxiPoolDetailViewModel.selectedIndex, matchedShareTaxis: taxiPoolDetailViewModel.matchedShareTaxi, ride: taxiPoolDetailViewModel.ride, delegate: self, analyticNotificationHandlerModel: taxiPoolDetailViewModel.analyticNotificationHandlerModel, taxiInviteData: taxiPoolDetailViewModel.taxiInviteEntity)
        // Set a content view controller
        floatingPanelController.set(contentViewController: taxiPoolRideDetailViewController)
        floatingPanelController.track(scrollView: taxiPoolRideDetailViewController.taxiRideDetailsTableView)
        floatingPanelController.addPanel(toParent: self, animated: true)
    }
}

class TaxiPoolFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 50.0 // A top inset from safe area
        case .half: return 250 // A bottom inset from the safe area
        case .tip: return 249 // A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}
