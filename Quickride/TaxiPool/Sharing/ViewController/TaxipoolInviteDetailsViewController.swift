//
//  TaxipoolInviteDetailsViewController.swift
//  Quickride
//
//  Created by HK on 20/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
import GoogleMaps
import FloatingPanel

class TaxipoolInviteDetailsViewController: UIViewController, GMSMapViewDelegate {
    
    //MARK: Oultes
    @IBOutlet weak var mapView: UIView!
    
    private var viewModel = TaxipoolInviteDetailsViewModel()
    private var pickUpMarker,dropMarker: GMSMarker?
    weak var viewMap: GMSMapView!
    var floatingPanelController: FloatingPanelController!
    var taxipoolInviteDetailBottomViewController: TaxipoolInviteDetailBottomViewController!
    
    func showReceivedTaxipoolInvite(taxipoolInvite: TaxiPoolInvite,matchedTaxiRideGroup: MatchedTaxiRideGroup,isFromJoinMyRide: Bool){
        viewModel = TaxipoolInviteDetailsViewModel(taxiInvite: taxipoolInvite,matchedTaxiRideGroup: matchedTaxiRideGroup,isFromJoinMyRide: isFromJoinMyRide)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomSheetViewController()
        viewModel.getInvtedUserDetails { [weak self] (result) in
            if result{
                self?.taxipoolInviteDetailBottomViewController.taxiInviteDetailCardTableView.reloadData()
            }
        }
        viewMap = QRMapView.getQRMapView(mapViewContainer: mapView)
        viewMap.padding = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 40)
        viewMap.delegate = self
        drawUserRoute()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    private func drawUserRoute(){
        GoogleMapUtils.drawRoute(pathString: viewModel.taxiInvite?.overviewPolyLine ?? "", map: viewMap, colorCode: UIColor(netHex: 0x007AFF), width: GoogleMapUtils.POLYLINE_WIDTH_4, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        let start = CLLocationCoordinate2D(latitude: viewModel.taxiInvite?.fromLat ?? 0,longitude: viewModel.taxiInvite?.fromLng ?? 0)
        pickUpMarker?.map = nil
        pickUpMarker = nil
        pickUpMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: start, shortIcon: UIImage(named: "icon_start_location")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        dropMarker?.zIndex = 12
        dropMarker?.map = nil
        dropMarker = nil
        let end =  CLLocationCoordinate2D(latitude: viewModel.taxiInvite?.toLat ?? 0, longitude: viewModel.taxiInvite?.toLng ?? 0)
        dropMarker = GoogleMapUtils.addMarker(googleMap: viewMap, location: end, shortIcon: UIImage(named: "icon_drop_location_new")!, tappable: false, anchor: CGPoint(x: 0.5, y: 0.5))
        dropMarker?.zIndex = 12
        if let routePolyline = viewModel.taxiInvite?.overviewPolyLine, viewMap != nil{
            GoogleMapUtils.fitToScreen(route: routePolyline, map : viewMap)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
//MARK: panel
extension TaxipoolInviteDetailsViewController: FloatingPanelControllerDelegate {
    private func addBottomSheetViewController() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.delegate = self
        floatingPanelController.surfaceView.backgroundColor = .clear
        floatingPanelController.surfaceView.shadowHidden = false
        floatingPanelController.surfaceView.grabberTopPadding = 10
        taxipoolInviteDetailBottomViewController = storyboard?.instantiateViewController(withIdentifier: "TaxipoolInviteDetailBottomViewController") as? TaxipoolInviteDetailBottomViewController
        taxipoolInviteDetailBottomViewController.prepareBottomSheet(viewModel: viewModel)
        floatingPanelController.set(contentViewController: taxipoolInviteDetailBottomViewController)
        floatingPanelController.track(scrollView: taxipoolInviteDetailBottomViewController.taxiInviteDetailCardTableView)
        floatingPanelController.addPanel(toParent: self, animated: true)
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        let taxipoolInviteDetailPanelLayout = TaxipoolInviteDetailPanelLayout()
        return taxipoolInviteDetailPanelLayout
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
                        }else{
                            self.floatingPanelController.backdropView.isHidden = false
                            self.floatingPanelController.surfaceView.shadowHidden = false
                        }
                       }, completion: nil)
    }
}
//FloatingPanelLayout
class TaxipoolInviteDetailPanelLayout: FloatingPanelLayout {
    var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()
    func initialiseData(taxiLiveRideViewModel: TaxiPoolLiveRideViewModel){
        self.taxiLiveRideViewModel = taxiLiveRideViewModel
    }
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .half:
            return 301
        case .tip:
            return 300
        default: return nil
        }
    }
}
