//
//  PickupDropEditViewController.swift
//  Quickride
//
//  Created by Vinutha on 10/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import GoogleMaps

class PickupDropEditViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet weak var locationDetailsView: UIView!
    @IBOutlet weak var pickupNoteTextField: UITextField!
    @IBOutlet weak var editMarkerPinButton: UIButton!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var noteView: UIView!
    
    //MARK: Properties
    private var mapView: GMSMapView!
    var pickupDropEditViewViewModel = PickupDropEditViewModel()
    
    //MARK: ViewModelInitializer
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: -3))
        setUpDelegate()
        handleViewCustomization()
        drawRouteWithPickupOrDropPoint()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.animate(with: GMSCameraUpdate.setTarget(pickupDropEditViewViewModel.currentLatLng, zoom: mapView.maxZoom))
        self.locationNameLabel.text = pickupDropEditViewViewModel.currentAddress
    }
    
    //MARK: Methods
    private func setUpDelegate() {
        mapView = QRMapView.getQRMapView(mapViewContainer: mapViewContainer)
        mapView.padding = UIEdgeInsets(top: 66, left: 0, bottom: 60, right: 0)
        mapView.delegate = self
        pickupNoteTextField.delegate = self
    }
    
    private func handleViewCustomization() {
        ViewCustomizationUtils.addCornerRadiusToView(view: locationDetailsView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: locationDetailsView, borderWidth: 1.0, color: UIColor(netHex: 0xcecece))
    }
    
    func drawRouteWithPickupOrDropPoint() {} //impltn in Child class
    
    func drawUserRoute(routePolyline: String, image: UIImage?) {
        pickupDropEditViewViewModel.matchedRoutePolyline = GoogleMapUtils.drawRoute(pathString: routePolyline, map: mapView, colorCode: UIColor.black, width: GoogleMapUtils.POLYLINE_WIDTH_6, zIndex: GoogleMapUtils.Z_INDEX_10, tappable: false)
        let pickupOrDropMarker = GoogleMapUtils.addMarker(googleMap: mapView, location: pickupDropEditViewViewModel.currentLatLng, shortIcon: image ?? UIImage(),tappable: false)
        pickupOrDropMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func locationSelectCompleted(position: CLLocationCoordinate2D) {
        if pickupDropEditViewViewModel.isFromTaxi{
            locationNameLabel.textColor = .black
            pickupNoteTextField.textColor = UIColor.black.withAlphaComponent(0.6)
            doneButton.backgroundColor = UIColor(netHex: 0x00B557)
        }else{
            mapView.animate(toLocation: position)
        }
        pickupDropEditViewViewModel.changedLatLng = position
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.PickupDropEditView", coordinate: position, handler: { (location,error) -> Void in
            if error != nil{
                ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
            }else if location == nil{
                UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
            }else{
                self.pickupDropEditViewViewModel.changedAddress = location!.completeAddress
                self.locationNameLabel.text = location!.completeAddress
            }
        })
    }
    
    func checkDifferenceBetweenChangedPickupAndContinueSaving() {
        let distance = LocationClientUtils.getDistance(fromLatitude: pickupDropEditViewViewModel.currentLatLng.latitude, fromLongitude: pickupDropEditViewViewModel.currentLatLng.longitude, toLatitude: pickupDropEditViewViewModel.changedLatLng.latitude, toLongitude: pickupDropEditViewViewModel.changedLatLng.longitude)
        if distance > 500 {
            var message = Strings.pickup_change_may_vary_fare
            if !pickupDropEditViewViewModel.isFromEditPickup {
                message = Strings.drop_change_may_vary_fare
            }
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : true, message1: message, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.yes_caps == result{
                    self.continueSavingPickupAndDropChanges()
                }
            })
        } else {
            self.continueSavingPickupAndDropChanges()
        }
    }
    
    func continueSavingPickupAndDropChanges() {} //imptn in child class
    
    
    //MARK: Actions
    @IBAction func ibaDone(_ sender: UIButton) {
        if isValueChanged() {
            checkDifferenceBetweenChangedPickupAndContinueSaving()
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if isValueChanged() {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.save_caps == result{
                    self.checkDifferenceBetweenChangedPickupAndContinueSaving()
                } else {
                    self.navigationController?.popViewController(animated: false)
                }
            })
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    private func isValueChanged() -> Bool{
        if pickupDropEditViewViewModel.isFromEditPickup{
            let input = pickupNoteTextField.text
            if (pickupDropEditViewViewModel.note == nil && input?.isEmpty == false) || (pickupDropEditViewViewModel.note != nil && input?.isEmpty == true) || (pickupDropEditViewViewModel.note != nil && pickupDropEditViewViewModel.note != input){
                return true
            }
        }
        if pickupDropEditViewViewModel.isLocationChanged && (pickupDropEditViewViewModel.currentLatLng.latitude != pickupDropEditViewViewModel.changedLatLng.latitude || pickupDropEditViewViewModel.currentLatLng.longitude != pickupDropEditViewViewModel.changedLatLng.longitude) {
            return true
        }
        return false
    }
}
//MARK: GMSMapViewDelegate
extension PickupDropEditViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if pickupDropEditViewViewModel.isLocationChanged {
            if pickupDropEditViewViewModel.isFromTaxi{
                locationSelectCompleted(position: position.target)
            }else{
                var nearestPoint = GoogleMapUtils.nearestPolylineLocation(toCoordinate: position.target, polyline: pickupDropEditViewViewModel.matchedRoutePolyline!)
                if nearestPoint == nil {
                    let latLngIndex = LocationClientUtils.getNearestLatLongPositionForPath(checkLatLng: position.target, route: pickupDropEditViewViewModel.matchedUserRoute!)
                    nearestPoint = pickupDropEditViewViewModel.matchedUserRoute![latLngIndex]
                }
                locationSelectCompleted(position: nearestPoint!)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            locationNameLabel.textColor = UIColor(netHex: 0xA9A9A9)
            pickupNoteTextField.textColor = UIColor(netHex: 0xA9A9A9)
            doneButton.backgroundColor = UIColor(netHex: 0xC2C2C2)
            pickupDropEditViewViewModel.isLocationChanged = true
        }else{
            locationNameLabel.textColor = .black
            pickupNoteTextField.textColor = UIColor.black.withAlphaComponent(0.6)
            doneButton.backgroundColor = UIColor(netHex: 0x00B557)
        }
    }
}
//MARK: UITextFieldDelegate
extension PickupDropEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let threshold = 500
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}
