//
//  TaxiConfirmPickupPointViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 03/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps
class TaxiConfirmPickupPointViewController: PickupDropEditViewController {
    
    private var viewModel = TaxiConfirmPickupPointViewModel()
    
    func showConfirmPickPointView(taxiRide: TaxiRidePassenger,delegate: TaxiPickupSelectionDelegate){
        pickupDropEditViewViewModel = PickupDropEditViewModel(currentLatLng: CLLocationCoordinate2D(latitude: taxiRide.startLat ?? 0,longitude: taxiRide.startLng ?? 0), currentAddress: taxiRide.startAddress, isFromEditPickup: true, routePolyline: taxiRide.routePolyline ?? "",note: taxiRide.pickupNote)
        pickupDropEditViewViewModel.isFromTaxi = true
        viewModel = TaxiConfirmPickupPointViewModel(taxiRide: taxiRide, delegate: delegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteView.isHidden = false
        if let note = pickupDropEditViewViewModel.note {
            pickupNoteTextField.text = note
        }
    }
    
    override func drawRouteWithPickupOrDropPoint() {
        drawUserRoute(routePolyline: viewModel.taxiRide?.routePolyline ?? "", image: UIImage(named: "green"))
    }
    
    override func continueSavingPickupAndDropChanges() {
        viewModel.assignChangedValues(changedLatLng: pickupDropEditViewViewModel.changedLatLng, address: pickupDropEditViewViewModel.changedAddress,note: pickupNoteTextField.text)
        viewModel.delegate?.pickupChanged(taxiRide: viewModel.taxiRide!)
        self.navigationController?.popViewController(animated: true)
    }
}
