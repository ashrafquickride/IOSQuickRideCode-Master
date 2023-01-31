//
//  ConfirmCarpoolPickupOrDropPointViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class ConfirmCarpoolPickupOrDropPointViewController: PickupDropEditViewController {
    
    private var viewModel = ConfirmCarpoolPickupOrDropPointViewModel()
    
    func showConfirmPickPointView(matchedUser: MatchedUser,riderRoutePolyline : String,delegate : PickUpAndDropSelectionDelegate, passengerRideId :Double?,riderRideId : Double?,passengerId :Double?,riderId : Double?,noOfSeats : Int,isFromEditPickup: Bool, note: String?){
        if isFromEditPickup{
            pickupDropEditViewViewModel = PickupDropEditViewModel(currentLatLng: CLLocationCoordinate2D(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!), currentAddress: matchedUser.pickupLocationAddress, isFromEditPickup: isFromEditPickup,routePolyline: riderRoutePolyline,note: matchedUser.userPreferredPickupDrop?.note)
        }else{
            pickupDropEditViewViewModel = PickupDropEditViewModel(currentLatLng: CLLocationCoordinate2D(latitude: matchedUser.dropLocationLatitude!,longitude: matchedUser.dropLocationLongitude!), currentAddress: matchedUser.dropLocationAddress, isFromEditPickup: isFromEditPickup,routePolyline: riderRoutePolyline,note: matchedUser.userPreferredPickupDrop?.note)
        }
        self.viewModel = ConfirmCarpoolPickupOrDropPointViewModel(matchedUser: matchedUser, riderRoutePolyline: riderRoutePolyline, delegate: delegate, passengerRideId: passengerRideId, riderRideId: riderRideId, passengerId: passengerId, riderId: riderId, noOfSeats: noOfSeats)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNoteView()
    }
    
    override func drawRouteWithPickupOrDropPoint() {
        if pickupDropEditViewViewModel.isFromEditPickup{
            drawUserRoute(routePolyline: viewModel.riderRoutePolyline!, image: UIImage(named: "green"))
        } else {
            drawUserRoute(routePolyline: viewModel.riderRoutePolyline!, image: UIImage(named: "red"))
        }
    }
    
    private func showNoteView(){
        if pickupDropEditViewViewModel.isFromEditPickup{
            noteView.isHidden = false
            if let note = pickupDropEditViewViewModel.note {
                pickupNoteTextField.text = note
            }
        }else{
            noteView.isHidden = true
        }
    }
    
    override func continueSavingPickupAndDropChanges() {
        if pickupDropEditViewViewModel.isFromEditPickup{
            viewModel.matchedUser!.pickupLocationLatitude = pickupDropEditViewViewModel.changedLatLng.latitude
            viewModel.matchedUser!.pickupLocationLongitude = pickupDropEditViewViewModel.changedLatLng.longitude
            viewModel.matchedUser?.pickupLocationAddress = pickupDropEditViewViewModel.changedAddress
        }else{
            viewModel.matchedUser!.dropLocationLatitude = pickupDropEditViewViewModel.changedLatLng.latitude
            viewModel.matchedUser!.dropLocationLongitude = pickupDropEditViewViewModel.changedLatLng.longitude
            viewModel.matchedUser?.dropLocationAddress = pickupDropEditViewViewModel.changedAddress
        }
        if pickupNoteTextField.text != nil && !pickupNoteTextField.text!.isEmpty {
            checkPreferredPickupDropAndContinueSaving()
        } else {
            self.completeSavingPickupDrop(preferredPickupDrop: nil)
        }
    }
    
    private func checkPreferredPickupDropAndContinueSaving() {
        let newPreferredPickupDrop = UserPreferredPickupDrop(userId: viewModel.passengerId, latitude: viewModel.matchedUser!.pickupLocationLatitude!, longitude: viewModel.matchedUser!.pickupLocationLongitude, type: Strings.pick_up, note: pickupNoteTextField.text)
        var updatedPreferredPickupDrop: UserPreferredPickupDrop?
        if let userPreferredPickupDrops = UserDataCache.getInstance()?.getUserPreferredPickupDrops() {
            for userPreferredPickupDrop in userPreferredPickupDrops {
                if LocationClientUtils.getDistance(fromLatitude: userPreferredPickupDrop.latitude ?? 0, fromLongitude: userPreferredPickupDrop.longitude ?? 0, toLatitude: viewModel.matchedUser!.pickupLocationLatitude!, toLongitude: viewModel.matchedUser!.pickupLocationLongitude!) <= 500 {
                    updatedPreferredPickupDrop = userPreferredPickupDrop
                    updatedPreferredPickupDrop!.note = pickupNoteTextField.text
                    updatedPreferredPickupDrop!.latitude = viewModel.matchedUser!.pickupLocationLatitude!
                    updatedPreferredPickupDrop!.longitude = viewModel.matchedUser!.pickupLocationLongitude!
                    break
                }
            }
        }
        if let updatedPickupDrop = updatedPreferredPickupDrop {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.already_having_pickup_note, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.yes_caps == result{
                    self.completeSavingPickupDrop(preferredPickupDrop: updatedPickupDrop)
                }
            })
        } else {
            self.completeSavingPickupDrop(preferredPickupDrop: newPreferredPickupDrop)
        }
    }
    
    private func completeSavingPickupDrop(preferredPickupDrop: UserPreferredPickupDrop?) {
        if viewModel.passengerRideId != nil && viewModel.riderRideId != nil {
            viewModel.getRideMatchMetricsForNewPickupDrop(preferredPickupDrop: preferredPickupDrop, viewController: self)
        }
    }
}
