//
//  TaxiPoolPassengerDetailsInviteViewController.swift
//  Quickride
//
//  Created by Ashutos on 9/15/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
import Polyline

class TaxiPoolPassengerDetailsInviteViewController: UIViewController {
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var matchedPassengerTableView: UITableView!
    
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    private var backGroundView: UIView?
    private var participantPickupIconMarker: GMSMarker?
    private var participantDropIconMarker: GMSMarker?
    private var taxiRideDetailsForInviteViewModel: TaxiRideDetailsForInViteViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        registerCell()
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 40)
        viewMap.delegate = self
        drawRouteOnMap()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        getInvitedList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func dataBeforePresent(selectedIndex: Int,matchedPassengerRide: [MatchedPassenger],taxiShareRide: TaxiShareRide,ride: Ride? ,allInvitedUsers: [TaxiInviteEntity]?) {
        taxiRideDetailsForInviteViewModel = TaxiRideDetailsForInViteViewModel(selectedIndex: selectedIndex, matchedPassengerRide: matchedPassengerRide, taxiShareRide: taxiShareRide, ride: ride, allInvitedUsers: allInvitedUsers)
    }
    
    private func getInvitedList() {
        taxiRideDetailsForInviteViewModel?.getInvitedList(completionHandler: { [weak self] (result) in
            self?.matchedPassengerTableView.reloadData()
        })
    }
    
    private func registerCell() {
        matchedPassengerTableView.register(UINib(nibName: "InviteTableViewCell", bundle: nil), forCellReuseIdentifier: "InviteTableViewCell")
    }
    
    private func drawRouteOnMap() {
        if viewMap == nil{
            return
        }
        viewMap.clear()
        drawTaxiRoute()
        setPickUpAndDrop()
    }
    
    private func drawTaxiRoute() {
        if viewMap == nil{
            return
        }
        var polyline = ""
        let matchedPassenger = taxiRideDetailsForInviteViewModel?.matchedPassengerRide[taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0]
        if  let matchedTaxiRoutePathPolyline = matchedPassenger?.routePolyline, viewMap != nil {
            let route = Polyline(encodedPolyline: matchedTaxiRoutePathPolyline)
            if (route.coordinates?.count)! < 2{
                return
            }
            polyline = matchedTaxiRoutePathPolyline
        }
        GoogleMapUtils.drawRoute(pathString: taxiRideDetailsForInviteViewModel?.taxiShareRide?.routePathPolyline ?? "", map: viewMap, colorCode: UIColor(netHex:0x000000), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        GoogleMapUtils.drawRoute(pathString: polyline, map: viewMap, colorCode: UIColor(netHex:0x2196F3), width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_7, tappable: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            GoogleMapUtils.fitToScreen(route: polyline, map : self.viewMap)
        }
    }
    
   private func setPickUpAndDrop() {
        let matchedPassengerData = taxiRideDetailsForInviteViewModel?.matchedPassengerRide[taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0]
        if matchedPassengerData?.pickupLocationAddress != nil {
            let pickUp = CLLocationCoordinate2D(latitude: matchedPassengerData?.pickupLocationLatitude ?? 0.0, longitude: matchedPassengerData?.pickupLocationLongitude ?? 0.0)
            self.setPickUpMarker(pickUp: pickUp, zoomState: TaxiRideDetailsForInViteViewModel.ZOOMED_OUT)
        }
        
        if matchedPassengerData?.dropLocationAddress != nil {
            let drop = CLLocationCoordinate2D(latitude: matchedPassengerData?.dropLocationLatitude ?? 0.0, longitude: matchedPassengerData?.dropLocationLongitude ?? 0.0)
            self.setDropMarker(drop: drop, zoomState: TaxiRideDetailsForInViteViewModel.ZOOMED_OUT)
        }

    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
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
}

 extension TaxiPoolPassengerDetailsInviteViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let matchedPassenger = taxiRideDetailsForInviteViewModel?.matchedPassengerRide[taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0]
        if marker.title == Strings.pick_up_caps {
            if taxiRideDetailsForInviteViewModel?.pickupZoomState == TaxiPoolRideDetailsViewModel.ZOOMED_IN {
                taxiRideDetailsForInviteViewModel?.pickupZoomState = TaxiRideDetailsForInViteViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                let pickUp = CLLocationCoordinate2D(latitude: matchedPassenger?.pickupLocationLatitude ?? 0.0, longitude: matchedPassenger?.pickupLocationLongitude ?? 0.0)
                setPickUpMarker(pickUp: pickUp, zoomState: TaxiRideDetailsForInViteViewModel.ZOOMED_OUT)
            } else {
                taxiRideDetailsForInviteViewModel?.pickUpOrDropNavigation = Strings.pick_up_caps
                taxiRideDetailsForInviteViewModel?.pickupZoomState = TaxiRideDetailsForInViteViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedPassenger?.pickupLocationLatitude ?? 0.0, longitude: matchedPassenger?.pickupLocationLongitude ?? 0.0)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.pick_up_caps)
                let pickUp = CLLocationCoordinate2D(latitude: matchedPassenger?.pickupLocationLatitude ?? 0.0, longitude: matchedPassenger?.pickupLocationLongitude ?? 0.0)
                setPickUpMarker(pickUp: pickUp, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_IN)
            }
        }
        
        if marker.title == Strings.drop_caps {
            if taxiRideDetailsForInviteViewModel?.dropZoomState == TaxiRideDetailsForInViteViewModel.ZOOMED_IN {
                taxiRideDetailsForInviteViewModel?.dropZoomState = TaxiPoolRideDetailsViewModel.ZOOMED_OUT
                zoomOutToSelectedPoint()
                let drop = CLLocationCoordinate2D(latitude: matchedPassenger?.dropLocationLatitude ?? 0.0 , longitude: matchedPassenger?.dropLocationLongitude ?? 0.0)
                setDropMarker(drop: drop, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_OUT)
            } else {
                taxiRideDetailsForInviteViewModel?.pickUpOrDropNavigation = Strings.drop_caps
                taxiRideDetailsForInviteViewModel?.dropZoomState = TaxiPoolRideDetailsViewModel.ZOOMED_IN
                let zoomPoint = CLLocationCoordinate2D(latitude: matchedPassenger?.dropLocationLatitude ?? 0.0, longitude: matchedPassenger?.dropLocationLongitude ?? 0.0)
                zoomInToSelectedPoint(zoomPoint: zoomPoint, markerType: Strings.drop_caps)
                let drop = CLLocationCoordinate2D(latitude: matchedPassenger?.dropLocationLatitude ?? 0.0, longitude: matchedPassenger?.dropLocationLongitude ?? 0.0)
                setDropMarker(drop: drop, zoomState: TaxiPoolRideDetailsViewModel.ZOOMED_IN)
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
        let bounds = GMSCoordinateBounds(path: GMSPath(fromEncodedPath: taxiRideDetailsForInviteViewModel?.matchedPassengerRide[taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0].routePolyline ?? "")!)
        
        let uiEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.viewMap.animate(with: GMSCameraUpdate.fit(bounds, with: uiEdgeInsets))
        CATransaction.commit()
    }
}

//SwipeGesture
extension TaxiPoolPassengerDetailsInviteViewController {
    
    func checkAndAddRideDetailViewSwipeGesture(cell: InviteTableViewCell) {
       
        if taxiRideDetailsForInviteViewModel?.matchedPassengerRide.count ?? 0 > 1 {
                cell.backGroundView.isUserInteractionEnabled = true
                backGroundView = cell.backGroundView
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                leftSwipe.direction = .left
                backGroundView!.addGestureRecognizer(leftSwipe)
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
                rightSwipe.direction = .right
                backGroundView!.addGestureRecognizer(rightSwipe)
            }else{
                cell.leftView.isHidden = true
                cell.rightView.isHidden = true
            }
            if taxiRideDetailsForInviteViewModel?.selectedIndex == 0{
                cell.leftView.isHidden = true
                
            }else{
                cell.leftView.isHidden = false
            }
        if taxiRideDetailsForInviteViewModel?.selectedIndex == (taxiRideDetailsForInviteViewModel?.matchedPassengerRide.count ?? 0) - 1 {
                cell.rightView.isHidden = true
            }else{
                cell.rightView.isHidden = false
            }
    }
    
    @objc func swiped(_ gesture : UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            
            if taxiRideDetailsForInviteViewModel?.selectedIndex != (taxiRideDetailsForInviteViewModel?.matchedPassengerRide.count ?? 0) - 1{
                backGroundView!.slideInFromRight(duration: 0.5, completionDelegate: nil)
            }
        }else if gesture.direction == .right {
            
            if taxiRideDetailsForInviteViewModel?.selectedIndex != 0 {
                backGroundView!.slideInFromLeft(duration: 0.5, completionDelegate: nil)
            }
        }
        if gesture.direction == .left {
            taxiRideDetailsForInviteViewModel?.selectedIndex += 1
            if (taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0) > (taxiRideDetailsForInviteViewModel?.matchedPassengerRide.count ?? 0) - 1 {
                taxiRideDetailsForInviteViewModel?.selectedIndex = (taxiRideDetailsForInviteViewModel?.matchedPassengerRide.count ?? 0) - 1
            }
        }else if gesture.direction == .right {
            taxiRideDetailsForInviteViewModel?.selectedIndex -= 1
            if taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0 < 0 {
                taxiRideDetailsForInviteViewModel?.selectedIndex = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.matchedPassengerTableView.reloadData()
            self.drawRouteOnMap()
        })
    }
}

extension TaxiPoolPassengerDetailsInviteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell", for: indexPath) as! InviteTableViewCell
        cell.setUpUIWithData(data: self.taxiRideDetailsForInviteViewModel?.matchedPassengerRide[taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0], ride: self.taxiRideDetailsForInviteViewModel?.ride, row: taxiRideDetailsForInviteViewModel?.selectedIndex ?? 0, allInvites: taxiRideDetailsForInviteViewModel?.allInvitedUsers)
        checkAndAddRideDetailViewSwipeGesture(cell: cell)
        cell.contentView.backgroundColor = .clear
        return cell
    }
}
